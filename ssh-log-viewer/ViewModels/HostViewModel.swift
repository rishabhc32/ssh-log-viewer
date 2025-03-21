import Foundation
import SwiftUI
import Observation

@Observable
class HostViewModel {
    var hosts: [Host] = []
    var selectedHost: Host?
    var isConnecting = false
    var connectionError: String? = nil

    // Dictionary to maintain an individual SSHManager for each host.
    // This assumes that Host.id is a unique and Hashable identifier (e.g., UUID).
    private var sshManagers: [UUID: SSHManager] = [:]
    
    // Computed property to get files for the selected host
    var files: [RemoteFile] {
        selectedHost?.files ?? []
    }
    
    func addHost(name: String, hostname: String, username: String, password: String, port: Int = 22) {
        let newHost = Host(name: name, hostname: hostname, username: username, password: password, port: port)
        hosts.append(newHost)
    }
    
    func removeHost(at offsets: IndexSet) {
        // Disconnect and remove the SSH manager for each host being removed.
        offsets.forEach { index in
            let host = hosts[index]
            disconnectFromHost(host: host)
            sshManagers.removeValue(forKey: host.id)
        }
        hosts.remove(atOffsets: offsets)
        
        // Clear the selected host if it was removed.
        if let selectedHost = selectedHost,
           !hosts.contains(where: { $0.id == selectedHost.id }) {
            self.selectedHost = nil
        }
    }
    
    /// Returns the SSHManager associated with a host.
    /// If one does not exist, a new instance is created and added to the dictionary.
    private func sshManager(for host: Host) -> SSHManager {
        if let manager = sshManagers[host.id] {
            return manager
        } else {
            let newManager = SSHManager()
            sshManagers[host.id] = newManager
            return newManager
        }
    }
    
    /// Establishes an SSH connection for the given host.
    /// - Parameters:
    ///   - host: The host to connect to.
    ///   - password: User password for the SSH connection.
    ///   - remotePath: The remote path to fetch files from. The default is "/" (root).
    func connectToHost(host: Host) async {
        guard !isConnecting else { return }
        
        isConnecting = true
        connectionError = nil
        
        // Get or create the SSHManager for this host.
        let manager = sshManager(for: host)
        
        do {
            let connected = try manager.connect(
                hostname: host.hostname,
                port: host.port,
                username: host.username,
                password: host.password
            )
            
            if connected {
                let remotePath = "/home/\(host.username)/"
                try await fetchRemoteFiles(for: host, path: remotePath)
            }
        } catch {
            connectionError = "Connection failed: \(error.localizedDescription)"
        }
        
        isConnecting = false
    }
    
    /// Disconnects the SSH connection for a given host and removes its connection from the dictionary.
    func disconnectFromHost(host: Host) {
        let manager = sshManager(for: host)
        manager.disconnect()
        sshManagers.removeValue(forKey: host.id)
    }
    
    /// Fetches remote files from a given path for a host using its dedicated SSH connection.
    func fetchRemoteFiles(for host: Host, path: String = "/") async throws {
        let manager = sshManager(for: host)
        do {
            let remoteFiles = try manager.listFiles(path: path)
            
            // Update the host's files on the main thread
            await MainActor.run {
                if var updatedHost = hosts.first(where: { $0.id == host.id }) {
                    updatedHost.files = remoteFiles
                    
                    // Update the host in the list
                    if let index = hosts.firstIndex(where: { $0.id == host.id }) {
                        hosts[index] = updatedHost
                    }
                    
                    // Update selected host if needed
                    if selectedHost?.id == host.id {
                        selectedHost = updatedHost
                    }
                }
            }
        } catch {
            throw error
        }
    }
}

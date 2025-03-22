import Foundation
import SwiftUI
import Observation

@Observable
class HostViewModel {
    var hosts: [Host] = []
    var selectedHost: Host?
    var isConnecting = false
    var connectionError: String? = nil
    
    // Directory navigation properties - maintained per host
    private var hostNavigationState: [UUID: (currentPath: String, backStack: [String], forwardStack: [String])] = [:]
    
    // Helper method to get navigation state for the current host
    private func currentNavigationState() -> (currentPath: String, backStack: [String], forwardStack: [String])? {
        return selectedHost.flatMap { hostNavigationState[$0.id] }
    }
    
    // Computed properties to get navigation state for the current host
    var currentPath: String {
        return currentNavigationState()?.currentPath ?? "/"
    }
    
    var canNavigateBack: Bool {
        return currentNavigationState()?.backStack.isEmpty == false
    }
    
    var canNavigateForward: Bool {
        return currentNavigationState()?.forwardStack.isEmpty == false
    }
    
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
        for index in offsets {
            let host = hosts[index]
            disconnectFromHost(host: host)  // Disconnect the host            
            hostNavigationState.removeValue(forKey: host.id) // Clean up navigation state
            
            // If the removed host is the selected one, clear the selection immediately.
            if selectedHost?.id == host.id {
                self.selectedHost = nil
            }
        }
        
        // Remove hosts from the list.
        hosts.remove(atOffsets: offsets)
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
        
        // Only initialize navigation state if it doesn't exist for this host
        if hostNavigationState[host.id] == nil {
            let homePath = FormattingUtils.joinPath(basePath: "/home", filename: host.username)
            hostNavigationState[host.id] = (currentPath: homePath, backStack: [], forwardStack: [])
        }
        
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
                        
                        // Update navigation state with the new path
                        if var state = hostNavigationState[host.id] {
                            // Only update if the path is different
                            if state.currentPath != path {
                                state.currentPath = path
                                hostNavigationState[host.id] = state
                            }
                        }
                    }
                }
            }
        } catch {
            throw error
        }
    }
    
    /// Navigate to a directory
    func navigateToDirectory(_ directory: RemoteFile) async {
        guard let host = selectedHost, directory.isDirectory else { return }
        
        // Get or create navigation state
        var state = hostNavigationState[host.id] ?? (currentPath: "/", backStack: [], forwardStack: [])
        
        // Add current path to back stack and clear forward stack
        state.backStack.append(state.currentPath)
        state.forwardStack = []
        state.currentPath = directory.path
        
        // Update the state
        hostNavigationState[host.id] = state
        
        do {
            try await fetchRemoteFiles(for: host, path: directory.path)
        } catch {
            connectionError = "Failed to navigate to directory: \(error.localizedDescription)"
        }
    }
    
    /// Navigate back to the previous directory
    func navigateBack() async {
        guard let host = selectedHost, canNavigateBack else { return }
        
        // Get navigation state
        guard var state = hostNavigationState[host.id] else { return }
        
        // Get the previous path from the back stack
        if let previousPath = state.backStack.popLast() {
            // Add current path to forward stack
            state.forwardStack.append(state.currentPath)
            state.currentPath = previousPath
            
            // Update the state
            hostNavigationState[host.id] = state
            
            do {
                try await fetchRemoteFiles(for: host, path: previousPath)
            } catch {
                connectionError = "Failed to navigate back: \(error.localizedDescription)"
            }
        }
    }
    
    /// Navigate to the home directory
    func navigateToHome() async {
        guard let host = selectedHost else { return }
        
        let homePath = FormattingUtils.joinPath(basePath: "/home", filename: host.username)
        
        // Get or create navigation state
        var state = hostNavigationState[host.id] ?? (currentPath: "/", backStack: [], forwardStack: [])
        
        // Add current path to back stack and clear forward stack
        state.backStack.append(state.currentPath)
        state.forwardStack = []
        state.currentPath = homePath
        
        // Update the state
        hostNavigationState[host.id] = state
        
        do {
            try await fetchRemoteFiles(for: host, path: homePath)
        } catch {
            connectionError = "Failed to navigate to home directory: \(error.localizedDescription)"
        }
    }
    
    /// Navigate forward to the next directory
    func navigateForward() async {
        guard let host = selectedHost, canNavigateForward else { return }
        
        // Get navigation state
        guard var state = hostNavigationState[host.id] else { return }
        
        // Get the next path from the forward stack
        if let nextPath = state.forwardStack.popLast() {
            // Add current path to back stack
            state.backStack.append(state.currentPath)
            state.currentPath = nextPath
            
            // Update the state
            hostNavigationState[host.id] = state
            
            do {
                try await fetchRemoteFiles(for: host, path: nextPath)
            } catch {
                connectionError = "Failed to navigate forward: \(error.localizedDescription)"
            }
        }
    }
}

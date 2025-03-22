import Observation
import SwiftUI

@Observable
class HostViewModel {
    var hosts: [Host] = []
    var selectedHost: Host?
    var isConnecting = false
    var connectionError: String? = nil

    // Using a class allows the dictionary to hold references that update in place.
    private var navigationStates: [UUID: NavigationState] = [:]

    // Dictionary for storing an SSHManager for each host.
    private var sshManagers: [UUID: SSHManager] = [:]

    /// Returns the NavigationState associated with a host.
    /// If one does not exist, a new instance is created and added to the dictionary.
    private func navigationState(for host: Host) -> NavigationState {
        if let state = navigationStates[host.id] {
            return state
        } else {
            let newState = NavigationState(currentPath: host.homePath)
            navigationStates[host.id] = newState
            return newState
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

    // Computed properties using the navigation state.
    var currentPath: String {
        guard let host = selectedHost else { return "/" }
        return navigationState(for: host).currentPath
    }

    var canNavigateBack: Bool {
        guard let host = selectedHost else { return false }
        return navigationState(for: host).canNavigateBack
    }

    var canNavigateForward: Bool {
        guard let host = selectedHost else { return false }
        return navigationState(for: host).canNavigateForward
    }

    // Returns files for the selected host.
    var files: [RemoteFile] {
        selectedHost?.files ?? []
    }

    func addHost(
        name: String, hostname: String, username: String, password: String, port: Int = 22
    ) {
        let newHost = Host(
            name: name,
            hostname: hostname,
            username: username,
            password: password,
            port: port
        )

        hosts.append(newHost)
    }

    func removeHost(at offsets: IndexSet) {
        for index in offsets {
            let host = hosts[index]
            disconnectFromHost(host: host)  // Disconnect the host
            navigationStates.removeValue(forKey: host.id)  // Clean up navigation state

            if selectedHost?.id == host.id {
                selectedHost = nil
            }
        }
        hosts.remove(atOffsets: offsets)
    }

    // Connect to the host and initialize its navigation state if needed.
    func connectToHost(host: Host) async {
        guard !isConnecting else { return }
        isConnecting = true
        connectionError = nil

        let manager = sshManager(for: host)

        do {
            let connected = try manager.connect(
                hostname: host.hostname,
                port: host.port,
                username: host.username,
                password: host.password
            )

            if connected {
                let state = navigationState(for: host)
                try await fetchRemoteFiles(for: host, path: state.currentPath)
            }
        } catch {
            connectionError = "Connection failed: \(error.localizedDescription)"
        }
        isConnecting = false
    }

    func disconnectFromHost(host: Host) {
        let manager = sshManager(for: host)
        manager.disconnect()
        sshManagers.removeValue(forKey: host.id)
    }

    func fetchRemoteFiles(for host: Host, path: String = "/") async throws {
        let manager = sshManager(for: host)
        let remoteFiles = try manager.listFiles(path: path)

        // Update the host's files on the main thread
        await MainActor.run {
            if let index = hosts.firstIndex(where: { $0.id == host.id }) {
                // Update the host's files and store back in the array
                hosts[index].files = remoteFiles

                // Update the current path for this host
                let state = navigationState(for: host)
                state.currentPath = path

                // Update selected host if needed
                if selectedHost?.id == host.id {
                    selectedHost = hosts[index]
                }
            }
        }
    }

    // Updated unified navigation method using a navigation action.
    private func updateNavigation(for host: Host, action: NavigationAction) async {
        let state = navigationState(for: host)

        guard let targetPath = state.updateNavigation(action: action) else {
            return
        }

        do {
            try await fetchRemoteFiles(for: host, path: targetPath)
        } catch {
            connectionError = "Navigation failed: \(error.localizedDescription)"
        }
    }

    func navigateToDirectory(_ directory: RemoteFile) async {
        guard let host = selectedHost, directory.isDirectory else { return }
        await updateNavigation(for: host, action: .to(path: directory.path))
    }

    func navigateToHome() async {
        guard let host = selectedHost else { return }
        await updateNavigation(for: host, action: .to(path: host.homePath))
    }

    func navigateBack() async {
        guard let host = selectedHost else { return }
        await updateNavigation(for: host, action: .back)
    }

    func navigateForward() async {
        guard let host = selectedHost else { return }
        await updateNavigation(for: host, action: .forward)
    }
}

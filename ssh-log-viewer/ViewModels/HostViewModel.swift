import Foundation
import SwiftUI
import Observation

@Observable class HostViewModel {
    var hosts: [Host] = []
    var selectedHost: Host?
    var files: [RemoteFile] = []
    
    init() {
        // Load sample data for demonstration
        loadSampleData()
    }
    
    func addHost(name: String, hostname: String, username: String, port: Int = 22) {
        let newHost = Host(name: name, hostname: hostname, username: username, port: port)
        hosts.append(newHost)
    }
    
    func removeHost(at offsets: IndexSet) {
        hosts.remove(atOffsets: offsets)
        if selectedHost == nil || !hosts.contains(where: { $0.id == selectedHost?.id }) {
            selectedHost = hosts.first
            loadFiles()
        }
    }
    
    func selectHost(_ host: Host) {
        selectedHost = host
        loadFiles()
    }
    
    func loadFiles() {
        guard selectedHost != nil else {
            files = []
            return
        }
        
        // In a real app, this would connect to the host via SSH and fetch files
        // For now, we'll just load sample files
        loadSampleFiles()
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        hosts = [
            Host(name: "Local Server", hostname: "localhost", username: "user"),
            Host(name: "Production", hostname: "example.com", username: "admin"),
            Host(name: "Development", hostname: "dev.example.com", username: "developer")
        ]
        
        selectedHost = hosts.first
        loadFiles()
    }
    
    private func loadSampleFiles() {
        let now = Date()
        
        files = [
            RemoteFile(name: "var", path: "/var", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "etc", path: "/etc", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "home", path: "/home", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "usr", path: "/usr", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "bin", path: "/bin", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "sbin", path: "/sbin", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "lib", path: "/lib", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "tmp", path: "/tmp", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "boot", path: "/boot", isDirectory: true, size: 4096, modificationDate: now),
            RemoteFile(name: "dev", path: "/dev", isDirectory: true, size: 4096, modificationDate: now)
        ]
    }
}

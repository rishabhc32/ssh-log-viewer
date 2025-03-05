import Foundation
import SwiftUI
import Observation

@Observable class HostViewModel {
    var hosts: [Host] = []
    var selectedHost: Host?
    
    // Computed property to get files for the selected host
    var files: [RemoteFile] {
        selectedHost?.files ?? []
    }
    
    init() {
        // Load sample data for demonstration
        loadSampleData()
    }
    
    func addHost(name: String, hostname: String, username: String, port: Int = 22) {
        var newHost = Host(name: name, hostname: hostname, username: username, port: port)
        // Generate random files for the new host
        newHost.files = generateRandomFiles()
        hosts.append(newHost)
    }
    
    func removeHost(at offsets: IndexSet) {
        hosts.remove(atOffsets: offsets)
        
        // If the selected host was removed, set selectedHost to nil
        if let selectedHost = selectedHost, !hosts.contains(where: { $0.id == selectedHost.id }) {
            self.selectedHost = nil
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleData() {
        // Create hosts with random files
        var localServer = Host(name: "Local Server", hostname: "localhost", username: "user")
        localServer.files = generateRandomFiles()
        
        var production = Host(name: "Production", hostname: "example.com", username: "admin")
        production.files = generateRandomFiles()
        
        var development = Host(name: "Development", hostname: "dev.example.com", username: "developer")
        development.files = generateRandomFiles()
        
        hosts = [localServer, production, development]
    }
    
    // Generate a random list of files and directories
    private func generateRandomFiles() -> [RemoteFile] {
        let now = Date()
        var randomFiles: [RemoteFile] = []
        
        // Possible directories
        let possibleDirectories = [
            ("var", "/var"),
            ("etc", "/etc"),
            ("home", "/home"),
            ("usr", "/usr"),
            ("bin", "/bin"),
            ("sbin", "/sbin"),
            ("lib", "/lib"),
            ("tmp", "/tmp"),
            ("boot", "/boot"),
            ("dev", "/dev"),
            ("opt", "/opt"),
            ("mnt", "/mnt"),
            ("media", "/media"),
            ("srv", "/srv"),
            ("proc", "/proc")
        ]
        
        // Possible files
        let possibleFiles = [
            ("passwd", "/etc/passwd", Int64(1024)),
            ("shadow", "/etc/shadow", Int64(2048)),
            ("hosts", "/etc/hosts", Int64(512)),
            ("resolv.conf", "/etc/resolv.conf", Int64(128)),
            ("fstab", "/etc/fstab", Int64(1024)),
            ("bashrc", "/home/user/.bashrc", Int64(4096)),
            ("profile", "/home/user/.profile", Int64(2048)),
            ("nginx.conf", "/etc/nginx/nginx.conf", Int64(8192)),
            ("apache2.conf", "/etc/apache2/apache2.conf", Int64(16384)),
            ("php.ini", "/etc/php/php.ini", Int64(32768)),
            ("my.cnf", "/etc/mysql/my.cnf", Int64(4096)),
            ("sshd_config", "/etc/ssh/sshd_config", Int64(8192)),
            ("crontab", "/etc/crontab", Int64(1024)),
            ("syslog", "/var/log/syslog", Int64(1048576)),
            ("auth.log", "/var/log/auth.log", Int64(524288)),
            ("kern.log", "/var/log/kern.log", Int64(2097152)),
            ("dmesg", "/var/log/dmesg", Int64(131072)),
            ("boot.log", "/var/log/boot.log", Int64(262144)),
            ("dpkg.log", "/var/log/dpkg.log", Int64(65536)),
            ("alternatives.log", "/var/log/alternatives.log", Int64(32768))
        ]
        
        // Add random directories
        let shuffledDirectories = possibleDirectories.shuffled()
        let directoryCount = Int.random(in: 10...20)
        
        for i in 0..<min(directoryCount, shuffledDirectories.count) {
            let dir = shuffledDirectories[i]
            randomFiles.append(RemoteFile(name: dir.0, path: dir.1, isDirectory: true, size: Int64(4096), modificationDate: now))
        }
        
        // Add random files (5-12)
        let shuffledFiles = possibleFiles.shuffled()
        let fileCount = Int.random(in: 5...12)
        
        for i in 0..<min(fileCount, shuffledFiles.count) {
            let file = shuffledFiles[i]
            randomFiles.append(RemoteFile(name: file.0, path: file.1, isDirectory: false, size: file.2, modificationDate: now))
        }
        
        return randomFiles
    }
}

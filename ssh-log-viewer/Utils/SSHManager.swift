import mft

class SSHManager {
    private var sftpConnection: MFTSftpConnection?
    
    func connect(hostname: String, port: Int, username: String, password: String) throws -> Bool {
        let sftp = MFTSftpConnection(
            hostname: hostname,
            port: port,
            username: username,
            password: password
        )
        
        try sftp.connect()
        try sftp.authenticate()
        
        self.sftpConnection = sftp
        return true
    }
    
    func disconnect() {
        sftpConnection?.disconnect()
        sftpConnection = nil
    }
    
    func isConnected() -> Bool {
        return sftpConnection != nil
    }
    
    func listFiles(path: String = "/") throws -> [RemoteFile] {
        guard let sftp = sftpConnection else {
            throw SSHError.notConnected
        }
        
        let items = try sftp.contentsOfDirectory(atPath: path, maxItems: 1000)
        var files: [RemoteFile] = []
        
        for item in items {
            let itemPath = path.hasSuffix("/") ? "\(path)\(item.filename)" : "\(path)/\(item.filename)"
            
            let file = RemoteFile(
                name: item.filename,
                path: itemPath,
                isDirectory: item.isDirectory,
                size: Int64(item.size),
                modificationDate: item.mtime
            )
            
            files.append(file)
        }
        
        return files
    }
}

enum SSHError: Error {
    case notConnected
}


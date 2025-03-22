import mft

class SSHManager {
    private var sftpConnection: MFTSftpConnection?

    func connect(
        hostname: String, port: Int, username: String, password: String
    ) throws -> Bool {
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
            let itemPath = FormattingUtils.joinPath(basePath: path, filename: item.filename)

            let file = RemoteFile(
                name: item.filename,
                path: itemPath,
                isDirectory: item.isDirectory,
                size: Int64(item.size),
                modificationDate: item.mtime
            )

            files.append(file)
        }

        files.sort { (file1, file2) -> Bool in
            // If one is a directory and the other is not, this returns true if the left-hand side is a directory.
            if file1.isDirectory != file2.isDirectory {
                return file1.isDirectory
            }

            // If both are directories or both are files, sort alphabetically by name
            return file1.name.localizedCaseInsensitiveCompare(file2.name) == .orderedAscending
        }

        return files
    }
}

enum SSHError: Error {
    case notConnected
}

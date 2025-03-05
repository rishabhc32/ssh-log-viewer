import mft

class SSHManager {
    func connect() throws {
        let sftp = MFTSftpConnection(
            hostname: "123.123.123.123",
            port: 22,
            username: "your_user_name",
            password: "your_secret_password"
        )
        
        try sftp.connect()
        try sftp.authenticate()
    }
}


import Foundation

struct Host: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var hostname: String
    var username: String
    var password: String
    var port: Int = 22
    var files: [RemoteFile] = []

    var homePath: String {
        return FormattingUtils.joinPath(basePath: "/home", filename: username)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.id == rhs.id
    }
}

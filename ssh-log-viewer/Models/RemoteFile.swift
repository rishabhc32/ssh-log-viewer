import Foundation

struct RemoteFile: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var path: String
    var isDirectory: Bool
    var size: Int64
    var modificationDate: Date

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: RemoteFile, rhs: RemoteFile) -> Bool {
        lhs.id == rhs.id
    }
}

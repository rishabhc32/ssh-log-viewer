import Foundation

enum FormattingUtils {
    static func formatFileSize(_ size: Int64) -> String {
        if size == 0 {
            return "0 KB"
        }

        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    static func joinPath(basePath: String, filename: String) -> String {
        return basePath.hasSuffix("/") ? "\(basePath)\(filename)" : "\(basePath)/\(filename)"
    }
}

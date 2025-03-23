import SwiftUI

struct FileRowView: View {
    let file: RemoteFile
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Group {
                    if file.isDirectory {
                        Image("folder")
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image("doc")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 18, height: 18)

                VStack(alignment: .leading) {
                    Text(file.name)
                        .font(.body)
                        .foregroundColor(isSelected ? .white : .primary)

                    Text(file.path)
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white : .secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(FormattingUtils.formatFileSize(file.size))
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : .secondary)

                    Text(FormattingUtils.formatDate(file.modificationDate))
                        .font(.caption)
                        .foregroundColor(isSelected ? .white : .secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 2)
            .padding(.bottom, 4)
            .contentShape(Rectangle())
            .background(isSelected ? Color.accentColor : Color.clear)

            Divider()
        }
    }
}

#Preview {
    let files = [
        // Directories
        RemoteFile(
            name: "Documents",
            path: "/home/user/Documents",
            isDirectory: true,
            size: 4096,
            modificationDate: Date().addingTimeInterval(-86400 * 2)  // 2 days ago
        ),
        RemoteFile(
            name: "Downloads",
            path: "/home/user/Downloads",
            isDirectory: true,
            size: 4096,
            modificationDate: Date().addingTimeInterval(-86400)  // 1 day ago
        ),

        // Files
        RemoteFile(
            name: "report.pdf",
            path: "/home/user/report.pdf",
            isDirectory: false,
            size: 2_048_576,  // 2MB
            modificationDate: Date().addingTimeInterval(-3600 * 5)  // 5 hours ago
        ),
        RemoteFile(
            name: "config.json",
            path: "/home/user/config.json",
            isDirectory: false,
            size: 1024,  // 1KB
            modificationDate: Date().addingTimeInterval(-3600)  // 1 hour ago
        ),
        RemoteFile(
            name: "image.jpg",
            path: "/home/user/image.jpg",
            isDirectory: false,
            size: 5_242_880,  // 5MB
            modificationDate: Date()
        )
    ]

    return VStack(spacing: 0) {
        ForEach(files) { file in
            FileRowView(file: file, isSelected: file.name == "config.json" || file.name == "Downloads")
        }
    }
}

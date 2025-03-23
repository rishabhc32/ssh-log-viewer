import SwiftUI

struct FileRowView: View {
    let file: RemoteFile
    var isSelected: Bool = false
    var onDirectoryTap: ((RemoteFile) -> Void)? = nil

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
    let file = RemoteFile(
        name: "Documents",
        path: "/home/user/Documents",
        isDirectory: true,
        size: 4096,
        modificationDate: Date()
    )
    
    return FileRowView(file: file, isSelected: false)
}

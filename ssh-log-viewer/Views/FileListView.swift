import SwiftUI

struct FileListView: View {
    @ObservedObject var viewModel: HostViewModel
    
    var body: some View {
        VStack {
            if let selectedHost = viewModel.selectedHost {
                List {
                    ForEach(viewModel.files) { file in
                        HStack {
                            Image(systemName: file.isDirectory ? "folder" : "doc")
                                .foregroundColor(file.isDirectory ? .blue : .gray)
                            
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.headline)
                                
                                Text(file.path)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(formatFileSize(file.size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(formatDate(file.modificationDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                Text("Select a host to view files")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    private func formatFileSize(_ size: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    FileListView(viewModel: HostViewModel())
}

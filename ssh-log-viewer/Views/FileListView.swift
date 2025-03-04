import SwiftUI
import Observation

struct FileListView: View {
    @Bindable var viewModel: HostViewModel

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
                                Text(FormattingUtils.formatFileSize(file.size))
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text(FormattingUtils.formatDate(file.modificationDate))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .id(selectedHost.id) // Unique ID per host prevents sync
            } else {
                Text("Select a host to view files")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    FileListView(viewModel: HostViewModel())
}

import SwiftUI
import Observation

struct FileListView: View {
    @Bindable var viewModel: HostViewModel
    @State private var position: UUID?
    @State private var scrollHistory: [UUID: UUID] = [:]
    
    private let topId = "topSpacer"
    
    var body: some View {
        VStack {
            if let selectedHost = viewModel.selectedHost {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            // Add top padding to the first element
                            if !viewModel.files.isEmpty {
                                Spacer()
                                    .frame(height: 6)
                                    .id(topId)
                            }
                            
                            ForEach(viewModel.files) { file in
                                VStack(spacing: 0) {
                                    HStack {
                                        Image(systemName: file.isDirectory ? "folder" : "doc")
                                            .foregroundColor(file.isDirectory ? .blue : .gray)
                                            .font(.system(size: 16))
                                            .frame(width: 26)
                                            .padding(.trailing, 5)

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
                                    .padding(.horizontal, 12)
                                    .padding(.top, 0)
                                    .padding(.bottom, 6)
                                    
                                    Divider()
                                }
                                .id(file.id)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $position)
                    .onChange(of: position) { oldValue, newValue in
                        if (oldValue != newValue && newValue != nil) {
                            scrollHistory[selectedHost.id] = newValue
                        }
                    }
                    .onChange(of: selectedHost.id) { oldId, newId in
                        print("Host changed")
                        if let value = scrollHistory[selectedHost.id] {
                            print("Scrolling to: ", value)
                            proxy.scrollTo(value, anchor: .top)
                        } else {
                            print("Scroll to top")
                            proxy.scrollTo(topId, anchor: .top)
                        }
                    }

                }
               
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

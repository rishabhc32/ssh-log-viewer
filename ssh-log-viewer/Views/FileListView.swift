import Observation
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
            .padding(.top, 0)
            .padding(.bottom, 6)
            .contentShape(Rectangle())
            .background(isSelected ? Color.accentColor : Color.clear)

            Divider()
        }
    }
}

struct FileListView: View {
    @Bindable var viewModel: HostViewModel
    @State private var position: UUID?
    @State private var selectedFileId: UUID?
    
    // Mapping of Host ID to last scrolled position.For scroll position tracking we use File ID.
    @State private var scrollHistory: [UUID: UUID] = [:]
    @State private var showingPathMenu = false

    private let topId = UUID()

    var body: some View {
        VStack {
            if let selectedHost = viewModel.selectedHost {
                if viewModel.isConnecting {
                    // Loading state
                    VStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(1.2)  // Make it visually similar in size to the exclamation mark icon
                            .controlSize(.small)

                        Text("Connecting to \(selectedHost.name)...")
                    }
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.connectionError {
                    // Error state
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 20))
                            .foregroundColor(.red)

                        Text("Connection Error: \(error)")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)

                        Button("Retry") {
                            Task {
                                await viewModel.connectToHost(host: selectedHost)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // File list with native Finder-style navigation
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack {
                                // Add top padding to the first element
                                Spacer()
                                    .frame(height: 6)
                                    .id(topId)
                                
                                ForEach(viewModel.files) { file in
                                    FileRowView(
                                        file: file, 
                                        isSelected: selectedFileId == file.id
                                    )
                                    .id(file.id)  // Using File ID as scroll target
                                    .gesture(TapGesture(count: 2).onEnded {
                                        if file.isDirectory {
                                            Task {
                                                await viewModel.navigateToDirectory(file)
                                            }
                                        }
                                    })
                                    .simultaneousGesture(TapGesture().onEnded {
                                        selectedFileId = file.id
                                    })
                                }
                                
                            }
                            .scrollTargetLayout()
                        }
                        .background(.background)
                        .scrollPosition(id: $position)
                        .onChange(of: position) { oldValue, newValue in
                            if oldValue != newValue && newValue != nil {
                                scrollHistory[selectedHost.id] = newValue
                            }
                        }
                        .onChange(of: selectedHost.id) {
                            let destination = scrollHistory[selectedHost.id] ?? topId
                            proxy.scrollTo(destination, anchor: .top)
                        }
                        .navigationTitle(viewModel.currentPath)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigation) {
                                Button(action: {
                                    Task {
                                        await viewModel.navigateBack()
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                }
                                .help("Go back")
                                .disabled(!viewModel.canNavigateBack)
                                
                                Button(action: {
                                    Task {
                                        await viewModel.navigateForward()
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                }
                                .help("Go forward")
                                .disabled(!viewModel.canNavigateForward)
                                
                                Button(action: {
                                    Task {
                                        await viewModel.navigateToHome()
                                    }
                                }) {
                                    Image(systemName: "house")
                                }
                                .help("Go to home directory")
                            }
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
    let viewModel = HostViewModel()

    let host = Host(
        name: "Preview Server",
        hostname: "example.com",
        username: "user",
        password: "password",
        files: [
            RemoteFile(
                name: "Documents",
                path: "/home/user/Documents",
                isDirectory: true,
                size: 4096,
                modificationDate: Date()
            ),
            RemoteFile(
                name: "notes.txt",
                path: "/home/user/notes.txt",
                isDirectory: false,
                size: 1024,
                modificationDate: Date().addingTimeInterval(-86400)
            )
        ]
    )

    viewModel.hosts.append(host)
    viewModel.selectedHost = host

    return FileListView(viewModel: viewModel)
}

#Preview("NoHost") {
    let viewModel = HostViewModel()
    viewModel.selectedHost = nil
    return FileListView(viewModel: viewModel)
}

#Preview("Loading") {
    let viewModel = HostViewModel()
    let host = Host(
        name: "Example Host",
        hostname: "example.com",
        username: "user",
        password: "password"
    )
    viewModel.hosts.append(host)
    viewModel.selectedHost = host
    viewModel.isConnecting = true
    return FileListView(viewModel: viewModel)
}

#Preview("Error") {
    let viewModel = HostViewModel()
    let host = Host(
        name: "Error Example",
        hostname: "example.com",
        username: "user",
        password: "password"
    )
    viewModel.hosts.append(host)
    viewModel.selectedHost = host
    viewModel.connectionError = "Failed to connect to server. Please check your credentials and try again."
    return FileListView(viewModel: viewModel)
}

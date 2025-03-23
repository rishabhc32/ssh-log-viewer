import Observation
import SwiftUI

struct FileListView: View {
    @Bindable var viewModel: HostViewModel
    @State private var position: UUID?
    @State private var selectedFileIndex: Int?
    
    // Computed property for selectedFileId based on selectedFileIndex
    private var selectedFileId: UUID? {
        if let index = selectedFileIndex, index < viewModel.files.count {
            return viewModel.files[index].id
        }
        return nil
    }

    // Mapping of Host ID to last scrolled position. For scroll position tracking we use File ID.
    @State private var scrollHistory: [UUID: UUID] = [:]

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
                            LazyVStack(spacing: 0) {
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
                                        // double click to navigate to directory
                                        if file.isDirectory {
                                            Task {
                                                await viewModel.navigateToDirectory(file)
                                            }
                                        }
                                    })
                                    .simultaneousGesture(TapGesture().onEnded {
                                        // single click to highlight the file
                                        selectedFileIndex = viewModel.files.firstIndex(where: { $0.id == file.id })
                                    })
                                }
                                
                            }
                            .scrollTargetLayout()
                        }
                        .focusable()
                        .focusEffectDisabled()
                        .onKeyPress(keys: [.upArrow, .downArrow, .return]) { keyPress in
                            switch keyPress.key {
                            case .upArrow, .downArrow:
                                // Only proceed if files exist
                                guard !viewModel.files.isEmpty else { break }
                                
                                if let index = selectedFileIndex {
                                    let increment = (keyPress.key == .upArrow) ? -1 : 1
                                    let newIndex = index + increment
                                    // Only update if the new index is within valid bounds
                                    if newIndex >= 0 && newIndex < viewModel.files.count {
                                        selectedFileIndex = newIndex
                                    }
                                } else {
                                    // If no file is selected, default to the first file
                                    selectedFileIndex = 0
                                }
                                // Update the position after changing the selection
                                position = selectedFileId

                            case .return:
                                // Handle file/directory selection
                                if let index = selectedFileIndex, index < viewModel.files.count {
                                    let selectedFile = viewModel.files[index]
                                    if selectedFile.isDirectory {
                                        Task {
                                            await viewModel.navigateToDirectory(selectedFile)
                                        }
                                    }
                                }
                            
                            default:
                                break
                            }
                            return .handled
                        }
                        .background(.background)
                        .scrollPosition(id: $position)
                        .onChange(of: position) { oldValue, newValue in
                            if oldValue != newValue && newValue != nil {
                                scrollHistory[selectedHost.id] = newValue
                            }
                        }
                        .onChange(of: selectedHost.id) {
                            // Reset scroll position when changing hosts
                            let destination = scrollHistory[selectedHost.id] ?? topId
                            proxy.scrollTo(destination, anchor: .top)
                        }
                        .onChange(of: viewModel.files) {
                            // Reset selection when navigating to a new directory
                            selectedFileIndex = nil
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

#Preview("Files") {
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
                name: "file.txt",
                path: "/home/user/file.txt",
                isDirectory: false,
                size: 1024,
                modificationDate: Date()
            ),
        ]
    )

    viewModel.hosts = [host]
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

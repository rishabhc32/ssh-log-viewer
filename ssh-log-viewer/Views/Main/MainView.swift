import Observation
import SwiftUI

struct MainView: View {
    @State private var viewModel: HostViewModel

    init(viewModel: HostViewModel? = nil) {
        _viewModel = State(initialValue: viewModel ?? HostViewModel())
    }
    @State private var showingAddHost = false
    @State private var hostToDelete: Host? = nil

    private func triggerDelete(for host: Host) {
        hostToDelete = host
    }

    private func triggerAddHost() {
        showingAddHost = true
    }

    private func connectToSelectedHost() {
        if let host = viewModel.selectedHost {
            Task {
                await viewModel.connectToHost(host: host)
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                if viewModel.hosts.isEmpty {
                    EmptyStateView()
                } else {
                    List(selection: $viewModel.selectedHost) {
                        Section(header: Text("Hosts")) {
                            ForEach(viewModel.hosts) { host in
                                HostRowView(host: host, deleteAction: triggerDelete)
                                    .tag(host)
                            }
                        }
                    }
                    .contextMenu {
                        Button(action: triggerAddHost) {
                            Label("Add Host", systemImage: "plus")
                        }
                        .keyboardShortcut("n", modifiers: [.command, .shift])
                    }
                }

                Button(action: {
                    triggerAddHost()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Host")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                .padding(.bottom)
                .help("Add a new host (⌘⇧N)")
            }
            .navigationTitle("SSH Log Viewer")
            .focusedValue(\.hostActions, HostActions(
                add: triggerAddHost,
                delete: {
                    if let selectedHost = viewModel.selectedHost {
                        triggerDelete(for: selectedHost)
                    }
                }
            ))
            .sheet(isPresented: $showingAddHost) {
                AddHostView(viewModel: viewModel)
            }
            .alert("Delete Host", isPresented: .constant(hostToDelete != nil), presenting: hostToDelete) { host in
                Button("Cancel", role: .cancel) { hostToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let index = viewModel.hosts.firstIndex(where: {
                        $0.id == host.id
                    }) {
                        viewModel.removeHost(at: IndexSet(integer: index))
                        hostToDelete = nil
                    }
                }
            } message: { host in
                Text(
                    "Are you sure you want to delete '\(host.name)'? This action cannot be undone."
                )
            }
        } detail: {
            // Track when the selected host changes and connect if needed
            if let selectedHost = viewModel.selectedHost {
                FileListView(viewModel: viewModel)
                    .onAppear(perform: connectToSelectedHost)
                    .onChange(of: selectedHost.id) { connectToSelectedHost() }
            } else {
                Text("Select a host to view files")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    let viewModel = HostViewModel()
    viewModel.hosts.append(
        Host(
            name: "Test Server",
            hostname: "127.0.0.1",
            username: "demo",
            password: "demo",
            port: 2222
        )
    )
    return MainView(viewModel: viewModel)
}

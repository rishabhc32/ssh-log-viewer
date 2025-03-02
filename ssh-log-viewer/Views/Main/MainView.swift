import SwiftUI
import Observation

struct MainView: View {
    @State private var viewModel = HostViewModel()
    @State private var showingAddHost = false
    @State private var hostToDelete: Host? = nil

    private func triggerDelete(for host: Host) {        
        hostToDelete = host
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                List(selection: $viewModel.selectedHost) {
                    Section(header: Text("Hosts")) {
                        ForEach(viewModel.hosts) { host in
                            HStack {
                                Image(systemName: "server.rack")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(host.name)
                                        .font(.headline)
                                    Text("\(host.username)@\(host.hostname):\(host.port)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .tag(host)
                            .contextMenu {
                                Button(role: .destructive, action: {
                                    triggerDelete(for: host)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                                .keyboardShortcut("d", modifiers: [.command])

                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive, action: {
                                    triggerDelete(for: host)
                                }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                .contextMenu {
                    Button(action: {
                        showingAddHost = true
                    }) {
                        Label("Add Host", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: [.command, .shift])
                }
                
                Button(action: {
                    showingAddHost = true
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
                add: { self.showingAddHost = true },
                delete: { if let selectedHost = viewModel.selectedHost { triggerDelete(for: selectedHost) } }
            ))
            .sheet(isPresented: $showingAddHost) {
                AddHostView(viewModel: viewModel)
            }
            .alert("Delete Host", isPresented: .constant(hostToDelete != nil), presenting: hostToDelete) { host in
                Button("Cancel", role: .cancel) { hostToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let index = viewModel.hosts.firstIndex(where: { $0.id == host.id }) {
                        viewModel.removeHost(at: IndexSet(integer: index))
                    }
                }
            } message: { host in
                Text("Are you sure you want to delete \(host.name)? This action cannot be undone.")
            }
        } detail: {
            FileListView(viewModel: viewModel)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
}

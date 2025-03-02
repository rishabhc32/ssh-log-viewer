import SwiftUI
import Observation

struct MainView: View {
    @State private var viewModel = HostViewModel()
    @State private var showingAddHost = false
    @State private var hostToDelete: Host? = nil

    private func triggerDelete(for host: Host) {        
        hostToDelete = host
    }
    
    private func triggerAddHost() {
        showingAddHost = true
    }
    
    var body: some View {
        NavigationSplitView {
            VStack {
                if viewModel.hosts.isEmpty {
                    EmptyStateView()
                } else {
                    HostListView(
                        selectedHost: $viewModel.selectedHost,
                        hosts: viewModel.hosts,
                        addHostAction: triggerAddHost,
                        deleteAction: triggerDelete
                    )
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

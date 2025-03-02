import SwiftUI

// MARK: - Host Row View
struct HostRowView: View {
    let host: Host
    let deleteAction: (Host) -> Void
    
    var body: some View {
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
        .contextMenu {
            Button(role: .destructive, action: {
                deleteAction(host)
            }) {
                Label("Delete", systemImage: "trash")
            }
            .keyboardShortcut("d", modifiers: [.command])
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: {
                deleteAction(host)
            }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Host List View
struct HostListView: View {
    @Binding var selectedHost: Host?
    let hosts: [Host]
    let addHostAction: () -> Void
    let deleteAction: (Host) -> Void
    
    var body: some View {
        List(selection: $selectedHost) {
            Section(header: Text("Hosts")) {
                ForEach(hosts) { host in
                    HostRowView(host: host, deleteAction: deleteAction)
                        .tag(host)
                }
            }
        }
        .contextMenu {
            Button(action: addHostAction) {
                Label("Add Host", systemImage: "plus")
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Previews
#Preview("Host List") {
    HostListView(
        selectedHost: .constant(nil),
        hosts: [
            Host(name: "Production Server", hostname: "prod.example.com", username: "admin", port: 22),
            Host(name: "Development Server", hostname: "dev.example.com", username: "developer", port: 22)
        ],
        addHostAction: {},
        deleteAction: { _ in }
    )
}

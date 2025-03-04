import SwiftUI

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
            Button(
                role: .destructive,
                action: {
                    deleteAction(host)
                }
            ) {
                Label("Delete", systemImage: "trash")
            }
            .keyboardShortcut("d", modifiers: [.command])
        }
        .swipeActions(edge: .trailing) {
            Button(
                role: .destructive,
                action: {
                    deleteAction(host)
                }
            ) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    List {
        Section(header: Text("Hosts")) {
            HostRowView(
                host: Host(name: "Production Server", hostname: "prod.example.com", username: "admin", port: 22),
                deleteAction: { _ in }
            )
            HostRowView(
                host: Host(name: "Development Server", hostname: "dev.example.com", username: "developer", port: 22),
                deleteAction: { _ in }
            )
        }
    }
}

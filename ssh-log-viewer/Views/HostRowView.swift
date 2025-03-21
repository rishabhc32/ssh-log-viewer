import SwiftUI

struct HostRowView: View {
    let host: Host
    let deleteAction: (Host) -> Void

    var body: some View {
        HStack {
            Image(systemName: "server.rack")
                .foregroundColor(.primary)  // This will adapt to selection state
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.secondary.opacity(0.2))  // Subtle background that works in both states
                )

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
                host: Host(name: "Production Server", hostname: "prod.example.com", username: "admin", password: "test", port: 22),
                deleteAction: { _ in }
            )
            HostRowView(
                host: Host(name: "Development Server", hostname: "dev.example.com", username: "developer", password: "test", port: 22),
                deleteAction: { _ in }
            )
        }
    }
}

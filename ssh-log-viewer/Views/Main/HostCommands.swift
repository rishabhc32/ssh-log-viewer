import SwiftUI

struct HostActions {
    let add: () -> Void
    let delete: () -> Void
}

struct HostActionsKey: FocusedValueKey {
    typealias Value = HostActions
}

extension FocusedValues {
    var hostActions: HostActions? {
        get { self[HostActionsKey.self] }
        set { self[HostActionsKey.self] = newValue }
    }
}

struct HostCommands: Commands {
    @FocusedValue(\.hostActions) var hostActions

    var body: some Commands {
        CommandMenu("Hosts") {
            Button("Add Host") {
                hostActions?.add()
            }
            .keyboardShortcut("n", modifiers: [.command, .shift])

            Divider()

            Button("Delete Host") {
                hostActions?.delete()
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(hostActions == nil)
        }
    }
}

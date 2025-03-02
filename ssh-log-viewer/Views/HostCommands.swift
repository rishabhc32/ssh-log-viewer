//
//  AddHostCommands.swift
//  ssh-log-viewer
//
//  Created by RC on 03/03/25.
//
import SwiftUI

struct HostCommands: Commands {
    @FocusedValue(\.addHostAction) var addHostAction
    @FocusedValue(\.deleteHostAction) var deleteHostAction

    var body: some Commands {
        CommandMenu("Hosts") {
            Button("Add Host") {
                addHostAction?()
            }
            .keyboardShortcut("n", modifiers: .command)
            
            Divider()
            
            Button("Delete Host") {
                deleteHostAction?()
            }
            .keyboardShortcut("d", modifiers: .command)
            .disabled(deleteHostAction == nil)
        }
    }
}

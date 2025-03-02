import SwiftUI
import Observation

struct AddHostView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: HostViewModel
    
    @State private var name: String = ""
    @State private var hostname: String = ""
    @State private var username: String = ""
    @State private var port: String = "22"
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Host Details")) {
                    TextField("Name", text: $name)
                    TextField("Hostname", text: $hostname)
                    TextField("Username", text: $username)
                    TextField("Port", text: $port)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Add") {
                    let portNumber = Int(port) ?? 22
                    viewModel.addHost(name: name, hostname: hostname, username: username, port: portNumber)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty || hostname.isEmpty || username.isEmpty)
            }
            .padding()
        }
        .frame(width: 400, height: 300)
        .padding()
    }
}

#Preview {
    AddHostView(viewModel: HostViewModel())
}

import SwiftUI

struct EmptyStateView: View {
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "server.rack")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No Hosts Available")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Add a host to get started with SSH Log Viewer")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer(minLength: 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.top)
    }
}

#Preview {
    EmptyStateView()
}

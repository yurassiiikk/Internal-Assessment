import SwiftUI
import NetworkExtension

struct ContentView: View {
    @State private var isConnected = false
    @State private var selectedServer: VPNServer?
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var vpnManager: VPNProtocolManager
    
    var body: some View {
        if userManager.currentUser == nil {
            AuthView()
        } else {
            VStack {
                Text("VPN Connection")
                    .font(.largeTitle)
                    .padding()
                
                Picker("Select Server", selection: $selectedServer) {
                    ForEach(vpnManager.servers, id: \.self) { server in
                        Text(server.name).tag(server)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                Button(action: {
                    if let server = selectedServer {
                        vpnManager.connect(to: server)
                        isConnected.toggle()
                    }
                }) {
                    Text(isConnected ? "Disconnect" : "Connect")
                        .font(.title2)
                        .padding()
                        .frame(width: 200)
                        .background(isConnected ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink("Speed Test", destination: SpeedTestView())
                    .padding()
            }
            .frame(width: 300, height: 350)
        }
    }
}


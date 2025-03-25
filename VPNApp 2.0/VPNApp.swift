import SwiftUI

@main
struct VPNApp: App {
    @StateObject var userManager = UserManager()
    @StateObject var vpnManager = VPNProtocolManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
                .environmentObject(vpnManager)
        }
    }
}

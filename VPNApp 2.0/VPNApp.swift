import SwiftUI

@main
struct VPNApp: App {
    @StateObject var userManager = UserManager()
    @StateObject var vpnManager = VPNProtocolManager()
    @State private var showOnboarding = UserDefaults.standard.bool(forKey: "hasLaunchedBefore") ? false : true

    var body: some Scene {
        WindowGroup {
            if showOnboarding {
                OnboardingView(showOnboarding: $showOnboarding)
                    .onDisappear {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                    }
            } else {
                ContentView()
                    .environmentObject(userManager)
                    .environmentObject(vpnManager)
            }
        }
    }
}

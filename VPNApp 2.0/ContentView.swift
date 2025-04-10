import SwiftUI
import NetworkExtension

struct ContentView: View {
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var vpnManager: VPNProtocolManager
    @State private var selectedServer: VPNServer?
    @State private var speedTestResult: String = ""
    @State private var isShowingSettings = false
    @State private var showServerSheet = false
    @State private var connectionProgress: CGFloat = 0.0
    
    private var connectionStatusColor: Color {
        if vpnManager.isConnected {
            return .accentGreen
        } else {
            return .accentRed
        }
    }
    
    var body: some View {
        if userManager.currentUser == nil {
            AuthView()
        } else {
            ZStack {
                // Background
                Color.darkBackground.ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Custom navigation bar
                    HStack {
                        Text("Vire VPN")
                            .font(.titleMedium)
                            .foregroundColor(.textPrimary)
                        
                        Spacer()
                        
                        Button(action: {
                            isShowingSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                                .font(.system(size: 20))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Connection status card
                            ConnectionStatusCard(
                                isConnected: vpnManager.isConnected,
                                serverName: selectedServer?.name ?? "Not Selected",
                                connectionProgress: $connectionProgress
                            )
                            .padding(.top, 10)
                            
                            // Server selection card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Server Location")
                                    .font(.titleSmall)
                                    .foregroundColor(.textPrimary)
                                
                                Button(action: {
                                    showServerSheet = true
                                }) {
                                    HStack {
                                        if let server = selectedServer {
                                            HStack {
                                                ServerFlagImage(countryName: server.name)
                                                    .frame(width: 30, height: 30)
                                                
                                                Text(server.name)
                                                    .font(.bodyLarge)
                                                    .foregroundColor(.textPrimary)
                                            }
                                        } else {
                                            Text("Select a server")
                                                .font(.bodyLarge)
                                                .foregroundColor(.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.bodyMedium)
                                            .foregroundColor(.textSecondary)
                                    }
                                    .padding()
                                    .background(Color.cardBackground)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal)
                            
                            // Connect button
                            ConnectButton(
                                isConnected: vpnManager.isConnected,
                                selectedServer: selectedServer,
                                action: {
                                    if vpnManager.isConnected {
                                        withAnimation {
                                            connectionProgress = 0
                                            vpnManager.disconnect()
                                        }
                                    } else if let server = selectedServer {
                                        withAnimation {
                                            connectionProgress = 0
                                            startConnectionAnimation()
                                            vpnManager.connect(to: server)
                                        }
                                    }
                                }
                            )
                            .disabled(selectedServer == nil && !vpnManager.isConnected)
                            .padding(.horizontal)
                            
                            // Speed test card
                            SpeedTestCard(speedTestResult: $speedTestResult) {
                                speedTestResult = "Testing..."
                                vpnManager.testSpeed { speed in
                                    if let speed = speed {
                                        speedTestResult = String(format: "%.2f Mbps", speed)
                                    } else {
                                        speedTestResult = "Test failed"
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Stats card
                            if vpnManager.isConnected {
                                VPNStatsCard(
                                    connectedTime: "02:34:17",
                                    dataUsed: "1.2 GB",
                                    ip: "192.168.1.1"
                                )
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.bottom, 30)
                    }
                }
                
                // Server selection sheet
                if showServerSheet {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showServerSheet = false
                            }
                        }
                    
                    ServerSelectionSheet(
                        servers: vpnManager.servers,
                        selectedServer: $selectedServer,
                        isShowing: $showServerSheet
                    )
                    .transition(.move(edge: .bottom))
                }
                
                // Settings sheet
                if isShowingSettings {
                    SettingsView(isShowing: $isShowingSettings)
                        .transition(.move(edge: .trailing))
                }
            }
            .animation(.spring(), value: vpnManager.isConnected)
            .animation(.spring(), value: selectedServer)
            .sheet(isPresented: $showServerSheet) {
                ServerSelectionSheet(
                    servers: vpnManager.servers,
                    selectedServer: $selectedServer,
                    isShowing: $showServerSheet
                )
            }
        }
    }
    
    private func startConnectionAnimation() {
        withAnimation(Animation.easeInOut(duration: 2)) {
            connectionProgress = 1.0
        }
    }
}

// Connection Status Card Component
struct ConnectionStatusCard: View {
    let isConnected: Bool
    let serverName: String
    @Binding var connectionProgress: CGFloat
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.cardBackground, lineWidth: 20)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: connectionProgress)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [isConnected ? .accentGreen : .primaryBlue, isConnected ? .accentGreen.opacity(0.7) : .secondaryPurple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: connectionProgress)
                
                // Status icon and text
                VStack(spacing: 10) {
                    Image(systemName: isConnected ? "shield.fill" : "shield.slash")
                        .font(.system(size: 40))
                        .foregroundColor(isConnected ? .accentGreen : .accentRed)
                    
                    Text(isConnected ? "Connected" : "Disconnected")
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)
                    
                    if isConnected {
                        Text(serverName)
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.cardBackground)
        )
        .padding(.horizontal)
    }
}

// Connect Button Component
struct ConnectButton: View {
    let isConnected: Bool
    let selectedServer: VPNServer?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                
                Text(isConnected ? "Disconnect" : "Connect")
                    .font(.titleSmall)
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.vertical, 18)
            .background(
                Group {
                    if isConnected {
                        LinearGradient(
                            gradient: Gradient(colors: [.accentRed, .accentRed.opacity(0.7)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else if selectedServer != nil {
                        LinearGradient(
                            gradient: Gradient(colors: [.primaryBlue, .secondaryPurple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(16)
            .shadow(color: isConnected ? .accentRed.opacity(0.5) : .primaryBlue.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

// Speed Test Card Component
struct SpeedTestCard: View {
    @Binding var speedTestResult: String
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Speed Test")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "speedometer")
                            .font(.system(size: 18))
                            .foregroundColor(.primaryBlue)
                            .rotationEffect(.degrees(isAnimating ? 30 : -30))
                            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating)
                        
                        Text("Current Speed")
                            .font(.bodyMedium)
                            .foregroundColor(.textSecondary)
                    }
                    
                    Text(speedTestResult.isEmpty ? "Not tested" : speedTestResult)
                        .font(.titleSmall)
                        .foregroundColor(.textPrimary)
                }
                
                Spacer()
                
                Button(action: action) {
                    Text("Test")
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.primaryBlue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
        .onAppear {
            isAnimating = true
        }
    }
}

// VPN Stats Card Component
struct VPNStatsCard: View {
    let connectedTime: String
    let dataUsed: String
    let ip: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Connection Statistics")
                .font(.titleSmall)
                .foregroundColor(.textPrimary)
            
            VStack(spacing: 16) {
                StatRow(icon: "clock.fill", title: "Connected Time", value: connectedTime)
                StatRow(icon: "arrow.up.arrow.down", title: "Data Used", value: dataUsed)
                StatRow(icon: "network", title: "IP Address", value: ip)
            }
        }
        .padding()
        .background(Color.cardBackground)
        .cornerRadius(16)
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.primaryBlue)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.bodyMedium)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
        }
    }
}

// Server Selection Sheet
struct ServerSelectionSheet: View {
    let servers: [VPNServer]
    @Binding var selectedServer: VPNServer?
    @Binding var isShowing: Bool
    @State private var searchText = ""
    
    var filteredServers: [VPNServer] {
        if searchText.isEmpty {
            return servers
        } else {
            return servers.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle for drag to dismiss
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.6))
                .frame(width: 40, height: 5)
                .padding(.vertical, 10)
            
            Text("Select Server")
                .font(.titleMedium)
                .padding(.vertical, 10)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.textSecondary)
                
                TextField("Search countries", text: $searchText)
                    .foregroundColor(.textPrimary)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .padding()
            .background(Color.cardBackground)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Server list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredServers) { server in
                        ServerRow(
                            server: server,
                            isSelected: selectedServer?.id == server.id,
                            action: {
                                selectedServer = server
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Cancel button
            Button(action: {
                withAnimation {
                    isShowing = false
                }
            }) {
                Text("Cancel")
                    .font(.bodyLarge)
                    .foregroundColor(.textSecondary)
                    .padding(.vertical, 16)
            }
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.darkBackground)
                .edgesIgnoringSafeArea(.bottom)
        )
        .animation(.spring(), value: isShowing)
    }
}

// Server Row Component
struct ServerRow: View {
    let server: VPNServer
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ServerFlagImage(countryName: server.name)
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
                Text(server.name)
                    .font(.bodyLarge)
                    .foregroundColor(.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentGreen)
                }
            }
            .padding()
            .background(isSelected ? Color.cardBackground.opacity(0.7) : Color.clear)
            .cornerRadius(12)
        }
    }
}

// Server Flag Image
struct ServerFlagImage: View {
    let countryName: String
    
    var flagEmoji: String {
        switch countryName {
        case "United States":
            return "🇺🇸"
        case "Canada":
            return "🇨🇦"
        case "Germany":
            return "🇩🇪"
        case "France":
            return "🇫🇷"
        case "United Kingdom":
            return "🇬🇧"
        case "Netherlands":
            return "🇳🇱"
        case "Brazil":
            return "🇧🇷"
        case "India":
            return "🇮🇳"
        case "Singapore":
            return "🇸🇬"
        case "Japan":
            return "🇯🇵"
        case "Australia":
            return "🇦🇺"
        case "South Korea":
            return "🇰🇷"
        case "Spain":
            return "🇪🇸"
        case "Italy":
            return "🇮🇹"
        case "Russia":
            return "🇷🇺"
        default:
            return "🌐"
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.cardBackground)
            
            Text(flagEmoji)
                .font(.system(size: 18))
        }
    }
}

// Settings View
struct SettingsView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject var userManager: UserManager
    @State private var showConfirmLogout = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            HStack {
                Spacer()
                
                VStack {
                    // Close button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isShowing = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textSecondary)
                                .padding(8)
                                .background(Color.cardBackground)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    // Settings content
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Settings")
                            .font(.titleMedium)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            SettingsRow(icon: "person.fill", title: "Account", hasToggle: false)
                            SettingsRow(icon: "bell.fill", title: "Notifications", hasToggle: true)
                            SettingsRow(icon: "lock.fill", title: "Privacy", hasToggle: false)
                            SettingsRow(icon: "gear", title: "General", hasToggle: false)
                            SettingsRow(icon: "info.circle.fill", title: "About", hasToggle: false)
                        }
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Button(action: {
                            showConfirmLogout = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .foregroundColor(.accentRed)
                                
                                Text("Log Out")
                                    .foregroundColor(.accentRed)
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .padding(.top)
                }
                .background(Color.darkBackground)
                .edgesIgnoringSafeArea(.vertical)
            }
            .alert(isPresented: $showConfirmLogout) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        userManager.currentUser = nil
                        withAnimation {
                            isShowing = false
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

// Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let hasToggle: Bool
    @State private var isToggled = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
            
            Spacer()
            
            if hasToggle {
                Toggle("", isOn: $isToggled)
                    .labelsHidden()
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding()
        .background(Color.cardBackground)
    }
}


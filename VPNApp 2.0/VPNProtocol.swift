// VPNProtocol.swift
import Foundation
import NetworkExtension
import Combine
import SwiftUI

struct VPNServer: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var uri: String
}

class VPNProtocolManager: ObservableObject {
    @Published var servers: [VPNServer] = [
        VPNServer(name: "US Server", uri: "vpn://us.server.com"),
        VPNServer(name: "EU Server", uri: "vpn://eu.server.com"),
        VPNServer(name: "Asia Server", uri: "vpn://asia.server.com")
    ]
    
    @Published var isConnected: Bool = false
    @Published var currentServer: VPNServer?
    @Published var downloadSpeed: Double? // Speed in Mbps
    private var vpnManager = NEVPNManager.shared()
    
    init() {
        setupVPN()
    }
    
    private func setupVPN() {
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Failed to load VPN preferences: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func connect(to server: VPNServer) {
        print("Connecting to: \(server.uri)")
        currentServer = server
        isConnected = true
        
        let vpnConfig = NEVPNProtocolIKEv2()
        vpnConfig.serverAddress = server.uri
        vpnConfig.username = "yourUsername" // Set dynamically if needed
        vpnConfig.passwordReference = retrievePassword() // Secure storage
        vpnConfig.authenticationMethod = .none
        vpnConfig.useExtendedAuthentication = true
        vpnConfig.disconnectOnSleep = false
        
        vpnManager.protocolConfiguration = vpnConfig
        vpnManager.isEnabled = true
        
        vpnManager.saveToPreferences { error in
            if let error = error {
                print("Failed to save VPN preferences: \(error.localizedDescription)")
                return
            }
            do {
                try self.vpnManager.connection.startVPNTunnel()
            } catch {
                print("VPN Connection failed: \(error.localizedDescription)")
            }
        }
    }
    
    func disconnect() {
        print("Disconnecting from: \(currentServer?.uri ?? "Unknown")")
        vpnManager.connection.stopVPNTunnel()
        currentServer = nil
        isConnected = false
    }
    
    private func retrievePassword() -> Data? {
        // Implement keychain storage for password reference
        return nil
    }
    
    func testSpeed() {
        guard let url = URL(string: "https://speed.hetzner.de/100MB.bin") else { return }
        
        let startTime = Date()
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Speed test failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            let elapsedTime = Date().timeIntervalSince(startTime)
            let speedMbps = (Double(data.count) * 8) / (elapsedTime * 1_000_000) // Convert to Mbps
            
            DispatchQueue.main.async {
                self.downloadSpeed = speedMbps
                print("Download Speed: \(speedMbps) Mbps")
            }
        }
        task.resume()
    }
}

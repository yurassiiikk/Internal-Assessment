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
        VPNServer(name: "United States", uri: "vless://71ed6628-5870-4d19-8a52-f2a3ba3d4898@69.84.182.1:443?security=tls&sni=vbbc.ylks2024.us.kg&type=ws&host=vbbc.ylks2024.us.kg&path=/youlingkaishi#"),
        VPNServer(name: "Canada", uri: "vless://51d3d249-9095-4cbd-8fd2-3e6c1039cab4@172.67.180.238:8880?security=none&type=ws&host=falcunargo.c2259d7c10.workers.dev&path=%2F%3Fed%3D2048#"),
        VPNServer(name: "Germany", uri: "vless://64a1796c-95f8-40e4-9a56-825823212648@185.235.243.133:443?security=tls&sni=tr-s.xor-vpn.ru&type=tcp#"),
        VPNServer(name: "France", uri: "vless://568279ce-dd78-4f33-9e5c-64b18c5505db@151.101.123.73:80?security=none&type=ws&host=foffmelo.com&path=%2Folem%2Fws%3Fed%3D2560#"),
        VPNServer(name: "United Kingdom", uri: "vless://d6660712-4d18-47fd-b095-0c36db667250@162.159.192.14:443?security=tls&sni=xxx.66500-280b-471c-b2b8-d68b7f9960011.workers.dev&type=ws&host=xxx.66500-280b-471c-b2b8-d68b7f9960011.workers.dev&path=%2F%3Fed%3D2048&fp=chrome&alpn=h3%2Ch2#"),
        VPNServer(name: "Netherlands", uri: "vless://568279ce-dd78-4f33-9e5c-64b18c5505db@151.101.123.7:80?security=none&type=ws&host=foffmelo.com&path=%2Folem%2Fws%3Fed%3D2560#"),
        VPNServer(name: "Brazil", uri: "vless://17272b75-51c8-4999-a4ce-b3bd8679e04e@104.16.12.75:443?security=tls&sni=liu133.us.kg&type=ws&host=liu133.us.kg&allowInsecure=1#"),
        VPNServer(name: "India", uri: "vless://1325fc61-3723-4591-90cb-b66d9a079aad@146.75.106.133:80?security=none&type=xhttp&host=joinbede_unlimiteddev.ir&path=/@UnlimitedDev----@UnlimitedDev-----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev----@UnlimitedDev?ed%3D2480#"),
        VPNServer(name: "Singapore", uri: "vless://53fa8faf-ba4b-4322-9c69-a3e5b1555049@45.131.4.247:80?security=none&type=ws&host=301.pooriam.ir&path=Telegram%F0%9F%87%A8%F0%9F%87%B3%20%40WangCai2#"),
        VPNServer(name: "Japan", uri: "vless://77f806f0-8f87-4c01-8e07-c88d52092e92@172.67.150.87:443?security=tls&sni=cs2.film2serial.cloud&type=grpc&serviceName=6k9LhPdmkFyy7eL4dZlhBC&fp=chrome&alpn=h2#"),
        VPNServer(name: "Australia", uri: "vless://df0680ca-e43c-498d-ed86-8e196eedd012@84.32.9.104:8880?security=none&type=grpc#"),
        VPNServer(name: "South Korea", uri: "vless://06e4425e-a8cb-4b63-929f-2105604ab0a9@108.162.195.83:443?security=tls&sni=il.ylkszy.eu.org&type=ws&host=il.ylkszy.eu.org&path=%2F%3Fed%3D2560#"),
        VPNServer(name: "Spain", uri: "vless://96a1b724-68d2-4f4d-ab25-38ecd83577bc@141.193.213.30:2087?security=tls&sni=CiHsFuEf76.nExTvIsIoNaRy.oRg&type=grpc&fp=chrome&alpn=h2"),
        VPNServer(name: "Italy", uri: "vless://80c9743a-d7d8-4a10-b28c-16ae5f75a077@138.199.216.129:6666?security=none"),
        VPNServer(name: "Russia", uri: "vless://55520747-311e-4015-83ce-be46e2060ce3@45.67.215.174:443?security=tls&sni=re.vs2024.us.kg&type=ws&path=%2F%3Fed#")
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

    func testSpeed(completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: "https://speed.hetzner.de/5MB.bin") else {
            completion(nil)
            return
        }

        let startTime = Date()

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 15

        let session = URLSession(configuration: config)
        let task = session.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Speed test failed: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let elapsedTime = Date().timeIntervalSince(startTime)
            let bitsDownloaded = Double(data.count) * 8
            let speedMbps = bitsDownloaded / (elapsedTime * 1_000_000)

            DispatchQueue.main.async {
                self.downloadSpeed = speedMbps
                completion(speedMbps)
            }
        }

        task.resume()
    }
}

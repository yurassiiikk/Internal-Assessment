import Foundation
import Network

class SpeedTester: ObservableObject {
    @Published var downloadSpeed: Double = 0.0
    @Published var uploadSpeed: Double = 0.0
    @Published var ping: Double = 0.0
    
    func startTest() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.ping = Double.random(in: 10...100) // Simulate ping
                self.downloadSpeed = Double.random(in: 10...100) // Simulate Mbps
                self.uploadSpeed = Double.random(in: 5...50) // Simulate Mbps
            }
        }
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
}


import SwiftUI

struct SpeedTestView: View {
    @ObservedObject var tester = SpeedTester()
    
    var body: some View {
        VStack {
            Text("Speed Test")
                .font(.largeTitle)
                .padding()
            
            Button("Start Test") {
                tester.startTest()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("Ping: \(tester.ping, specifier: "%.2f") ms")
            Text("Download: \(tester.downloadSpeed, specifier: "%.2f") Mbps")
            Text("Upload: \(tester.uploadSpeed, specifier: "%.2f") Mbps")
        }
        .padding()
    }
}

import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.primaryBlue, .secondaryPurple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            ZStack {
                Image(systemName: "shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                    .foregroundColor(.white.opacity(0.15))
                
                // Additional shield and logo components
            }
        }
        .frame(width: 1024, height: 1024)
        .cornerRadius(220)
    }
}

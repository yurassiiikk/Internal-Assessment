import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var showOnboarding: Bool
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage(
                    title: "Welcome to V VPN",
                    description: "The most secure and reliable VPN service for all your devices",
                    imageName: "shield.lefthalf.filled",
                    backgroundColor: .primaryBlue
                )
                .tag(0)
                
                OnboardingPage(
                    title: "Secure Connection",
                    description: "Protect your data with military-grade encryption and secure protocols",
                    imageName: "lock.shield",
                    backgroundColor: .secondaryPurple
                )
                .tag(1)
                
                OnboardingPage(
                    title: "Global Servers",
                    description: "Connect to servers in over 15 countries for the best possible experience",
                    imageName: "network",
                    backgroundColor: .accentGreen
                )
                .tag(2)
                
                OnboardingPage(
                    title: "Speed Test",
                    description: "Check your connection speed to ensure optimal performance",
                    imageName: "speedometer",
                    backgroundColor: .accentRed
                )
                .tag(3)
            }
            
            // Skip and Continue buttons
            VStack {
                Spacer()
                
                HStack {
                    if currentPage < 3 {
                        Button(action: {
                            showOnboarding = false
                        }) {
                            Text("Skip")
                                .font(.bodyLarge)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentPage < 3 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            showOnboarding = false
                        }
                    }) {
                        Text(currentPage < 3 ? "Continue" : "Get Started")
                            .font(.bodyLarge)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color.primaryBlue)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingPage: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(backgroundColor)
                .background(
                    Circle()
                        .fill(backgroundColor.opacity(0.2))
                        .frame(width: 220, height: 220)
                )
                .padding(.bottom, 40)
            
            Text(title)
                .font(.titleLarge)
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text(description)
                .font(.bodyLarge)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

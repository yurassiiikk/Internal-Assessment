import SwiftUI

struct AuthView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage = ""
    @State private var isAnimating = false
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        ZStack {
            // Animated background
            BackgroundAnimationView()
            
            VStack(spacing: 25) {
                // Logo and title
                VStack(spacing: 10) {
                    Image(systemName: "shield.lefthalf.filled")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.primaryBlue)
                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                        .animation(Animation.linear(duration: 20).repeatForever(autoreverses: false), value: isAnimating)
                    
                    Text("Vire")
                        .font(.titleLarge)
                        .foregroundColor(.textPrimary)
                    
                    Text(isRegistering ? "Create Account" : "Welcome Back")
                        .font(.titleSmall)
                        .foregroundColor(.textSecondary)
                }
                .padding(.bottom, 20)
                
                // Form fields with glassmorphism effect
                VStack(spacing: 20) {
                    CustomTextField(
                        placeholder: "Username",
                        text: $username,
                        icon: "person.fill"
                    )
                    
                    CustomSecureField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock.fill"
                    )
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(errorMessage.contains("successful") ? .accentGreen : .accentRed)
                            .padding(.horizontal)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 30)
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            authenticateUser()
                        }
                    }) {
                        Text(isRegistering ? "Create Account" : "Sign In")
                            .font(.titleSmall)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.primaryBlue, .secondaryPurple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .primaryBlue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isRegistering.toggle()
                            errorMessage = ""
                        }
                    }) {
                        Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Create one")
                            .font(.bodyMedium)
                            .foregroundColor(.primaryBlue)
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
            }
            .padding(.vertical, 40)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func authenticateUser() {
        if isRegistering {
            if userManager.register(username: username, password: password) {
                errorMessage = "Account created successfully!"
                // Automatically switch to login after successful registration
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation {
                        isRegistering = false
                        errorMessage = ""
                    }
                }
            } else {
                errorMessage = "Username already exists."
            }
        } else {
            if userManager.login(username: username, password: password) {
                errorMessage = "Login successful!"
            } else {
                errorMessage = "Invalid credentials."
            }
        }
    }
}

// Custom TextField with icon
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
                .padding(.leading, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.cardBackground.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [.primaryBlue.opacity(0.4), .secondaryPurple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// Custom SecureField with icon
struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 20)
            
            SecureField(placeholder, text: $text)
                .font(.bodyLarge)
                .foregroundColor(.textPrimary)
                .padding(.leading, 8)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.cardBackground.opacity(0.8))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LinearGradient(
                    gradient: Gradient(colors: [.primaryBlue.opacity(0.4), .secondaryPurple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

// Animated background with particles
struct BackgroundAnimationView: View {
    @State private var phase = 0.0
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            // Circle gradients in background
            GeometryReader { geometry in
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.primaryBlue.opacity(0.4), .secondaryPurple.opacity(0.1)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
                        .blur(radius: 80)
                    
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.secondaryPurple.opacity(0.4), .accentGreen.opacity(0.1)]),
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ))
                        .frame(width: geometry.size.width * 0.8)
                        .offset(x: geometry.size.width * 0.3, y: geometry.size.height * 0.3)
                        .blur(radius: 80)
                }
                .offset(x: CGFloat(sin(phase)) * 10, y: CGFloat(cos(phase)) * 10)
                .animation(Animation.easeInOut(duration: 20).repeatForever(autoreverses: true), value: phase)
            }
        }
        .onAppear {
            phase = Double.random(in: 0...2 * .pi)
        }
    }
}

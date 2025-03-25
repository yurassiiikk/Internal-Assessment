import SwiftUI

struct AuthView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage = ""
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        VStack {
            Text(isRegistering ? "Register" : "Login")
                .font(.largeTitle)
                .padding()
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                if isRegistering {
                    if userManager.register(username: username, password: password) {
                        errorMessage = "Registration successful!"
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
            }) {
                Text(isRegistering ? "Register" : "Login")
                    .font(.title2)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                isRegistering.toggle()
                errorMessage = ""
            }) {
                Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}


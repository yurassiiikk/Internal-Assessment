import Foundation
import Combine

class UserManager: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUser: User? = nil
    
    let userDefaultsKey = "registeredUsers"
    
    init() {
        loadUsers()
    }
    
    func register(username: String, password: String) -> Bool {
        if users.contains(where: { $0.username == username }) {
            return false // User already exists
        }
        let newUser = User(username: username, password: password)
        users.append(newUser)
        saveUsers()
        return true
    }
    
    func login(username: String, password: String) -> Bool {
        if let user = users.first(where: { $0.username == username && $0.password == password }) {
            currentUser = user
            return true
        }
        return false
    }
    
    private func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUsers() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedUsers = try? JSONDecoder().decode([User].self, from: savedData) {
            users = decodedUsers
        }
    }
}

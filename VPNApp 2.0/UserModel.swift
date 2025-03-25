import Foundation

struct User: Codable, Identifiable {
    var id = UUID()
    var username: String
    var password: String
}

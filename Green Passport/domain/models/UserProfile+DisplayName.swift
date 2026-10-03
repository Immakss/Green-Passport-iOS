import Foundation

extension UserProfile {
    var displayName: String? {
        let name = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? nil : name
    }
}

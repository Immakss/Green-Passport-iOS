import Foundation

final class UserDefaultsSavedMapPointsRepository: SavedMapPointsRepository {
    private static let savedIdsKey = "saved_map_point_ids"
    private static let separator = ","

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var savedPointIds: Set<String> {
        let raw = defaults.string(forKey: Self.savedIdsKey) ?? ""
        return Set(raw.components(separatedBy: Self.separator).filter { !$0.isEmpty })
    }

    func setSaved(pointId: String, isSaved: Bool) {
        var ids = savedPointIds
        if isSaved {
            ids.insert(pointId)
        } else {
            ids.remove(pointId)
        }
        defaults.set(ids.sorted().joined(separator: Self.separator), forKey: Self.savedIdsKey)
    }
}

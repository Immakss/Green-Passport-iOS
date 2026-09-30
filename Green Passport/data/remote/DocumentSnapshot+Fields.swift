import FirebaseFirestore
import Foundation

extension DocumentSnapshot {
    func string(_ field: String) -> String? {
        return get(field) as? String
    }

    func int(_ field: String) -> Int? {
        return (get(field) as? NSNumber)?.intValue
    }

    func millis(_ field: String) -> Int64? {
        return (get(field) as? NSNumber)?.int64Value
    }

    func date(_ field: String) -> Date? {
        return millis(field).map(EpochMillis.date(from:))
    }

    func bool(_ field: String) -> Bool? {
        return get(field) as? Bool
    }

    func strings(_ field: String) -> [String] {
        return get(field) as? [String] ?? []
    }
}

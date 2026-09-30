nonisolated enum ReportReason: String, CaseIterable, Hashable, Sendable {
    case offensive = "OFFENSIVE"
    case spam = "SPAM"
    case inappropriateImage = "INAPPROPRIATE_IMAGE"
    case other = "OTHER"
}

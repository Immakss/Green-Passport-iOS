extension EcoTask {
    private static let placeholderTitle = "Placeholder task title"
    private static let placeholderCity = "Placeholder"
    private static let placeholderPoints = 50

    static func placeholders(count: Int) -> [EcoTask] {
        return (0..<count).map { index in
            return EcoTask(
                id: "placeholder-\(index)",
                title: placeholderTitle,
                description: "",
                category: .recycling,
                city: placeholderCity,
                rewardPoints: placeholderPoints,
                rewardXp: placeholderPoints,
                imageUrl: nil,
                verification: .selfReported
            )
        }
    }
}

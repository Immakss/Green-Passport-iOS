final class IsTextAllowedUseCase {
    private let textModerator: TextModerator

    init(textModerator: TextModerator) {
        self.textModerator = textModerator
    }

    func execute(text: String) -> Bool {
        return textModerator.isAllowed(text)
    }
}

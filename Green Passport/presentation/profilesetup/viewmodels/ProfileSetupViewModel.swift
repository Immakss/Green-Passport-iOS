import Foundation
import Observation

@Observable
final class ProfileSetupViewModel {
    private static let nameLengthRange = 2...30
    private static let namePattern = /^[\p{L}][\p{L} \-]*$/

    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let saveUserProfile: SaveUserProfileUseCase
    @ObservationIgnored private let isTextAllowed: IsTextAllowedUseCase
    @ObservationIgnored private let signOut: SignOutUseCase

    private(set) var uiState = ProfileSetupUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        saveUserProfile: SaveUserProfileUseCase,
        isTextAllowed: IsTextAllowedUseCase,
        signOut: SignOutUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.saveUserProfile = saveUserProfile
        self.isTextAllowed = isTextAllowed
        self.signOut = signOut
    }

    func observe() async {
        for await session in observeSession.execute() {
            guard let session else {
                continue
            }
            await prefill(session: session)
        }
    }

    func handle(_ action: ProfileSetupUserAction) {
        switch action {
        case .firstNameChanged(let value):
            uiState.firstName = value
            uiState.firstNameError = nil
        case .lastNameChanged(let value):
            uiState.lastName = value
            uiState.lastNameError = nil
        case .citySelected(let city):
            uiState.city = city
            uiState.isCityMissing = false
        case .interestToggled(let category):
            if uiState.interests.contains(category) {
                uiState.interests.remove(category)
            } else {
                uiState.interests.insert(category)
            }
            uiState.isInterestsMissing = false
        case .avatarSelected(let avatar):
            uiState.avatar = avatar
        case .back:
            if let previous = ProfileSetupStep(rawValue: uiState.step.rawValue - 1) {
                uiState.step = previous
            }
        case .next:
            next()
        case .signOut:
            try? signOut.execute()
        }
    }

    private func next() {
        guard !uiState.isSaving, isCurrentStepValid() else {
            return
        }
        if let following = ProfileSetupStep(rawValue: uiState.step.rawValue + 1) {
            uiState.step = following
        } else {
            save()
        }
    }

    private func isCurrentStepValid() -> Bool {
        switch uiState.step {
        case .name:
            uiState.firstNameError = validateName(uiState.firstName)
            uiState.lastNameError = validateName(uiState.lastName)
            return uiState.firstNameError == nil && uiState.lastNameError == nil
        case .city:
            uiState.isCityMissing = uiState.city == nil
            return uiState.city != nil
        case .interests:
            uiState.isInterestsMissing = uiState.interests.isEmpty
            return !uiState.interests.isEmpty
        case .avatar:
            return true
        }
    }

    private func validateName(_ name: String) -> NameError? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if !Self.nameLengthRange.contains(trimmed.count) {
            return .length
        }
        if trimmed.wholeMatch(of: Self.namePattern) == nil {
            return .characters
        }
        if !isTextAllowed.execute(text: trimmed) {
            return .inappropriate
        }
        return nil
    }

    private func save() {
        guard let userId = uiState.userId, let city = uiState.city else {
            return
        }
        let profile = UserProfile(
            userId: userId,
            firstName: uiState.firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: uiState.lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            city: city,
            interests: uiState.interests,
            avatar: uiState.avatar
        )
        uiState.isSaving = true
        uiState.hasSaveError = false
        Task {
            do {
                try await saveUserProfile.execute(profile: profile)
                uiState.isSaving = false
                uiState.isSaved = true
            } catch is ContentRejectedError {
                uiState.isSaving = false
                uiState.step = .name
                uiState.firstNameError = .inappropriate
            } catch {
                uiState.isSaving = false
                uiState.hasSaveError = true
            }
        }
    }

    private func prefill(session: AuthSession) async {
        if uiState.isPrefilled && uiState.userId == session.userId {
            return
        }
        uiState = ProfileSetupUiState()
        let profile = await firstProfile(userId: session.userId)
        let suggestedNames = (session.displayName ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            .map(String.init)
        uiState.isPrefilled = true
        uiState.userId = session.userId
        if let profile {
            uiState.firstName = profile.firstName
            uiState.lastName = profile.lastName
            uiState.city = profile.city.isEmpty ? nil : profile.city
            uiState.interests = profile.interests
            uiState.avatar = profile.avatar
        } else {
            uiState.firstName = suggestedNames.first ?? ""
            uiState.lastName = suggestedNames.dropFirst().first ?? ""
        }
    }

    private func firstProfile(userId: String) async -> UserProfile? {
        do {
            for try await profile in observeUserProfile.execute(userId: userId) {
                return profile
            }
        } catch {
            return nil
        }
        return nil
    }
}

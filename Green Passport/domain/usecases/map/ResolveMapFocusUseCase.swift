final class ResolveMapFocusUseCase {
    private let locationRepository: LocationRepository
    private let authRepository: AuthRepository
    private let userProfileRepository: UserProfileRepository

    init(
        locationRepository: LocationRepository,
        authRepository: AuthRepository,
        userProfileRepository: UserProfileRepository
    ) {
        self.locationRepository = locationRepository
        self.authRepository = authRepository
        self.userProfileRepository = userProfileRepository
    }

    func execute() async -> MapFocus {
        if let location = await locationRepository.currentLocation() {
            return .userLocation(location)
        }
        return .city(SupportedCities.center(of: await profileCity()))
    }

    private func profileCity() async -> String? {
        var userId: String?
        for await session in authRepository.observeSession() {
            userId = session?.userId
            break
        }
        guard let userId else {
            return nil
        }
        let profile = try? await userProfileRepository.observeProfile(userId: userId).firstValue()
        return profile??.city
    }
}

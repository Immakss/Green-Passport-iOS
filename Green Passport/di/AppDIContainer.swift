import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage

final class AppDIContainer {
    private static let functionsRegion = "europe-central2"

    private lazy var firestore = Firestore.firestore()
    private lazy var auth = Auth.auth()
    private lazy var functions = Functions.functions(region: Self.functionsRegion)
    private lazy var storage = Storage.storage()

    private lazy var textModerator: TextModerator = WordListTextModerator()
    private lazy var authRepository: AuthRepository = FirebaseAuthRepository(
        auth: auth,
        googleSignInProvider: GoogleSignInProvider()
    )
    private lazy var userProfileRepository: UserProfileRepository = FirestoreUserProfileRepository(firestore: firestore)
    private lazy var settingsRepository: SettingsRepository = UserDefaultsSettingsRepository()

    private lazy var observeSessionUseCase = ObserveSessionUseCase(authRepository: authRepository)
    private lazy var observeUserProfileUseCase = ObserveUserProfileUseCase(userProfileRepository: userProfileRepository)
    private lazy var signOutUseCase = SignOutUseCase(authRepository: authRepository)
}

extension AppDIContainer {
    func buildRootViewModel() -> RootViewModel {
        return RootViewModel(
            observeSession: observeSessionUseCase,
            observeUserProfile: observeUserProfileUseCase,
            isOnboardingSeen: IsOnboardingSeenUseCase(settingsRepository: settingsRepository),
            markOnboardingSeen: MarkOnboardingSeenUseCase(settingsRepository: settingsRepository)
        )
    }

    func buildAuthViewModel() -> AuthViewModel {
        return AuthViewModel(
            signInWithEmail: SignInWithEmailUseCase(authRepository: authRepository),
            registerWithEmail: RegisterWithEmailUseCase(authRepository: authRepository),
            signInAnonymously: SignInAnonymouslyUseCase(authRepository: authRepository),
            signInWithGoogle: SignInWithGoogleUseCase(authRepository: authRepository),
            signInWithApple: SignInWithAppleUseCase(authRepository: authRepository)
        )
    }

    func buildProfileSetupViewModel() -> ProfileSetupViewModel {
        return ProfileSetupViewModel(
            observeSession: observeSessionUseCase,
            observeUserProfile: observeUserProfileUseCase,
            saveUserProfile: SaveUserProfileUseCase(
                userProfileRepository: userProfileRepository,
                textModerator: textModerator
            ),
            isTextAllowed: IsTextAllowedUseCase(textModerator: textModerator),
            signOut: signOutUseCase
        )
    }
}

import Observation

@Observable
final class HomeViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let fetchPendingTasks: FetchPendingTasksUseCase
    @ObservationIgnored private let fetchPointsBalance: FetchPointsBalanceUseCase
    @ObservationIgnored private let fetchLevel: FetchLevelUseCase
    @ObservationIgnored private let fetchUpcomingEvent: FetchUpcomingEventUseCase
    @ObservationIgnored private let profileTask = LatestTask()
    @ObservationIgnored private var session: AuthSession?
    @ObservationIgnored private var profile: UserProfile?

    private(set) var uiState = HomeUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        fetchPendingTasks: FetchPendingTasksUseCase,
        fetchPointsBalance: FetchPointsBalanceUseCase,
        fetchLevel: FetchLevelUseCase,
        fetchUpcomingEvent: FetchUpcomingEventUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.fetchPendingTasks = fetchPendingTasks
        self.fetchPointsBalance = fetchPointsBalance
        self.fetchLevel = fetchLevel
        self.fetchUpcomingEvent = fetchUpcomingEvent
    }

    func observe() async {
        for await session in observeSession.execute() {
            guard let session else {
                continue
            }
            self.session = session
            profileTask.run { [weak self] in
                await self?.observeProfile(session: session)
            }
        }
        profileTask.cancel()
    }

    func refresh() async {
        guard let session else {
            return
        }
        await load(session: session, profile: profile)
    }

    private func observeProfile(session: AuthSession) async {
        do {
            for try await profile in observeUserProfile.execute(userId: session.userId) {
                self.profile = profile
                await load(session: session, profile: profile)
            }
        } catch {
            profile = nil
            await load(session: session, profile: nil)
        }
    }

    private func load(session: AuthSession, profile: UserProfile?) async {
        async let tasks = fetchPendingTasks.execute(userId: session.userId, profile: profile)
        async let points = fetchPointsBalance.execute(userId: session.userId)
        async let level = fetchLevel.execute(userId: session.userId)
        async let upcomingEvent = fetchUpcomingEvent.execute()
        let loadedTasks: [EcoTask]?
        do {
            loadedTasks = try await tasks
        } catch {
            loadedTasks = nil
        }
        let loadedPoints = try? await points
        let loadedLevel = try? await level
        let loadedEvent = try? await upcomingEvent
        guard !Task.isCancelled else {
            return
        }
        uiState = HomeUiState(
            isLoading: false,
            hasTasksError: loadedTasks == nil,
            displayName: profile?.firstName ?? session.displayName,
            avatar: profile?.avatar ?? .lime,
            points: loadedPoints ?? 0,
            level: loadedLevel,
            upcomingEvent: loadedEvent ?? nil,
            tasks: loadedTasks ?? []
        )
    }
}

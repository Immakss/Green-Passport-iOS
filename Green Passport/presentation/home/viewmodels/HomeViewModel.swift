import Foundation
import Observation

@Observable
final class HomeViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeUserProfile: ObserveUserProfileUseCase
    @ObservationIgnored private let observeTasks: ObserveTasksUseCase
    @ObservationIgnored private let observeCompletedTaskIds: ObserveCompletedTaskIdsUseCase
    @ObservationIgnored private let rankPendingTasks: RankPendingTasksUseCase
    @ObservationIgnored private let observeWallet: ObserveWalletUseCase
    @ObservationIgnored private let observeUpcomingEvent: ObserveUpcomingEventUseCase
    @ObservationIgnored private let sessionTask = LatestTask()
    @ObservationIgnored private var session: AuthSession?
    @ObservationIgnored private var tasks: [EcoTask]?
    @ObservationIgnored private var completedTaskIds: Set<String>?
    @ObservationIgnored private var profile: UserProfile?

    private(set) var uiState = HomeUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeUserProfile: ObserveUserProfileUseCase,
        observeTasks: ObserveTasksUseCase,
        observeCompletedTaskIds: ObserveCompletedTaskIdsUseCase,
        rankPendingTasks: RankPendingTasksUseCase,
        observeWallet: ObserveWalletUseCase,
        observeUpcomingEvent: ObserveUpcomingEventUseCase
    ) {
        self.observeSession = observeSession
        self.observeUserProfile = observeUserProfile
        self.observeTasks = observeTasks
        self.observeCompletedTaskIds = observeCompletedTaskIds
        self.rankPendingTasks = rankPendingTasks
        self.observeWallet = observeWallet
        self.observeUpcomingEvent = observeUpcomingEvent
    }

    func observe() async {
        for await session in observeSession.execute() {
            guard let session else {
                continue
            }
            self.session = session
            start(session: session)
        }
        sessionTask.cancel()
    }

    func retry() {
        guard let session else {
            return
        }
        uiState.hasTasksError = false
        start(session: session)
    }

    private func start(session: AuthSession) {
        sessionTask.run { [weak self] in
            await self?.observeData(session: session)
        }
    }

    private func observeData(session: AuthSession) async {
        uiState.displayName = profile?.firstName ?? session.displayName
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeProfile(session: session) }
            group.addTask { await self.observeWallet(userId: session.userId) }
            group.addTask { await self.observeTasks() }
            group.addTask { await self.observeCompletedTaskIds(userId: session.userId) }
            group.addTask { await self.observeUpcomingEvent() }
        }
    }

    private func observeProfile(session: AuthSession) async {
        do {
            for try await profile in observeUserProfile.execute(userId: session.userId) {
                self.profile = profile
                uiState.displayName = profile?.firstName ?? session.displayName
                uiState.avatar = profile?.avatar ?? .lime
                updateTasks()
            }
        } catch {
            return
        }
    }

    private func observeWallet(userId: String) async {
        do {
            for try await wallet in observeWallet.execute(userId: userId) {
                uiState.points = wallet.availablePoints
                uiState.level = wallet.level
                uiState.streakDays = wallet.streak?.currentCount(at: Date()) ?? 0
            }
        } catch {
            return
        }
    }

    private func observeTasks() async {
        do {
            for try await tasks in observeTasks.execute() {
                self.tasks = tasks
                updateTasks()
            }
        } catch {
            showTasksError()
        }
    }

    private func observeCompletedTaskIds(userId: String) async {
        do {
            for try await completedTaskIds in observeCompletedTaskIds.execute(userId: userId) {
                self.completedTaskIds = completedTaskIds
                updateTasks()
            }
        } catch {
            showTasksError()
        }
    }

    private func observeUpcomingEvent() async {
        do {
            for try await event in observeUpcomingEvent.execute() {
                uiState.upcomingEvent = event
            }
        } catch {
            return
        }
    }

    private func updateTasks() {
        guard let tasks, let completedTaskIds else {
            return
        }
        uiState.tasks = rankPendingTasks.execute(tasks: tasks, completedIds: completedTaskIds, profile: profile)
        uiState.hasTasksError = false
        uiState.isLoading = false
    }

    private func showTasksError() {
        guard !Task.isCancelled else {
            return
        }
        uiState.hasTasksError = uiState.tasks.isEmpty
        uiState.isLoading = false
    }
}

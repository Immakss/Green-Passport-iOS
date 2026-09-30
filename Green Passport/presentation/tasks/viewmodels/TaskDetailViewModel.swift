import Foundation
import Observation

@Observable
final class TaskDetailViewModel {
    @ObservationIgnored private let taskId: String
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let fetchTasks: FetchTasksUseCase
    @ObservationIgnored private let fetchCompletedTaskIds: FetchCompletedTaskIdsUseCase
    @ObservationIgnored private let completeSelfTask: CompleteSelfTaskUseCase
    @ObservationIgnored private let redeemTaskCode: RedeemTaskCodeUseCase
    @ObservationIgnored private let submitTaskPhoto: SubmitTaskPhotoUseCase
    @ObservationIgnored private let observeTaskSubmissions: ObserveTaskSubmissionsUseCase
    @ObservationIgnored private let submissionsTask = LatestTask()
    @ObservationIgnored private var userId: String?

    private(set) var uiState = TaskDetailUiState()

    init(
        taskId: String,
        observeSession: ObserveSessionUseCase,
        fetchTasks: FetchTasksUseCase,
        fetchCompletedTaskIds: FetchCompletedTaskIdsUseCase,
        completeSelfTask: CompleteSelfTaskUseCase,
        redeemTaskCode: RedeemTaskCodeUseCase,
        submitTaskPhoto: SubmitTaskPhotoUseCase,
        observeTaskSubmissions: ObserveTaskSubmissionsUseCase
    ) {
        self.taskId = taskId
        self.observeSession = observeSession
        self.fetchTasks = fetchTasks
        self.fetchCompletedTaskIds = fetchCompletedTaskIds
        self.completeSelfTask = completeSelfTask
        self.redeemTaskCode = redeemTaskCode
        self.submitTaskPhoto = submitTaskPhoto
        self.observeTaskSubmissions = observeTaskSubmissions
    }

    func observe() async {
        for await session in observeSession.execute() {
            userId = session?.userId
            await loadTask()
            guard let userId = session?.userId else {
                submissionsTask.cancel()
                continue
            }
            submissionsTask.run { [weak self] in
                await self?.observeSubmissions(userId: userId)
            }
        }
        submissionsTask.cancel()
    }

    func retry() {
        Task { await loadTask() }
    }

    func completeTask() {
        runRewardAction { [taskId] in
            return try await self.completeSelfTask.execute(taskId: taskId)
        }
    }

    func redeemCode(_ code: String) {
        runRewardAction {
            return try await self.redeemTaskCode.execute(code: code)
        }
    }

    func submitPhoto(_ imageData: Data) {
        guard let userId, !uiState.isSubmitting else {
            return
        }
        uiState.isSubmitting = true
        uiState.failure = nil
        Task {
            do {
                let submission = try await submitTaskPhoto.execute(userId: userId, taskId: taskId, imageData: imageData)
                uiState.submission = submission
                uiState.isSubmitting = false
            } catch {
                handleFailure(error)
            }
        }
    }

    private func runRewardAction(_ action: @escaping () async throws -> RewardResult) {
        guard !uiState.isCompleted, !uiState.isSubmitting, userId != nil else {
            return
        }
        uiState.isSubmitting = true
        uiState.failure = nil
        Task {
            do {
                let reward = try await action()
                uiState.isSubmitting = false
                uiState.isCompleted = true
                uiState.earnedPoints = reward.points
            } catch {
                handleFailure(error)
            }
        }
    }

    private func handleFailure(_ error: Error) {
        let failure = (error as? RewardFailureError)?.failure ?? .unknown
        uiState.isSubmitting = false
        uiState.failure = failure
        uiState.isCompleted = uiState.isCompleted || failure == .alreadyCompleted
    }

    private func observeSubmissions(userId: String) async {
        do {
            for try await submissions in observeTaskSubmissions.execute(userId: userId) {
                let submission = submissions.first { $0.taskId == taskId }
                uiState.submission = submission
                uiState.isCompleted = uiState.isCompleted || submission?.status == .approved
            }
        } catch {
            return
        }
    }

    private func loadTask() async {
        uiState.isLoading = true
        uiState.hasError = false
        do {
            let task = try await fetchTasks.execute().first { $0.id == taskId }
            var completedIds: Set<String> = []
            if let userId {
                completedIds = try await fetchCompletedTaskIds.execute(userId: userId)
            }
            uiState.task = task
            uiState.isCompleted = completedIds.contains(taskId)
            uiState.isLoading = false
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }
}

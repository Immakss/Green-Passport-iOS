import Observation

@Observable
final class ModerationViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeIsModerator: ObserveIsModeratorUseCase
    @ObservationIgnored private let observePendingSubmissions: ObservePendingSubmissionsUseCase
    @ObservationIgnored private let observeFlaggedPosts: ObserveFlaggedPostsUseCase
    @ObservationIgnored private let observeTasks: ObserveTasksUseCase
    @ObservationIgnored private let fetchSubmissionPhotoUrl: FetchSubmissionPhotoUrlUseCase
    @ObservationIgnored private let reviewSubmission: ReviewSubmissionUseCase
    @ObservationIgnored private let moderatePost: ModeratePostUseCase
    @ObservationIgnored private let queueTask = LatestTask()
    @ObservationIgnored private var hasLoadedSubmissions = false
    @ObservationIgnored private var hasLoadedPosts = false

    private(set) var uiState = ModerationUiState()

    init(
        observeSession: ObserveSessionUseCase,
        observeIsModerator: ObserveIsModeratorUseCase,
        observePendingSubmissions: ObservePendingSubmissionsUseCase,
        observeFlaggedPosts: ObserveFlaggedPostsUseCase,
        observeTasks: ObserveTasksUseCase,
        fetchSubmissionPhotoUrl: FetchSubmissionPhotoUrlUseCase,
        reviewSubmission: ReviewSubmissionUseCase,
        moderatePost: ModeratePostUseCase
    ) {
        self.observeSession = observeSession
        self.observeIsModerator = observeIsModerator
        self.observePendingSubmissions = observePendingSubmissions
        self.observeFlaggedPosts = observeFlaggedPosts
        self.observeTasks = observeTasks
        self.fetchSubmissionPhotoUrl = fetchSubmissionPhotoUrl
        self.reviewSubmission = reviewSubmission
        self.moderatePost = moderatePost
    }

    func observe() async {
        guard let userId = await observeSession.current()?.userId else {
            uiState.isLoading = false
            return
        }
        do {
            for try await isModerator in observeIsModerator.execute(userId: userId) {
                uiState.isModerator = isModerator
                if isModerator {
                    finishLoadingIfReady()
                    queueTask.run { [weak self] in
                        await self?.observeQueues()
                    }
                } else {
                    queueTask.cancel()
                    uiState.isLoading = false
                }
            }
        } catch {
            uiState.isLoading = false
        }
        queueTask.cancel()
    }

    func review(_ item: SubmissionItem, approve: Bool, reason: String?) {
        perform(id: item.id) {
            try await self.reviewSubmission.execute(submissionId: item.id, approve: approve, reason: reason)
        }
    }

    func moderate(_ post: ForumPost, action: ModerationAction) {
        perform(id: post.id) {
            try await self.moderatePost.execute(postId: post.id, action: action)
        }
    }

    private func perform(id: String, action: @escaping () async throws -> Void) {
        guard !uiState.processingIds.contains(id) else {
            return
        }
        uiState.processingIds.insert(id)
        uiState.hasActionError = false
        Task {
            do {
                try await action()
            } catch {
                uiState.hasActionError = true
            }
            uiState.processingIds.remove(id)
        }
    }

    private func observeQueues() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeSubmissions() }
            group.addTask { await self.observePosts() }
        }
    }

    private func observeSubmissions() async {
        let taskTitles = Dictionary(((try? await observeTasks.execute().firstValue()) ?? []).map { return ($0.id, $0.title) }) { first, _ in
            return first
        }
        do {
            for try await submissions in observePendingSubmissions.execute() {
                var items: [SubmissionItem] = []
                for submission in submissions {
                    let url = await fetchSubmissionPhotoUrl.execute(photoPath: submission.photoPath)
                    items.append(SubmissionItem(
                        submission: submission,
                        taskTitle: taskTitles[submission.taskId] ?? submission.taskId,
                        photoUrl: url
                    ))
                }
                uiState.submissions = items
                hasLoadedSubmissions = true
                finishLoadingIfReady()
            }
        } catch {
            uiState.submissions = []
            hasLoadedSubmissions = true
            finishLoadingIfReady()
        }
    }

    private func observePosts() async {
        do {
            for try await posts in observeFlaggedPosts.execute() {
                uiState.flaggedPosts = posts
                hasLoadedPosts = true
                finishLoadingIfReady()
            }
        } catch {
            uiState.flaggedPosts = []
            hasLoadedPosts = true
            finishLoadingIfReady()
        }
    }

    private func finishLoadingIfReady() {
        guard hasLoadedSubmissions, hasLoadedPosts else {
            return
        }
        uiState.isLoading = false
    }
}

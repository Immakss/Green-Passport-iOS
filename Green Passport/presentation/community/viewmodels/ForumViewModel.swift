import Foundation
import Observation

@Observable
final class ForumViewModel {
    @ObservationIgnored private let observeSession: ObserveSessionUseCase
    @ObservationIgnored private let observeForumPosts: ObserveForumPostsUseCase
    @ObservationIgnored private let postToForum: PostToForumUseCase
    @ObservationIgnored private let reportPost: ReportPostUseCase

    private(set) var uiState = ForumUiState()
    private(set) var postedCount = 0

    init(
        observeSession: ObserveSessionUseCase,
        observeForumPosts: ObserveForumPostsUseCase,
        postToForum: PostToForumUseCase,
        reportPost: ReportPostUseCase
    ) {
        self.observeSession = observeSession
        self.observeForumPosts = observeForumPosts
        self.postToForum = postToForum
        self.reportPost = reportPost
    }

    func observe() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.observeUser() }
            group.addTask { await self.observePosts() }
        }
    }

    func updateDraft(_ text: String) {
        uiState.draft = text
        uiState.isTextRejected = false
        uiState.isSendFailed = false
    }

    func post() {
        let text = uiState.draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let userId = uiState.currentUserId, !text.isEmpty, !uiState.isPosting else {
            return
        }
        uiState.isPosting = true
        uiState.isSendFailed = false
        Task {
            do {
                try await postToForum.execute(authorId: userId, text: text)
                uiState.draft = ""
                postedCount += 1
            } catch is ContentRejectedError {
                uiState.isTextRejected = true
            } catch {
                uiState.isSendFailed = true
            }
            uiState.isPosting = false
        }
    }

    func report(_ post: ForumPost, reason: ReportReason) {
        guard let userId = uiState.currentUserId else {
            return
        }
        Task {
            do {
                try await reportPost.execute(postId: post.id, reporterId: userId, reason: reason)
                uiState.reportedPostIds.insert(post.id)
            } catch {
                return
            }
        }
    }

    private func observeUser() async {
        for await session in observeSession.execute() {
            uiState.currentUserId = session?.userId
        }
    }

    private func observePosts() async {
        do {
            for try await posts in observeForumPosts.execute() {
                uiState.posts = posts
                uiState.isLoading = false
                uiState.hasError = false
            }
        } catch {
            uiState.isLoading = false
            uiState.hasError = true
        }
    }
}

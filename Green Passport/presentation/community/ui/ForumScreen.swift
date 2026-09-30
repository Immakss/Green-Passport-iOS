import SwiftUI

struct ForumScreen: View {
    private static let avatarSize: CGFloat = 36
    private static let composerLineLimit = 1...5

    let uiState: ForumUiState
    @Binding var draft: String
    let onPost: () -> Void
    let onReport: (ForumPost, ReportReason) -> Void
    let onRetry: () -> Void

    var body: some View {
        List(uiState.posts) { post in
            postRow(post)
        }
        .listStyle(.insetGrouped)
        .overlay {
            if uiState.isLoading {
                StateView(kind: .loading)
            } else if uiState.hasError {
                StateView(kind: .error(retry: onRetry))
            } else if uiState.posts.isEmpty {
                StateView(kind: .empty(message: .forumEmpty))
            }
        }
        .safeAreaInset(edge: .bottom) {
            composer
        }
        .navigationTitle(Text(.communityForumTitle))
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: Spacing.xxSmall) {
            if uiState.isTextRejected {
                Text(.textContainsBannedWords)
                    .font(.footnote)
                    .foregroundStyle(Palette.error)
                    .padding(.horizontal, Spacing.medium)
            }
            HStack(alignment: .bottom, spacing: Spacing.xSmall) {
                TextField(String(localized: .forumDraftLabel), text: $draft, axis: .vertical)
                    .lineLimit(Self.composerLineLimit)
                    .padding(.horizontal, Spacing.medium)
                    .padding(.vertical, Spacing.small)
                    .glassEffect(in: .rect(cornerRadius: CornerRadius.large))
                Button(action: onPost) {
                    if uiState.isPosting {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up")
                            .font(.headline)
                    }
                }
                .buttonStyle(.glassProminent)
                .buttonBorderShape(.circle)
                .controlSize(.large)
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || uiState.isPosting)
                .accessibilityLabel(Text(.forumPostButton))
            }
        }
        .padding(.horizontal, Spacing.screenHorizontal)
        .padding(.bottom, Spacing.xSmall)
    }

    private func postRow(_ post: ForumPost) -> some View {
        return VStack(alignment: .leading, spacing: Spacing.xSmall) {
            HStack(spacing: Spacing.small) {
                ProfileAvatar(style: post.authorAvatar ?? .lime, size: Self.avatarSize)
                VStack(alignment: .leading, spacing: Spacing.hairline) {
                    Text(post.authorName ?? String(localized: .guest))
                        .font(.subheadline.weight(.semibold))
                    Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(Palette.secondaryText)
                }
                Spacer()
                reportControl(post)
            }
            Text(post.text)
                .font(.body)
        }
        .padding(.vertical, Spacing.xxSmall)
    }

    @ViewBuilder
    private func reportControl(_ post: ForumPost) -> some View {
        if post.authorId != uiState.currentUserId && uiState.currentUserId != nil {
            if uiState.reportedPostIds.contains(post.id) {
                Text(.reportSent)
                    .font(.caption)
                    .foregroundStyle(Palette.secondaryText)
            } else {
                Menu {
                    ForEach(ReportReason.allCases, id: \.self) { reason in
                        Button {
                            onReport(post, reason)
                        } label: {
                            Text(reason.title)
                        }
                    }
                } label: {
                    Image(systemName: "flag")
                        .foregroundStyle(Palette.secondaryText)
                }
                .accessibilityLabel(Text(.report))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ForumScreen(
            uiState: ForumUiState(
                posts: [ForumPost(id: "1", authorId: "2", authorName: "Аня", authorAvatar: .berry, text: "Кто идёт на субботник?", createdAt: .now, isHidden: false, reportCount: 0)],
                isLoading: false,
                currentUserId: "1"
            ),
            draft: .constant(""),
            onPost: {},
            onReport: { _, _ in },
            onRetry: {}
        )
    }
}

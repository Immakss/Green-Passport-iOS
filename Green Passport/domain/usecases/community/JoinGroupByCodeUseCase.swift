import Foundation

final class JoinGroupByCodeUseCase {
    private let communityRepository: CommunityRepository

    init(communityRepository: CommunityRepository) {
        self.communityRepository = communityRepository
    }

    func execute(code: String, userId: String) async throws -> CommunityGroup {
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard normalizedCode.count == InviteCodeGenerator.length,
              let group = try await communityRepository.findGroup(inviteCode: normalizedCode) else {
            throw GroupNotFoundError()
        }
        if !group.memberIds.contains(userId) {
            try await communityRepository.joinGroup(groupId: group.id, userId: userId)
        }
        return group
    }
}

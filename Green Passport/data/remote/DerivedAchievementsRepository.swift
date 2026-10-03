final class DerivedAchievementsRepository: AchievementsRepository {
    private static let firstTaskThreshold = 1
    private static let taskMasterThreshold = 5
    private static let eventGoerThreshold = 1
    private static let ecoReaderThreshold = 3
    private static let communityMemberThreshold = 1
    private static let levelFiveThreshold = 5

    private let tasksRepository: TasksRepository
    private let eventsRepository: EventsRepository
    private let ecoTipsRepository: EcoTipsRepository
    private let communityRepository: CommunityRepository
    private let pointsRepository: PointsRepository

    init(
        tasksRepository: TasksRepository,
        eventsRepository: EventsRepository,
        ecoTipsRepository: EcoTipsRepository,
        communityRepository: CommunityRepository,
        pointsRepository: PointsRepository
    ) {
        self.tasksRepository = tasksRepository
        self.eventsRepository = eventsRepository
        self.ecoTipsRepository = ecoTipsRepository
        self.communityRepository = communityRepository
        self.pointsRepository = pointsRepository
    }

    func fetchAchievements(userId: String) async throws -> [Achievement] {
        async let completedTasks = tasksRepository.observeCompletedTaskIds(userId: userId).firstValue()
        async let registeredEvents = eventsRepository.observeRegisteredEventIds(userId: userId).firstValue()
        async let readTips = ecoTipsRepository.observeReadTipIds(userId: userId).firstValue()
        async let wallet = pointsRepository.observeWallet(userId: userId).firstValue()
        let isGroupMember = try await isMemberOfAnyGroup(userId: userId)
        let completedCount = try await completedTasks?.count ?? 0
        let registeredCount = try await registeredEvents?.count ?? 0
        let readCount = try await readTips?.count ?? 0
        let level = try await Level(lifetimeXp: wallet?.lifetimeXp ?? 0)
        return AchievementId.allCases.map { id in
            switch id {
            case .firstTask:
                return Achievement(id: id, progress: completedCount, target: Self.firstTaskThreshold)
            case .taskMaster:
                return Achievement(id: id, progress: completedCount, target: Self.taskMasterThreshold)
            case .eventGoer:
                return Achievement(id: id, progress: registeredCount, target: Self.eventGoerThreshold)
            case .ecoReader:
                return Achievement(id: id, progress: readCount, target: Self.ecoReaderThreshold)
            case .communityMember:
                return Achievement(id: id, progress: isGroupMember ? 1 : 0, target: Self.communityMemberThreshold)
            case .levelFive:
                return Achievement(id: id, progress: level.number, target: Self.levelFiveThreshold)
            }
        }
    }

    private func isMemberOfAnyGroup(userId: String) async throws -> Bool {
        for try await groups in communityRepository.observeGroups() {
            return groups.contains { return $0.memberIds.contains(userId) }
        }
        return false
    }
}

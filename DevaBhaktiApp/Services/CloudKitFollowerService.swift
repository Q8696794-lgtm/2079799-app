import Foundation

@Observable
@MainActor
class CloudKitFollowerService {
    var followerCounts: [DeityID: Int] = [:]
    private(set) var isLoaded = false

    init() {}

    func fetchAllCounts() async {
        for deity in Deity.allDeities {
            followerCounts[deity.id] = deity.followerCount
        }
        isLoaded = true
    }

    func reportSelection(deityIDs: [DeityID]) async {
        for deityID in deityIDs {
            let current = followerCounts[deityID] ?? Deity.deity(for: deityID).followerCount
            followerCounts[deityID] = current + 1
        }
    }

    func reportDeselection(removedIDs: [DeityID]) async {
        for deityID in removedIDs {
            let current = followerCounts[deityID] ?? Deity.deity(for: deityID).followerCount
            followerCounts[deityID] = max(0, current - 1)
        }
    }

    func count(for deityID: DeityID) -> Int {
        followerCounts[deityID] ?? Deity.deity(for: deityID).followerCount
    }
}

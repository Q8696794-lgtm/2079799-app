import SwiftUI

@Observable
@MainActor
class AppState {
    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    var selectedDeityIDs: [DeityID] {
        didSet {
            if let data = try? JSONEncoder().encode(selectedDeityIDs) {
                UserDefaults.standard.set(data, forKey: "selectedDeityIDs")
            }
        }
    }

    var primaryDeityID: DeityID? {
        selectedDeityIDs.first
    }

    var selectedDeities: [Deity] {
        selectedDeityIDs.compactMap { id in Deity.allDeities.first { $0.id == id } }
    }

    var progress: UserProgress {
        didSet {
            if let data = try? JSONEncoder().encode(progress) {
                UserDefaults.standard.set(data, forKey: "userProgress")
            }
        }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if let data = UserDefaults.standard.data(forKey: "selectedDeityIDs"),
           let ids = try? JSONDecoder().decode([DeityID].self, from: data) {
            self.selectedDeityIDs = ids
        } else {
            self.selectedDeityIDs = []
        }

        if let data = UserDefaults.standard.data(forKey: "userProgress"),
           let p = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.progress = p
        } else {
            self.progress = UserProgress()
        }
    }

    func selectDeities(_ ids: [DeityID]) {
        selectedDeityIDs = ids
        hasCompletedOnboarding = true
    }

    func addPunya(_ points: Int) {
        var p = progress
        p.punyaPoints += points
        updateLevel(&p)
        progress = p
    }

    func hasDoneAartiToday() -> Bool {
        guard let lastAarti = progress.lastAartiDate else { return false }
        return lastAarti >= lastResetTime()
    }

    func hasDoneDarshanToday() -> Bool {
        guard let lastDarshan = progress.lastDarshanDate else { return false }
        return lastDarshan >= lastResetTime()
    }

    private func lastResetTime() -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone.current
        let now = Date()
        var comps = cal.dateComponents([.year, .month, .day], from: now)
        comps.hour = 5
        comps.minute = 0
        comps.second = 0
        guard let today5AM = cal.date(from: comps) else { return now }
        return now >= today5AM ? today5AM : cal.date(byAdding: .day, value: -1, to: today5AM) ?? now
    }

    func recordDarshan() {
        guard !hasDoneDarshanToday() else { return }
        var p = progress
        let today = Calendar.current.startOfDay(for: Date())
        if let last = p.lastDarshanDate {
            let lastDay = Calendar.current.startOfDay(for: last)
            let diff = Calendar.current.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 1 {
                p.dailyDarshanStreak += 1
            } else if diff > 1 {
                p.dailyDarshanStreak = 1
            }
        } else {
            p.dailyDarshanStreak = 1
        }
        p.lastDarshanDate = Date()
        p.totalDarshanCount += 1
        p.punyaPoints += 10
        updateLevel(&p)
        progress = p
    }

    func recordAarti() {
        guard !hasDoneAartiToday() else { return }
        var p = progress
        p.lastAartiDate = Date()
        p.totalAartiCount += 1
        p.punyaPoints += 15
        updateLevel(&p)
        progress = p
    }

    func recordMantraChant(count: Int) {
        var p = progress
        let oldMalas = p.totalMantrasChanted / 108
        p.totalMantrasChanted += count
        let newMalas = p.totalMantrasChanted / 108
        let earnedPunya = newMalas - oldMalas
        if earnedPunya > 0 {
            p.punyaPoints += earnedPunya
        }
        updateLevel(&p)
        progress = p
    }

    private func updateLevel(_ p: inout UserProgress) {
        if p.punyaPoints >= 15000 {
            p.level = .paramBhakt
        } else if p.punyaPoints >= 5000 {
            p.level = .bhakt
        } else if p.punyaPoints >= 2000 {
            p.level = .upasak
        } else if p.punyaPoints >= 500 {
            p.level = .sadhak
        } else {
            p.level = .shishya
        }
    }
}

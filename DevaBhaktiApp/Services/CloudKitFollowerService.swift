import Foundation
import CloudKit

@Observable
@MainActor
class CloudKitFollowerService {
    var followerCounts: [DeityID: Int] = [:]
    private(set) var isLoaded = false

    private let container = CKContainer(identifier: "iCloud.app.rork.deva-bhakti-app")
    private var publicDB: CKDatabase { container.publicCloudDatabase }
    private let recordType = "DeityFollowerCount"

    private var reportedDeityIDs: Set<String> {
        get {
            let arr = UserDefaults.standard.stringArray(forKey: "ck_reported_deities") ?? []
            return Set(arr)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "ck_reported_deities")
        }
    }

    func fetchAllCounts() async {
        do {
            let predicate = NSPredicate(value: true)
            let query = CKQuery(recordType: recordType, predicate: predicate)
            let (results, _) = try await publicDB.records(matching: query, resultsLimit: 20)
            for (_, result) in results {
                if let record = try? result.get(),
                   let deityRaw = record["deityID"] as? String,
                   let deityID = DeityID(rawValue: deityRaw),
                   let count = record["count"] as? Int64 {
                    followerCounts[deityID] = Int(count)
                }
            }
            isLoaded = true
        } catch {
            print("CloudKit fetch error: \(error.localizedDescription)")
            isLoaded = true
        }
    }

    func reportSelection(deityIDs: [DeityID]) async {
        var reported = reportedDeityIDs
        for deityID in deityIDs {
            guard !reported.contains(deityID.rawValue) else { continue }
            await incrementCount(for: deityID)
            reported.insert(deityID.rawValue)
        }
        reportedDeityIDs = reported
    }

    func reportDeselection(removedIDs: [DeityID]) async {
        var reported = reportedDeityIDs
        for deityID in removedIDs {
            guard reported.contains(deityID.rawValue) else { continue }
            await decrementCount(for: deityID)
            reported.remove(deityID.rawValue)
        }
        reportedDeityIDs = reported
    }

    func count(for deityID: DeityID) -> Int {
        if let ckCount = followerCounts[deityID] {
            return ckCount
        }
        return Deity.deity(for: deityID).followerCount
    }

    private func incrementCount(for deityID: DeityID) async {
        do {
            let record = try await fetchOrCreateRecord(for: deityID)
            let current = record["count"] as? Int64 ?? 0
            record["count"] = (current + 1) as CKRecordValue
            let saved = try await publicDB.save(record)
            if let newCount = saved["count"] as? Int64 {
                followerCounts[deityID] = Int(newCount)
            }
        } catch {
            print("CloudKit increment error for \(deityID.rawValue): \(error.localizedDescription)")
        }
    }

    private func decrementCount(for deityID: DeityID) async {
        do {
            let record = try await fetchOrCreateRecord(for: deityID)
            let current = record["count"] as? Int64 ?? 0
            let newVal = max(0, current - 1)
            record["count"] = newVal as CKRecordValue
            let saved = try await publicDB.save(record)
            if let newCount = saved["count"] as? Int64 {
                followerCounts[deityID] = Int(newCount)
            }
        } catch {
            print("CloudKit decrement error for \(deityID.rawValue): \(error.localizedDescription)")
        }
    }

    private func fetchOrCreateRecord(for deityID: DeityID) async throws -> CKRecord {
        let predicate = NSPredicate(format: "deityID == %@", deityID.rawValue)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        let (results, _) = try await publicDB.records(matching: query, resultsLimit: 1)
        if let first = results.first, let record = try? first.1.get() {
            return record
        }
        let record = CKRecord(recordType: recordType)
        record["deityID"] = deityID.rawValue as CKRecordValue
        record["count"] = Int64(Deity.deity(for: deityID).followerCount) as CKRecordValue
        return record
    }
}

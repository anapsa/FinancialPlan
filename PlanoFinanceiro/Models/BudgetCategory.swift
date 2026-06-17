import Foundation
import SwiftData

@Model
final class BudgetCategory {
    var name: String = ""
    var bucketRaw: String = BudgetBucket.needs.rawValue
    var limit: Double = 0
    var sortIndex: Int = 0

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction]? = []

    init(name: String, bucket: BudgetBucket, limit: Double, sortIndex: Int = 0) {
        self.name = name
        self.bucketRaw = bucket.rawValue
        self.limit = limit
        self.sortIndex = sortIndex
    }

    var bucket: BudgetBucket { BudgetBucket(rawValue: bucketRaw) ?? .needs }

    func spent(in reference: Date = .now) -> Double {
        (transactions ?? [])
            .filter { Calendar.current.isDate($0.date, equalTo: reference, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func remaining(in reference: Date = .now) -> Double { max(limit - spent(in: reference), 0) }
    func progress(in reference: Date = .now) -> Double { limit > 0 ? min(spent(in: reference) / limit, 1) : 0 }
    func isOverBudget(in reference: Date = .now) -> Bool { spent(in: reference) > limit }
}

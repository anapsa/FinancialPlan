import Foundation
import SwiftData


@Model
final class Household {
    var name: String = "Nosso Lar"
    var combinedIncome: Double = 0
    var createdAt: Date = Date.now

    init(name: String = "Nosso Lar", combinedIncome: Double = 0) {
        self.name = name
        self.combinedIncome = combinedIncome
    }
}

@Model
final class Member {
    var name: String = ""
    var colorHex: String = "#5856D6"
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .nullify, inverse: \Transaction.payer)
    var transactions: [Transaction]? = []

    init(name: String, colorHex: String) {
        self.name = name
        self.colorHex = colorHex
    }

    func spentThisMonth(reference: Date = .now) -> Double {
        (transactions ?? [])
            .filter { Calendar.current.isDate($0.date, equalTo: reference, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }
}

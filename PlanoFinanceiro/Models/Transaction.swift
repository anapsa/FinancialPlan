import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Double = 0
    var note: String = ""
    var date: Date = Date.now

    var payer: Member?
    var category: BudgetCategory?

    init(amount: Double, note: String = "", date: Date = .now,
         payer: Member? = nil, category: BudgetCategory? = nil) {
        self.amount = amount
        self.note = note
        self.date = date
        self.payer = payer
        self.category = category
    }
}

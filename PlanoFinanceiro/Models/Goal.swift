import Foundation
import SwiftData

@Model
final class Goal {
    var name: String = ""
    var systemImage: String = "target"
    var target: Double = 0
    var saved: Double = 0
    var monthlyContribution: Double = 0
    var annualReturn: Double = 0
    var priority: Int = 0
    var instrument: String = ""

    init(name: String, systemImage: String, target: Double, saved: Double,
         monthlyContribution: Double, annualReturn: Double, priority: Int, instrument: String) {
        self.name = name
        self.systemImage = systemImage
        self.target = target
        self.saved = saved
        self.monthlyContribution = monthlyContribution
        self.annualReturn = annualReturn
        self.priority = priority
        self.instrument = instrument
    }

    var progress: Double { target > 0 ? min(saved / target, 1) : 0 }
    var remaining: Double { max(target - saved, 0) }
    var isComplete: Bool { saved >= target }
}

@Model
final class Debt {
    var name: String = ""
    var balance: Double = 0
    var payment: Double = 0
    var monthlyRate: Double = 0
    var remainingMonths: Int = 0

    init(name: String, balance: Double, payment: Double, monthlyRate: Double, remainingMonths: Int) {
        self.name = name
        self.balance = balance
        self.payment = payment
        self.monthlyRate = monthlyRate
        self.remainingMonths = remainingMonths
    }

    func isWorthPrepaying(againstMonthlyRate benchmark: Double) -> Bool { monthlyRate > benchmark }
}

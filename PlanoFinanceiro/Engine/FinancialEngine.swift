import Foundation

enum FinancialEngine {

    // MARK: - Emergency reserve projection (Cenário A)

    struct ReserveMonth: Identifiable {
        let id = UUID()
        let month: Int
        let openingBalance: Double
        let contribution: Double
        let yield: Double
        let closingBalance: Double
    }

    static func projectReserve(
        initial: Double,
        monthlyContribution: Double,
        monthlyRate: Double,
        target: Double,
        maxMonths: Int = 36
    ) -> [ReserveMonth] {
        var rows: [ReserveMonth] = []
        var balance = initial

        let openingYield = balance * monthlyRate
        balance += openingYield
        rows.append(ReserveMonth(month: 0, openingBalance: initial,
                                 contribution: 0, yield: openingYield,
                                 closingBalance: balance))

        for month in 1...maxMonths {
            let opening = balance
            let base = opening + monthlyContribution
            let yield = base * monthlyRate
            balance = base + yield
            rows.append(ReserveMonth(month: month, openingBalance: opening,
                                     contribution: monthlyContribution,
                                     yield: yield, closingBalance: balance))
            if balance >= target { break }
        }
        return rows
    }

    static func monthsToTarget(_ projection: [ReserveMonth], target: Double) -> Int? {
        projection.first(where: { $0.closingBalance >= target })?.month
    }

    static func futureValue(
        initial: Double, monthlyContribution: Double,
        annualReturn: Double, years: Double
    ) -> Double {
        let r = pow(1 + annualReturn, 1.0 / 12.0) - 1
        let n = years * 12
        guard r > 0 else { return initial + monthlyContribution * n }
        let growth = pow(1 + r, n)
        return initial * growth + monthlyContribution * ((growth - 1) / r)
    }

    static func monthsToReach(
        saved: Double, target: Double,
        monthlyContribution: Double, annualReturn: Double,
        cap: Int = 600
    ) -> Int? {
        guard target > saved else { return 0 }
        let r = pow(1 + annualReturn, 1.0 / 12.0) - 1
        var balance = saved
        for month in 1...cap {
            balance = balance * (1 + r) + monthlyContribution
            if balance >= target { return month }
        }
        return nil
    }

    struct PayoffResult {
        let monthsWithoutExtra: Int
        let monthsWithExtra: Int
        let interestSaved: Double
        let monthsSaved: Int
    }

    static func simulatePayoff(
        balance: Double, payment: Double,
        monthlyRate: Double, extraMonthly: Double
    ) -> PayoffResult {
        let baseline = amortize(balance: balance, payment: payment, rate: monthlyRate, extra: 0)
        let accel = amortize(balance: balance, payment: payment, rate: monthlyRate, extra: extraMonthly)
        return PayoffResult(
            monthsWithoutExtra: baseline.months,
            monthsWithExtra: accel.months,
            interestSaved: baseline.interest - accel.interest,
            monthsSaved: max(baseline.months - accel.months, 0)
        )
    }

    private static func amortize(
        balance: Double, payment: Double, rate: Double, extra: Double
    ) -> (months: Int, interest: Double) {
        var remaining = balance
        var totalInterest = 0.0
        var months = 0
        let total = payment + extra
        guard total > remaining * rate else { return (months: 999, interest: .infinity) }
        while remaining > 0 && months < 1_000 {
            let interest = remaining * rate
            totalInterest += interest
            remaining = remaining + interest - total
            months += 1
        }
        return (months, totalInterest)
    }
}

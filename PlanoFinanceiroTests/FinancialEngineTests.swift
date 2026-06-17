import XCTest
@testable import PlanoFinanceiro

final class FinancialEngineTests: XCTestCase {

    func testReserveReachesTargetAroundMonthEleven() {
        let projection = FinancialEngine.projectReserve(
            initial: 12_000, monthlyContribution: 5_000,
            monthlyRate: 0.0083, target: 76_800
        )
        let month = FinancialEngine.monthsToTarget(projection, target: 76_800)
        XCTAssertNotNil(month)
        XCTAssertEqual(month!, 11, accuracy: 1)
    }

    func testFirstMonthYieldMatchesPlan() {
        let projection = FinancialEngine.projectReserve(
            initial: 12_000, monthlyContribution: 5_000,
            monthlyRate: 0.0083, target: .greatestFiniteMagnitude, maxMonths: 1
        )
        let firstContribMonth = projection[1]
        XCTAssertEqual(firstContribMonth.yield, 142, accuracy: 2)
        XCTAssertEqual(firstContribMonth.closingBalance, 17_242, accuracy: 5)
    }
    // Future value sanity: positive growth beats the plain sum of deposits.
    func testFutureValueExceedsPrincipalPlusContributions() {
        let fv = FinancialEngine.futureValue(
            initial: 0, monthlyContribution: 1_000, annualReturn: 0.10, years: 5
        )
        XCTAssertGreaterThan(fv, 1_000 * 60)
    }

    // A goal already met should report 0 months.
    func testCompletedGoalReturnsZeroMonths() {
        let months = FinancialEngine.monthsToReach(
            saved: 80_000, target: 76_800, monthlyContribution: 5_000, annualReturn: 0.105
        )
        XCTAssertEqual(months, 0)
    }

    // Debt payoff: an extra payment must never lengthen the payoff.
    func testExtraPaymentNeverIncreasesMonths() {
        let result = FinancialEngine.simulatePayoff(
            balance: 36_000, payment: 1_000, monthlyRate: 0.012, extraMonthly: 1_200
        )
        XCTAssertLessThanOrEqual(result.monthsWithExtra, result.monthsWithoutExtra)
        XCTAssertGreaterThanOrEqual(result.interestSaved, 0)
    }
}

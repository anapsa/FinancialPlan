import Foundation
import SwiftData

enum SampleData {

    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        let alreadySeeded = (try? context.fetch(FetchDescriptor<Household>()))?.isEmpty == false
        guard !alreadySeeded else { return }

        context.insert(Household(name: "Maria & Pedro", combinedIncome: 18_000))

        for member in members() { context.insert(member) }
        for category in categories() { context.insert(category) }
        for goal in goals() { context.insert(goal) }
        for debt in debts() { context.insert(debt) }

        try? context.save()
    }

    static func members() -> [Member] {
        [
            Member(name: "Maria", colorHex: "#FF2D55"),
            Member(name: "Pedro", colorHex: "#007AFF")
        ]
    }

    static func categories() -> [BudgetCategory] {
        var index = 0
        func next() -> Int { defer { index += 1 }; return index }
        return [
            BudgetCategory(name: "Aluguel", bucket: .needs, limit: 2_800, sortIndex: next()),
            BudgetCategory(name: "Condomínio / Contas", bucket: .needs, limit: 500, sortIndex: next()),
            BudgetCategory(name: "Financiamento do Carro", bucket: .needs, limit: 1_000, sortIndex: next()),
            BudgetCategory(name: "Plano de Saúde", bucket: .needs, limit: 700, sortIndex: next()),
            BudgetCategory(name: "Supermercado", bucket: .needs, limit: 1_000, sortIndex: next()),
            BudgetCategory(name: "Combustível / Transporte", bucket: .needs, limit: 600, sortIndex: next()),
            BudgetCategory(name: "Assinaturas", bucket: .needs, limit: 200, sortIndex: next()),
            BudgetCategory(name: "Alimentação fora / Delivery", bucket: .lifestyle, limit: 1_300, sortIndex: next()),
            BudgetCategory(name: "Lazer / Entretenimento", bucket: .lifestyle, limit: 1_700, sortIndex: next()),
            BudgetCategory(name: "Compras Pessoais", bucket: .lifestyle, limit: 1_800, sortIndex: next())
        ]
    }

    static func goals() -> [Goal] {
        [
            Goal(name: "Reserva de Emergência", systemImage: "shield.lefthalf.filled",
                 target: 76_800, saved: 12_000, monthlyContribution: 5_000,
                 annualReturn: 0.105, priority: 1, instrument: "Tesouro Selic / CDB liquidez diária"),
            Goal(name: "Apartamento Próprio", systemImage: "building.2.fill",
                 target: 150_000, saved: 0, monthlyContribution: 3_000,
                 annualReturn: 0.09, priority: 2, instrument: "LCI/LCA + Tesouro IPCA+"),
            Goal(name: "Viagem Internacional", systemImage: "airplane",
                 target: 24_000, saved: 0, monthlyContribution: 600,
                 annualReturn: 0.11, priority: 3, instrument: "CDB pré-fixado"),
            Goal(name: "Planejamento para Filhos", systemImage: "figure.2.and.child.holdinghands",
                 target: 30_000, saved: 0, monthlyContribution: 800,
                 annualReturn: 0.12, priority: 4, instrument: "Multimercado + ETF (IVVB11)"),
            Goal(name: "Liberdade Financeira", systemImage: "chart.line.uptrend.xyaxis",
                 target: 1_000_000, saved: 0, monthlyContribution: 500,
                 annualReturn: 0.13, priority: 5, instrument: "ETFs + IPCA+ + Previdência")
        ]
    }

    static func debts() -> [Debt] {
        [Debt(name: "Financiamento do Carro", balance: 36_000, payment: 1_000,
              monthlyRate: 0.012, remainingMonths: 36)]
    }
}

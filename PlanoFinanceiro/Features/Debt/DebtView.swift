import SwiftUI
import SwiftData

struct DebtView: View {
    @Query private var debts: [Debt]
    @State private var extra: Double = 1_200

    private let benchmarkRate = 0.015
    private var debt: Debt? { debts.first }

    private var result: FinancialEngine.PayoffResult? {
        guard let debt else { return nil }
        return FinancialEngine.simulatePayoff(
            balance: debt.balance, payment: debt.payment,
            monthlyRate: debt.monthlyRate, extraMonthly: extra
        )
    }

    var body: some View {
        List {
            if let debt {
                Section("Dívida") {
                    labeled("Saldo devedor", Format.currency(debt.balance))
                    labeled("Parcela mensal", Format.currency(debt.payment))
                    labeled("Taxa estimada", Format.percent(debt.monthlyRate, decimals: 1) + " a.m.")
                }

                Section("Amortização extra") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Valor extra/mês")
                            Spacer()
                            Text(Format.currency(extra)).monospacedDigit().foregroundStyle(Theme.accent)
                        }
                        Slider(value: $extra, in: 0...2_000, step: 100).tint(Theme.accent)
                    }
                }

                if let result {
                    Section("Resultado") {
                        labeled("Quitação sem extra", "\(result.monthsWithoutExtra) meses")
                        labeled("Quitação com extra", "\(result.monthsWithExtra) meses", highlight: true)
                        labeled("Meses economizados", "\(result.monthsSaved)")
                        labeled("Juros economizados", Format.currency(result.interestSaved), highlight: true)
                    }
                }

                Section {
                    let worth = debt.isWorthPrepaying(againstMonthlyRate: benchmarkRate)
                    Label {
                        Text(worth
                             ? "A taxa da dívida supera o ganho de um investimento seguro. Antecipar tende a valer a pena."
                             : "A taxa está abaixo do benchmark. Pode render mais investir o extra do que amortizar.")
                            .font(.footnote)
                    } icon: {
                        Image(systemName: worth ? "checkmark.circle.fill" : "info.circle.fill")
                            .foregroundStyle(worth ? .green : .orange)
                    }
                } footer: {
                    Text("Regra do plano: só amortize se a taxa efetiva superar ~1,5% a.m. Confirme as condições de quitação antecipada com o banco.")
                }
            } else {
                ContentUnavailableView("Sem dívidas", systemImage: "checkmark.seal",
                                       description: Text("Nenhuma dívida cadastrada."))
            }
        }
        .navigationTitle("Dívidas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func labeled(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit()
                .fontWeight(highlight ? .semibold : .regular)
                .foregroundStyle(highlight ? Theme.accent : .primary)
        }
    }
}

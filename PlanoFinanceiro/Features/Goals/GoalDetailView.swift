import SwiftUI
import SwiftData
struct GoalDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var goal: Goal
    @State private var contribution = ""

    private var monthsToFinish: Int? {
        FinancialEngine.monthsToReach(
            saved: goal.saved, target: goal.target,
            monthlyContribution: goal.monthlyContribution, annualReturn: goal.annualReturn
        )
    }

    private var projectedDate: String {
        guard let months = monthsToFinish else { return "—" }
        guard months > 0 else { return "Concluído" }
        let date = Calendar.current.date(byAdding: .month, value: months, to: .now) ?? .now
        let f = DateFormatter()
        f.locale = Locale(identifier: "pt_BR")
        f.dateFormat = "MMM/yyyy"
        return f.string(from: date).capitalized
    }

    private var parsed: Double? { Double(contribution.replacingOccurrences(of: ",", with: ".")) }

    var body: some View {
        List {
            Section {
                VStack(spacing: Theme.Spacing.regular) {
                    ProgressRing(progress: goal.progress, tint: Theme.accent, label: "concluído")
                        .frame(height: 150)
                    Text("\(Format.currency(goal.saved)) de \(Format.currency(goal.target))")
                        .font(.headline.monospacedDigit())
                }
                .frame(maxWidth: .infinity).padding(.vertical, Theme.Spacing.tight)
            }
            .listRowBackground(Color.clear)

            Section("Projeção") {
                row("Aporte mensal", Format.currency(goal.monthlyContribution))
                row("Retorno estimado", Format.percent(goal.annualReturn, decimals: 1) + " a.a.")
                row("Faltam", Format.currency(goal.remaining))
                row("Conclusão estimada", projectedDate, highlight: true)
            }

            Section("Estratégia") {
                Label(goal.instrument, systemImage: "banknote").font(.subheadline)
            }

            Section("Registrar aporte") {
                HStack {
                    TextField("Valor (R$)", text: $contribution).keyboardType(.decimalPad)
                    Button("Aportar") {
                        if let value = parsed {
                            goal.saved += value
                            try? context.save()
                            contribution = ""
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(parsed == nil)
                }
            }
        }
        .navigationTitle(goal.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func row(_ label: String, _ value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit()
                .fontWeight(highlight ? .semibold : .regular)
                .foregroundStyle(highlight ? Theme.accent : .primary)
        }
    }
}

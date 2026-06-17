import SwiftUI
import SwiftData
import Charts

struct ReserveSimulationView: View {
    @Query(sort: \Goal.priority) private var goals: [Goal]

    @State private var initial: Double = 12_000
    @State private var monthlyContribution: Double = 5_000
    @State private var annualRate: Double = 0.105
    @State private var didSeed = false

    private var reserveGoal: Goal? { goals.first(where: { $0.priority == 1 }) }
    private var target: Double { reserveGoal?.target ?? 76_800 }

    private var projection: [FinancialEngine.ReserveMonth] {
        let monthlyRate = pow(1 + annualRate, 1.0 / 12.0) - 1
        return FinancialEngine.projectReserve(
            initial: initial, monthlyContribution: monthlyContribution,
            monthlyRate: monthlyRate, target: target
        )
    }

    private var monthsToTarget: Int? {
        FinancialEngine.monthsToTarget(projection, target: target)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.loose) {
                    summary
                    chart
                    controls
                    scheduleTable
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Simulador")
            .onAppear(perform: seedFromGoal)
        }
    }

    private func seedFromGoal() {
        guard !didSeed, let goal = reserveGoal else { return }
        initial = goal.saved
        monthlyContribution = goal.monthlyContribution
        annualRate = goal.annualReturn
        didSeed = true
    }

    private var summary: some View {
        VStack(spacing: 6) {
            Text("Reserva de Emergência").font(.subheadline).foregroundStyle(.secondary)
            Text(Format.currency(target)).font(.largeTitle.bold().monospacedDigit())
            if let months = monthsToTarget {
                Label("Atingida em \(months) meses", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.medium)).foregroundStyle(.green)
            } else {
                Label("Não atingida em 36 meses", systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline.weight(.medium)).foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity).padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private var chart: some View {
        Chart {
            ForEach(projection) { row in
                AreaMark(x: .value("Mês", row.month), y: .value("Saldo", row.closingBalance))
                    .foregroundStyle(.green.opacity(0.18))
                LineMark(x: .value("Mês", row.month), y: .value("Saldo", row.closingBalance))
                    .foregroundStyle(.green).interpolationMethod(.catmullRom)
            }
            RuleMark(y: .value("Meta", target))
                .foregroundStyle(.secondary)
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
                .annotation(position: .top, alignment: .leading) {
                    Text("Meta").font(.caption2).foregroundStyle(.secondary)
                }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(Format.compactCurrency(amount)).font(.caption2)
                    }
                }
            }
        }
        .frame(height: 220).padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private var controls: some View {
        VStack(spacing: Theme.Spacing.loose) {
            sliderRow(title: "Aporte mensal", value: $monthlyContribution,
                      range: 1_000...8_000, step: 250,
                      display: Format.currency(monthlyContribution))
            sliderRow(title: "Retorno anual estimado", value: $annualRate,
                      range: 0.05...0.15, step: 0.005,
                      display: Format.percent(annualRate, decimals: 1))
        }
        .padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }

    private func sliderRow(title: String, value: Binding<Double>,
                           range: ClosedRange<Double>, step: Double, display: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title).font(.subheadline)
                Spacer()
                Text(display).font(.subheadline.weight(.semibold).monospacedDigit())
                    .foregroundStyle(Theme.accent)
            }
            Slider(value: value, in: range, step: step).tint(Theme.accent)
        }
    }

    private var scheduleTable: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.tight) {
            Text("Evolução mês a mês").font(.headline)
            ForEach(projection.filter { [0, 1, 3, 6, 9].contains($0.month) || $0.month == projection.count - 1 }) { row in
                HStack {
                    Text("Mês \(row.month)").font(.caption).foregroundStyle(.secondary)
                    Spacer()
                    Text(Format.currency(row.closingBalance))
                        .font(.callout.monospacedDigit().weight(.medium))
                }
                if row.month != projection.last?.month { Divider() }
            }
        }
        .padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

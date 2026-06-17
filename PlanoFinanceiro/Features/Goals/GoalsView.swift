import SwiftUI
import SwiftData

/// Lists the SMART goals in funding order. Each links to a detail view that
/// projects a completion date and lets either partner log a contribution.
struct GoalsView: View {
    @Query(sort: \Goal.priority) private var goals: [Goal]

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(goals) { goal in
                        NavigationLink(value: goal) { GoalRow(goal: goal) }
                    }
                } footer: {
                    Text("Ordem de prioridade: a reserva é financiada primeiro; só avance para o próximo fundo quando o anterior estiver consolidado.")
                }
            }
            .navigationTitle("Metas")
            .navigationDestination(for: Goal.self) { GoalDetailView(goal: $0) }
        }
    }
}

private struct GoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: Theme.Spacing.regular) {
            ZStack {
                Circle().fill(Theme.accent.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: goal.systemImage).foregroundStyle(Theme.accent)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(goal.name).font(.subheadline.weight(.semibold))
                    if goal.isComplete {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    }
                }
                EnvelopeBar(progress: goal.progress, tint: Theme.accent, isOver: false)
                Text("\(Format.currency(goal.saved)) de \(Format.currency(goal.target))")
                    .font(.caption.monospacedDigit()).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

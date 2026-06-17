import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \BudgetCategory.sortIndex) private var categories: [BudgetCategory]
    @Query(sort: \Member.createdAt) private var members: [Member]
    @Query(sort: \Goal.priority) private var goals: [Goal]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]
    @Query private var households: [Household]

    private var household: Household? { households.first }

    private var reserveGoal: Goal? { goals.first(where: { $0.priority == 1 }) }

    private var spentThisMonth: Double {
        transactions
            .filter { Calendar.current.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    private var budgetProgress: Double {
        let limit = categories.reduce(0) { $0 + $1.limit }
        return limit > 0 ? min(spentThisMonth / limit, 1) : 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.loose) {
                    QuickAddExpenseCard(members: members, categories: categories)

                    memberSplit

                    rings

                    statGrid

                    recentTransactions
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(household?.name ?? "Visão Geral")
        }
    }

    // MARK: Who spent what (the shared view)

    private var memberSplit: some View {
        HStack(spacing: Theme.Spacing.regular) {
            ForEach(members) { member in
                HStack(spacing: Theme.Spacing.tight) {
                    MemberBadge(member: member)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name).font(.caption).foregroundStyle(.secondary)
                        Text(Format.currency(member.spentThisMonth()))
                            .font(.callout.weight(.semibold).monospacedDigit())
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Theme.Spacing.regular)
                .background(Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }
        }
    }

    private var rings: some View {
        HStack(spacing: Theme.Spacing.loose) {
            ProgressRing(progress: reserveGoal?.progress ?? 0, tint: .green, label: "Reserva")
                .frame(height: 130)
            ProgressRing(progress: budgetProgress, tint: Theme.accent, label: "Orçamento")
                .frame(height: 130)
        }
    }

    private var statGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.regular) {
            StatCard(title: "Renda combinada",
                     value: Format.currency(household?.combinedIncome ?? 0),
                     systemImage: "arrow.down.circle.fill", tint: .green)
            StatCard(title: "Gasto no mês",
                     value: Format.currency(spentThisMonth),
                     systemImage: "arrow.up.circle.fill", tint: .red)
        }
    }

    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.regular) {
            Text("Lançamentos recentes").font(.headline)
            if transactions.isEmpty {
                Text("Nenhum gasto ainda. Lance o primeiro acima 👆")
                    .font(.subheadline).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ForEach(transactions.prefix(8)) { tx in
                    TransactionRow(transaction: tx)
                    if tx.id != transactions.prefix(8).last?.id { Divider() }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.regular)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: Theme.Spacing.regular) {
            if let payer = transaction.payer {
                MemberBadge(member: payer, size: 32)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Sem categoria")
                    .font(.subheadline.weight(.medium))
                Text(transaction.note.isEmpty
                     ? transaction.date.formatted(date: .abbreviated, time: .omitted)
                     : transaction.note)
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(Format.currency(transaction.amount))
                .font(.callout.weight(.semibold).monospacedDigit())
        }
        .padding(.vertical, 2)
    }
}

# Plano Financeiro — app do casal (iOS / SwiftUI)

App nativo que transforma o *Plano de Inteligência Financeira* (Maria & Pedro)
numa ferramenta compartilhada: o casal lança gastos em segundos, cada um
atribuído a quem pagou, e acompanha orçamento, metas e simulações.

## O que mudou nesta versão

- **Compartilhado entre o casal.** Todo gasto é atribuído a um membro (Maria ou
  Pedro). A Visão Geral mostra *quem gastou quanto* no mês. Os dados ficam num
  banco **SwiftData** (persistem entre sessões) e estão prontos para sincronizar
  via **iCloud/CloudKit** entre os dois aparelhos.
- **Lançar gasto na primeira tela.** A aba *Visão Geral* é "entrada primeiro":
  um cartão de **lançamento rápido** no topo (quem pagou · valor · categoria) e
  a lista de lançamentos recentes logo abaixo. Tudo começa zerado — o casal
  registra os próprios gastos, que alimentam as barras do orçamento.

## Como abrir e rodar

Este pacote **já contém o projeto Xcode** (`PlanoFinanceiro.xcodeproj`):

1. Abra `PlanoFinanceiro.xcodeproj` no **Xcode 16+**.
2. Escolha um simulador de iPhone e dê **⌘R** (rodar) ou **⌘U** (testes).

Roda local, sem nenhuma configuração de conta. O alvo mínimo é **iOS 17**
(SwiftData + Swift Charts).

## Ligar a sincronização entre os celulares (iCloud)

Por padrão o armazenamento é local (build roda sem setup). Para sincronizar:

1. Renomeie `PlanoFinanceiro/PlanoFinanceiro.entitlements.template` para
   `PlanoFinanceiro.entitlements`.
2. No target ▸ **Signing & Capabilities**, adicione **iCloud (CloudKit)** e
   **Background Modes ▸ Remote notifications**.
3. Em `App/PlanoFinanceiroApp.swift`, descomente `cloudKitDatabase: .automatic`
   na `ModelConfiguration`.
4. Mesma conta iCloud nos dois aparelhos sincroniza direto. Para **Apple IDs
   diferentes** (o caso real do casal), o passo de produção é CloudKit Sharing
   (`CKShare`) — a modelagem (household + membros + relações opcionais) já está
   pronta para isso.

## Estrutura

```
PlanoFinanceiro.xcodeproj        → projeto (app + testes), usa synchronized groups
PlanoFinanceiro/
├── App/          → entry point (monta o ModelContainer) + RootView
├── Models/       → @Model do SwiftData: Household, Member, BudgetCategory,
│                   Transaction, Goal, Debt  (+ enum BudgetBucket)
├── Engine/       → FinancialEngine: matemática pura e testável (projeção, FV, dívida)
├── Persistence/  → SampleData: semeia a estrutura do plano no 1º launch
├── Components/   → reutilizáveis (QuickAddExpenseCard, MemberBadge, ProgressRing…)
├── Features/     → uma pasta por tela (Dashboard, Budget, Goals, Simulation, More)
└── Support/      → formatação (R$) + tema (cores semânticas, Color(hex:))
PlanoFinanceiroTests/            → testes do engine, validados contra o plano
```

## Telas

| Aba | O que faz |
|-----|-----------|
| **Visão Geral** | Lançamento rápido, quem-gastou-quanto, anéis de reserva/orçamento, recentes. |
| **Orçamento** | Envelopes (50/30/20 adaptado); gasto lido ao vivo do ledger; lançar por categoria. |
| **Metas** | Objetivos SMART em ordem de prioridade, com data de conclusão projetada e aportes. |
| **Simulador** | Projeção da reserva ao vivo (Cenário A) — sliders de aporte/taxa. |
| **Mais** | Calculadora de quitação antecipada (Cenário B), rituais e vieses. |

## Princípios de código limpo

- **A matemática não tem UI nem banco.** `FinancialEngine` é um `enum` de funções
  puras sobre números — testado contra os valores reais do plano.
- **SwiftData como fonte de verdade**, lido nas telas via `@Query` e mutado via
  `modelContext`. Modelos seguem as regras de CloudKit (defaults + relações
  opcionais), então o mesmo schema serve local e na nuvem.
- **HIG por padrão.** Cores semânticas + fontes do sistema = Dark Mode e Dynamic
  Type automáticos; `TabView` / `NavigationStack` / `List` / `Form` padrão.

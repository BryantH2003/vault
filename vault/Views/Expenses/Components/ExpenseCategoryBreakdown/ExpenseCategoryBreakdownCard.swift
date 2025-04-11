import SwiftUI
import Charts

struct CategoryChartData: Identifiable {
    let id: UUID
    let category: Category
    let amount: Double
    let percentage: Double
    
    init(category: Category, amount: Double, total: Double) {
        self.id = category.id
        self.category = category
        self.amount = amount
        self.percentage = total > 0 ? (amount / total) * 100 : 0
    }
}

struct ExpenseCategoryBreakdownCard: View {
    let categories: [UUID: Category]
    let categoryExpenses: [UUID: Double]
    let previousMonthCategoryExpenses: [UUID: Double]
    @State private var selectedCategoryID: UUID?
    
    private var totalExpenses: Double {
        categoryExpenses.values.reduce(0, +)
    }
    
    private var chartData: [CategoryChartData] {
        let total = totalExpenses
        return categoryExpenses.compactMap { (categoryID, amount) in
            guard let category = categories[categoryID] else { return nil }
            return CategoryChartData(category: category, amount: amount, total: total)
        }.sorted { $0.amount > $1.amount }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .cardTitleStyle()
            
            if chartData.isEmpty {
                Text("No expenses recorded")
                    .secondaryTitleStyle()
            } else {
                CategoryPieChart(data: chartData, selectedCategoryID: $selectedCategoryID)
                    .frame(height: 200)
                    .padding(.vertical)
                
                if let selectedID = selectedCategoryID,
                   let selectedData = chartData.first(where: { $0.id == selectedID }) {
                    SelectedCategoryDetail(
                        data: selectedData,
                        previousAmount: previousMonthCategoryExpenses[selectedID] ?? 0,
                        totalAmount: totalExpenses
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.bottom)
                }
                
                CategoryDetailsList(
                    data: chartData,
                    previousMonthExpenses: previousMonthCategoryExpenses
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .figtreeFont(.regular, size: 16)
        .animation(.easeInOut, value: selectedCategoryID)
    }
}

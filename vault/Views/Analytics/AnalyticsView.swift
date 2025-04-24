import SwiftUI
import Charts

enum TimeframeOption {
    case monthly, yearly
    
    var title: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
}

enum DataType: String, CaseIterable {
    case income = "Income"
    case expenses = "Expenses"
    case savings = "Savings"
    
    var color: Color {
        switch self {
        case .income: return .green
        case .expenses: return .red
        case .savings: return .blue
        }
    }
}

struct AnalyticsView: View {
    let userID: UUID
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedDataTypes: Set<DataType> = Set(DataType.allCases)
    @State private var selectedBarData: BarData?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Timeframe Selector
                Picker("Timeframe", selection: $viewModel.timeframeOption) {
                    Text("Monthly").tag(TimeframeOption.monthly)
                    Text("Yearly").tag(TimeframeOption.yearly)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(height: 300)
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                        .frame(height: 300)
                } else {
                    // Chart
                    ChartView(
                        data: viewModel.chartData,
                        selectedTimeframe: viewModel.timeframeOption,
                        selectedDataTypes: selectedDataTypes,
                        selectedBarData: $selectedBarData
                    )
                    .frame(height: 300)
                    .padding()
                }
                
                // Legend
                LegendView(selectedDataTypes: $selectedDataTypes)
                    .padding(.horizontal)
                
                // Navigation Arrows
                HStack {
                    Button(action: {
                        viewModel.previousTimeframe()
                        Task {
                            await viewModel.loadData(forUserID: userID)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    .disabled(viewModel.isLoading)
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.nextTimeframe()
                        Task {
                            await viewModel.loadData(forUserID: userID)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 40)
                
                // Selected Bar Details
                if let selectedData = selectedBarData {
                    SelectedBarDetailView(data: selectedData)
                        .padding()
                        .transition(.opacity)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Analytics")
        .task {
            await viewModel.loadData(forUserID: userID)
        }
        .onChange(of: viewModel.timeframeOption) { _ in
            Task {
                await viewModel.loadData(forUserID: userID)
            }
        }
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.red)
            Text("Error loading data")
                .font(.headline)
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Chart View
private struct ChartView: View {
    let data: [BarData]
    let selectedTimeframe: TimeframeOption
    let selectedDataTypes: Set<DataType>
    @Binding var selectedBarData: BarData?
    
    var body: some View {
        Chart {
            ForEach(data.suffix(4)) { item in
                if selectedDataTypes.contains(.income) {
                    BarMark(
                        x: .value("Period", item.period),
                        y: .value("Income", item.income)
                    )
                    .foregroundStyle(DataType.income.color)
                }
                
                if selectedDataTypes.contains(.expenses) {
                    BarMark(
                        x: .value("Period", item.period),
                        y: .value("Expenses", item.expenses)
                    )
                    .foregroundStyle(DataType.expenses.color)
                }
                
                if selectedDataTypes.contains(.savings) {
                    BarMark(
                        x: .value("Period", item.period),
                        y: .value("Savings", item.savings)
                    )
                    .foregroundStyle(DataType.savings.color)
                }
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(doubleValue, format: .currency(code: "USD"))
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                guard let index = proxy.value(atX: x, as: String.self) else { return }
                                if let barData = data.first(where: { $0.period == index }) {
                                    selectedBarData = barData
                                }
                            }
                            .onEnded { _ in
                                selectedBarData = nil
                            }
                    )
            }
        }
    }
}

// MARK: - Legend View
private struct LegendView: View {
    @Binding var selectedDataTypes: Set<DataType>
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(DataType.allCases, id: \.self) { type in
                Button(action: {
                    if selectedDataTypes.contains(type) {
                        if selectedDataTypes.count > 1 {
                            selectedDataTypes.remove(type)
                        }
                    } else {
                        selectedDataTypes.insert(type)
                    }
                }) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(type.color)
                            .frame(width: 12, height: 12)
                        Text(type.rawValue)
                            .foregroundColor(.primary)
                        
                        if selectedDataTypes.contains(type) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Selected Bar Detail View
private struct SelectedBarDetailView: View {
    let data: BarData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(data.period)
                .font(.headline)
            
            VStack(spacing: 8) {
                DetailRow(title: "Income", amount: data.income, color: DataType.income.color)
                DetailRow(title: "Expenses", amount: data.expenses, color: DataType.expenses.color)
                DetailRow(title: "Savings", amount: data.savings, color: DataType.savings.color)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct DetailRow: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
            Spacer()
            Text(amount, format: .currency(code: "USD"))
                .fontWeight(.medium)
        }
    }
} 
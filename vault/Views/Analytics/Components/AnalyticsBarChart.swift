import SwiftUI
import Charts

struct AnalyticsBarChart: View {
    let data: [BarData]
    let selectedTimeframe: TimeframeOption
    let selectedDataTypes: Set<DataType>
    @Binding var selectedBarData: BarData?
    
    private var yAxisRange: ClosedRange<Double> {
        let values = data.flatMap { barData in
            [
                selectedDataTypes.contains(.income) ? barData.income : nil,
                selectedDataTypes.contains(.expenses) ? barData.expenses : nil,
                selectedDataTypes.contains(.savings) ? barData.savings : nil
            ].compactMap { $0 }
        }
        
        guard !values.isEmpty else { return 0...100 }
        
        let maxValue = values.max() ?? 0
        let minValue = values.min() ?? 0
        
        // Add 20% padding on both ends for better visual appearance
        let topPadding = maxValue * 0.2
        let bottomPadding = minValue * 0.2
        
        let paddedMax = maxValue + abs(topPadding)
        let paddedMin = minValue - abs(bottomPadding)
        
        // Round to nearest thousand for cleaner axis values
        let roundedMax = ceil(paddedMax / 1000) * 1000
        let roundedMin = floor(paddedMin / 1000) * 1000
        
        return roundedMin...roundedMax
    }
    
    var body: some View {
        GeometryReader { geometry in
            Chart {
                ForEach(data.suffix(4)) { item in
                    if selectedDataTypes.contains(.income) {
                        BarMark(
                            x: .value("Period", item.period),
                            y: .value("Income", item.income)
                        )
                        .foregroundStyle(DataType.income.color)
                        .position(by: .value("Type", "Income"))
                    }
                    
                    if selectedDataTypes.contains(.expenses) {
                        BarMark(
                            x: .value("Period", item.period),
                            y: .value("Expenses", item.expenses)
                        )
                        .foregroundStyle(DataType.expenses.color)
                        .position(by: .value("Type", "Expenses"))
                    }
                    
                    if selectedDataTypes.contains(.savings) {
                        BarMark(
                            x: .value("Period", item.period),
                            y: .value("Savings", item.savings)
                        )
                        .foregroundStyle(DataType.savings.color)
                        .position(by: .value("Type", "Savings"))
                    }
                }
                
                // Add a zero baseline rule
                RuleMark(y: .value("Zero", 0))
                    .foregroundStyle(.gray.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
            }
            .chartYScale(domain: yAxisRange)
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text(doubleValue, format: .currency(code: "USD").notation(.compactName))
                        }
                    }
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.gray.opacity(0.1))
                    .border(Color.gray.opacity(0.2))
            }
            .chartOverlay { proxy in
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
        .frame(height: 250) // Fixed height to prevent overflow
        .padding(.vertical, 8) // Add some vertical padding
    }
}

struct AnalyticsBarChart_Previews: PreviewProvider {
    static var previews: some View {
        AnalyticsBarChart(
            data: [
                BarData(period: "Jan 2024", income: 5000, expenses: -3000, savings: 2000, date: Date()),
                BarData(period: "Feb 2024", income: 5500, expenses: -3200, savings: -1300, date: Date()),
                BarData(period: "Mar 2024", income: 6000, expenses: -3500, savings: 2500, date: Date()),
                BarData(period: "Apr 2024", income: 5800, expenses: -3300, savings: 2500, date: Date())
            ],
            selectedTimeframe: .monthly,
            selectedDataTypes: Set(DataType.allCases),
            selectedBarData: .constant(nil)
        )
        .padding()
    }
} 

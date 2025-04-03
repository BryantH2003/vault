import SwiftUI

struct DashboardCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .labelStyle()
                .foregroundColor(.secondary)
            
            Text(amount.formatted(.currency(code: "USD")))
                .title1Style()
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }
}

struct OverviewCard: View {
    let title: String
    let amount: Double
    let previousAmount: Double
    let color: Color
    let leftToSpend: Double?
    
    private func calculatePercentageChange(current: Double, previous: Double) -> Double {
        guard previous != 0 else { return 0 }
        return ((current - previous) / previous) * 100
    }
    
    private func secondaryAmountColor(for amount: Double) -> Color {
        if amount < 0 {
            return .red
        } else if amount < 500 {
            return .yellow
        } else {
            return .secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .bodyMediumStyle()
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(amount.formatted(.currency(code: "USD")))
                        .title2Style()
                        .foregroundColor(.primary)
                    
                    if let leftToSpend = leftToSpend {
                        Text("Left to spend")
                            .captionStyle()
                            .foregroundColor(.secondary)
                        
                        Text(leftToSpend.formatted(.currency(code: "USD")))
                            .bodyMediumStyle()
                            .foregroundColor(secondaryAmountColor(for: leftToSpend))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    let percentageChange = calculatePercentageChange(current: amount, previous: previousAmount)
                    let isIncrease = percentageChange >= 0
                    
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: isIncrease ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(isIncrease ? color : color == .red ? .green : .red)
                        
                        Text(String(format: "%.1f%%", abs(percentageChange)))
                            .bodyMediumStyle()
                            .foregroundColor(isIncrease ? color : color == .red ? .green : .red)
                    }
                    
                    Text("Difference")
                        .captionStyle()
                        .foregroundColor(.secondary)
                    
                    Text((amount - previousAmount).formatted(.currency(code: "USD")))
                        .bodyMediumStyle()
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.blue.opacity(0.65), lineWidth: 1)
        )
    }
} 

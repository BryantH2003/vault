//
//  ExpenseSummaryRow.swift
//  vault
//
//  Created by Bryant Huynh on 4/9/25.
//
import SwiftUI

struct OverviewSummaryRow: View {
    let title: String
    let amount: Double
    let previousAmount: Double
    
    private var percentageChange: Double {
        guard previousAmount != 0 else { return amount }
        return ((amount - previousAmount) / previousAmount) * 100
    }
    
    private var difference: Double {
        amount - previousAmount
    }
    
    var body: some View {
        HStack {
            // Left side - Current amount
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .secondaryTitleStyle()
                Text(amount, format: .currency(code: "USD"))
                    .largeNumberStyle()
                
                if (title == "Expenses") {
                    Text("Left to spend: ")
                        .secondaryTitleStyle()
                }
            }
            
            Spacer()
            
            // Right side - Comparison
            VStack(alignment: .trailing, spacing: 4) {
                // Percentage change
                HStack(spacing: 4) {
                    if difference == 0 || percentageChange == 0 {
                        Text(String(format: "%.1f%%", abs(percentageChange)))
                    } else {
                        Image(systemName: difference > 0 ? "arrow.up.right" : "arrow.down.right")
                        
                        if title.contains("Expenses") {
                            Text(String(format: "%.1f%%", abs(percentageChange)))
                                .foregroundColor(difference > 0 ? .red : .green)
                        } else {
                            Text(String(format: "%.1f%%", abs(percentageChange)))
                                .foregroundColor(difference > 0 ? .green : .red)
                        }
                        
                    }
                }
                .figtreeFont(.medium, size: 14)
                
                // Actual difference
                Text(difference >= 0 ? "+\(difference, format: .currency(code: "USD"))" : "\(difference, format: .currency(code: "USD"))")
                    .figtreeFont(.medium, size: 12)
                    .foregroundColor(.secondary)
            }
        }
    }
}


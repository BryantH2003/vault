//
//  SelectedCategoryDetailCard.swift
//  vault
//
//  Created by Bryant Huynh on 4/10/25.
//
import SwiftUI

struct SelectedCategoryDetail: View {
    let data: CategoryChartData
    let previousAmount: Double
    let totalAmount: Double
    
    private var monthOverMonthChange: Double {
        guard previousAmount > 0 else {
            return data.amount > 0 ? 100 : 0
        }
        return ((data.amount - previousAmount) / previousAmount) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(data.category.categoryName)
                    .font(.headline)
                if data.category.fixedExpense {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(data.amount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Previous Month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(previousAmount, format: .currency(code: "USD"))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Change")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: monthOverMonthChange >= 0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(monthOverMonthChange >= 0 ? .red : .green)
                        Text("\(abs(Int(monthOverMonthChange)))%")
                            .foregroundColor(monthOverMonthChange >= 0 ? .red : .green)
                    }
                }
            }
            
            ProgressView(value: data.amount, total: totalAmount)
                .tint(data.category.fixedExpense ? .blue : .orange)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

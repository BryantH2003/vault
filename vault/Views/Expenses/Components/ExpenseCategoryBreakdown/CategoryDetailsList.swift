//
//  CategoryDetailsList.swift
//  vault
//
//  Created by Bryant Huynh on 4/10/25.
//
import SwiftUI

struct CategoryDetailsList: View {
    let data: [CategoryChartData]
    let previousMonthExpenses: [UUID: Double]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(data) { item in
                CategoryDetailRow(
                    category: item.category,
                    currentAmount: item.amount,
                    totalAmount: data.reduce(0) { $0 + $1.amount },
                    previousAmount: previousMonthExpenses[item.category.id] ?? 0
                )
                
                if item.id != data.last?.id {
                    Divider()
                }
            }
        }
    }
}

struct CategoryDetailRow: View {
    let category: Category
    let currentAmount: Double
    let totalAmount: Double
    let previousAmount: Double
    
    private var percentage: Double {
        totalAmount > 0 ? (currentAmount / totalAmount) * 100 : 0
    }
    
    private var monthOverMonthChange: Double {
        guard previousAmount > 0 else {
            return currentAmount > 0 ? 100 : 0 // If no previous amount but has current amount, that's a 100% increase
        }
        return ((currentAmount - previousAmount) / previousAmount) * 100
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Category Name and Current Amount
            HStack {
                Text(category.categoryName)
                    .fontWeight(.medium)
                if category.fixedExpense {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                Spacer()
                Text(currentAmount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            // Percentage and Month-over-Month comparison
            HStack {
                Text("\(Int(percentage))% of total")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
                Spacer()
                
                if currentAmount > 0 || previousAmount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: monthOverMonthChange >= 0 ? "arrow.up" : "arrow.down")
                            .foregroundColor(monthOverMonthChange >= 0 ? .red : .green)
                        
                        Text("\(abs(Int(monthOverMonthChange)))% vs last month")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
        }
    }
} 

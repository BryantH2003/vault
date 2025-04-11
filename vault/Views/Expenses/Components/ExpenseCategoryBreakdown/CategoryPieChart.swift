//
//  CategoryPieChart.swift
//  vault
//
//  Created by Bryant Huynh on 4/10/25.
//
import SwiftUI
import Charts

struct CategoryPieChart: View {
    let data: [CategoryChartData]
    @Binding var selectedCategoryID: UUID?
    
    private func sectorOpacity(for item: CategoryChartData) -> Double {
        if selectedCategoryID == nil || selectedCategoryID == item.id {
            return 1.0
        }
        return 0.3
    }
    
    var body: some View {
        ZStack {
            Chart(data) { item in
                SectorMark(
                    angle: .value("Amount", item.amount),
                    angularInset: 1.5
                )
                .foregroundStyle(item.category.fixedExpense ? .blue : .orange)
                .opacity(sectorOpacity(for: item))
                .annotation(position: .overlay) {
                    Text("\(Int(item.percentage))%")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
            
            // Overlay invisible buttons for each sector
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2
                
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    let startAngle = data.prefix(index).reduce(0) { $0 + ($1.amount / totalAmount) * 2 * .pi }
                    let endAngle = startAngle + (item.amount / totalAmount) * 2 * .pi
                    
                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                  startAngle: Angle(radians: startAngle - .pi / 2),
                                  endAngle: Angle(radians: endAngle - .pi / 2),
                                  clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(Color.clear)
                    .contentShape(Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                  startAngle: Angle(radians: startAngle - .pi / 2),
                                  endAngle: Angle(radians: endAngle - .pi / 2),
                                  clockwise: false)
                        path.closeSubpath()
                    })
                    .onTapGesture {
                        selectedCategoryID = selectedCategoryID == item.id ? nil : item.id
                    }
                }
            }
        }
    }
    
    private var totalAmount: Double {
        data.reduce(0) { $0 + $1.amount }
    }
}

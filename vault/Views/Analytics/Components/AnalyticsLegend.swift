import SwiftUI

struct AnalyticsLegend: View {
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
                            .cardRowTitleStyle()
                        
                        if selectedDataTypes.contains(type) {
                            Image(systemName: "checkmark")
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
} 

import SwiftUI

struct AnalyticsChartControls: View {
    @Binding var timeframeOption: TimeframeOption
    let isLoading: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Timeframe Selector
            Picker("Timeframe", selection: $timeframeOption) {
                Text("Monthly").tag(TimeframeOption.monthly)
                    .cardRowTitleStyle()
                Text("Yearly").tag(TimeframeOption.yearly)
                    .cardRowTitleStyle()
            }
            .pickerStyle(.segmented)
            .padding()
            
            
            // Navigation Arrows
            HStack {
                Button(action: onPrevious) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                .disabled(isLoading)
                
                Spacer()
                
                Button(action: onNext) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                .disabled(isLoading)
            }
            .padding(.horizontal, 40)
        }
    }
} 

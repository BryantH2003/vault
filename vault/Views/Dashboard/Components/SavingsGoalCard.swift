import SwiftUI

struct SavingsGoalCard: View {
    let goal: SavingsGoal
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.goalName)
                    .font(.headline)
                Spacer()
                Text(goal.targetAmount, format: .currency(code: "USD"))
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: progress)
                    .tint(.blue)
                
                HStack {
                    Text("Current: ")
                        .foregroundColor(.secondary)
                    Text(goal.currentAmount, format: .currency(code: "USD"))
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .foregroundColor(.blue)
                        .fontWeight(.semibold)
                }
                
                if let targetDate = goal.targetDate {
                    HStack {
                        Text("Target Date:")
                            .foregroundColor(.secondary)
                        Text(targetDate, style: .date)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 
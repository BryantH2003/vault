//
//  AddExpenseSplitExpenseSection.swift
//  vault
//
//  Created by Bryant Huynh on 4/20/25.
//
import SwiftUI

struct SplitWithSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    let userID: UUID
    
    var body: some View {
        Section("Split with") {
            if viewModel.isLoadingUsers {
                ProgressView()
            } else if viewModel.users.isEmpty {
                Text("No users available")
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 16) {
                    SearchBarFriendsList(text: $viewModel.searchQuery)
                        .onChange(of: viewModel.searchQuery) { _ in
                            viewModel.filterUsers()
                        }
                    
                    if !viewModel.searchQuery.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.filteredUsers) { user in
                                    if !viewModel.selectedParticipants.contains(user.id) {
                                        FriendCard(
                                            user: user,
                                            isSelected: false,
                                            onSelect: {
                                                viewModel.toggleParticipant(user.id)
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    
                    // Always show the split section once it's activated
                    if viewModel.showSplitSection {
                        SplitTypeSelector(viewModel: viewModel)
                        
                        VStack(spacing: 12) {
                            // Current user card
                            ParticipantAmountCard(
                                title: "You",
                                subtitle: "Current User",
                                amount: $viewModel.currentUserAmount,
                                isEditable: viewModel.splitType == .custom,
                                onRemove: nil
                            )
                            
                            // Selected friends cards
                            ForEach(Array(viewModel.selectedParticipants), id: \.self) { participantID in
                                if let user = viewModel.users.first(where: { $0.id == participantID }) {
                                    ParticipantAmountCard(
                                        title: user.username,
                                        subtitle: user.fullName,
                                        amount: viewModel.getParticipantAmountBinding(for: participantID),
                                        isEditable: viewModel.splitType == .custom,
                                        onRemove: {
                                            withAnimation {
                                                viewModel.removeParticipant(participantID)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                        
                        if viewModel.splitType == .custom {
                            CustomAmountSummary(viewModel: viewModel)
                        }
                    }
                }
            }
        }
    }
}

private struct SplitTypeSelector: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Type")
                .font(.headline)
            
            Picker("Split Type", selection: $viewModel.splitType) {
                Text("Split Evenly").tag(ExpenseType.SplitType.even)
                Text("Custom Amounts").tag(ExpenseType.SplitType.custom)
            }
            .pickerStyle(SegmentedPickerStyle())
            .onChange(of: viewModel.splitType) { _ in
                viewModel.updateAmountsForSplitType()
            }
        }
    }
}

private struct ParticipantAmountCard: View {
    let title: String
    let subtitle: String
    @Binding var amount: Double
    let isEditable: Bool
    let onRemove: (() -> Void)?
    
    var body: some View {
        HStack {
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .buttonStyle(BorderlessButtonStyle())
                .padding(.trailing, 8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isEditable {
                TextField("Amount", value: $amount, format: .currency(code: "USD"))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .onChange(of: amount) { newValue in
                        // Limit to 2 decimal places
                        amount = (newValue * 100).rounded() / 100
                    }
            } else {
                Text(amount, format: .currency(code: "USD"))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

private struct CustomAmountSummary: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var remainingAmount: Double {
        viewModel.amount - viewModel.getTotalCustomAmounts()
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Remaining to allocate:")
                    .font(.subheadline)
                Spacer()
                Text(remainingAmount, format: .currency(code: "USD"))
                    .foregroundColor(remainingAmount == 0 ? .primary : .red)
            }
            
            if remainingAmount > 0 {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.distributeRemainingAmount()
                    }) {
                        Text("Distribute remaining amount evenly")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderlessButtonStyle()) // Prevent tap area from expanding
                    Spacer()
                }
            }
            
            if !viewModel.isCustomAmountsValid() {
                Text("Total amounts must equal the expense amount")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.top, 8)
    }
}

private struct SearchBarFriendsList: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search friends", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

private struct FriendCard: View {
    let user: User
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.headline)
                    Text(user.fullName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

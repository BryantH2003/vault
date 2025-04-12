import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddExpenseViewModel()
    let userID: UUID
    
    var body: some View {
        NavigationView {
            Form {
                ExpenseDetailsSection(viewModel: viewModel)
                CategorySection(viewModel: viewModel)
                SplitToggleSection(viewModel: viewModel)
                
                if viewModel.isSplitExpense {
                    SplitWithSection(viewModel: viewModel, userID: userID)
                }
                
                SaveButtonSection(viewModel: viewModel, saveAction: saveExpense)
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .task {
                await viewModel.loadCategories()
                await viewModel.loadFriends(forUserID: userID)
            }
            .interactiveDismissDisabled(viewModel.isSaving)
        }
    }
    
    private func saveExpense() {
        Task {
            if await viewModel.saveExpense(userID: userID) {
                dismiss()
            }
        }
    }
}

// MARK: - Subviews

private struct ExpenseDetailsSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section("Expense Details") {
            TextField("Expense Title", text: $viewModel.title)
            
            TextField("Amount", value: $viewModel.amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            
            TextField("Vendor (Optional)", text: $viewModel.vendor)
            
            DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
        }
    }
}

private struct CategorySection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section("Category") {
            if viewModel.isLoadingCategories {
                ProgressView()
            } else if viewModel.categories.isEmpty {
                Text("No categories available")
                    .foregroundColor(.secondary)
            } else {
                Picker("Category", selection: $viewModel.selectedCategoryID) {
                    ForEach(viewModel.categories) { category in
                        HStack {
                            Text(category.categoryName)
                            if category.fixedExpense {
                                Image(systemName: "pin.fill")
                            }
                        }
                        .tag(category.id as UUID?)
                    }
                }
            }
        }
    }
}

private struct SplitToggleSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section {
            Toggle("Split with Friends", isOn: $viewModel.isSplitExpense)
        }
    }
}

private struct SplitWithSection: View {
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
                UserSelectionList(viewModel: viewModel, userID: userID)
                if !viewModel.selectedParticipants.isEmpty {
                    SplitSummary(viewModel: viewModel)
                }
            }
        }
    }
}

private struct UserSelectionList: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    let userID: UUID
    
    var body: some View {
        VStack {
            SearchBarFriendsList(text: $viewModel.searchQuery)
                .onChange(of: viewModel.searchQuery) { _ in
                    viewModel.filterUsers()
                }
                .padding(.horizontal)
            
            if viewModel.filteredUsers.isEmpty {
                Text(viewModel.searchQuery.isEmpty ? "No friends available" : "No friends found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ForEach(viewModel.filteredUsers) { user in
                    Button(action: { viewModel.toggleParticipant(user.id) }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(user.username)
                                    .font(.headline)
                                if let fullName = user.fullName {
                                    Text(fullName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if viewModel.selectedParticipants.contains(user.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
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

private struct SplitSummary: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Split Summary")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            let totalParticipants = viewModel.selectedParticipants.count + 1
            let amountPerPerson = viewModel.amount / Double(totalParticipants)
            
            Text("Amount per person: \(amountPerPerson, format: .currency(code: "USD"))")
                .font(.subheadline)
        }
        .padding(.top, 8)
    }
}

private struct SaveButtonSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    let saveAction: () -> Void
    
    var body: some View {
        Section {
            Button(action: saveAction) {
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Save Expense")
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(viewModel.isSaving || !viewModel.isValid)
        }
    }
}

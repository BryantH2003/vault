import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddExpenseViewModel()
    let userID: UUID
    
    var body: some View {
        NavigationView {
            Form {
                ExpenseTypeSection(viewModel: viewModel)
                ExpenseDetailsSection(viewModel: viewModel)
                CategorySection(viewModel: viewModel)
                
                if viewModel.expenseType == .fixed {
                    RecurrenceSection(viewModel: viewModel)
                }
                
                if viewModel.expenseType == .shared {
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
                if viewModel.expenseType == .shared {
                    await viewModel.loadFriends(forUserID: userID)
                }
            }
            .onChange(of: viewModel.expenseType) { newType in
                Task {
                    await viewModel.loadCategories()
                    if newType == .shared {
                        await viewModel.loadFriends(forUserID: userID)
                    }
                }
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

private struct ExpenseTypeSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section {
            Picker("Expense Type", selection: $viewModel.expenseType) {
                Text("Regular Expense").tag(ExpenseType.regular)
                Text("Fixed Expense").tag(ExpenseType.fixed)
                Text("Shared Expense").tag(ExpenseType.shared)
            }
            .pickerStyle(.segmented)
        }
    }
}

private struct ExpenseDetailsSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section("Expense Details") {
            TextField("Expense Title", text: $viewModel.title)
            
            TextField("Amount", value: $viewModel.amount, format: .currency(code: "USD"))
                .keyboardType(.decimalPad)
            
            TextField("Vendor (Optional)", text: $viewModel.vendor)
            
            if viewModel.expenseType == .fixed {
                DatePicker("Due Date", selection: $viewModel.date, displayedComponents: [.date])
            } else {
                DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
            }
        }
    }
}

private struct RecurrenceSection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section("Recurrence") {
            Stepper("Every \(viewModel.recurrenceInterval) \(viewModel.recurrenceUnit.rawValue)\(viewModel.recurrenceInterval > 1 ? "s" : "")",
                    value: $viewModel.recurrenceInterval, in: 1...365)
            
            Picker("Recurrence Unit", selection: $viewModel.recurrenceUnit) {
                ForEach(AddExpenseViewModel.RecurrenceUnit.allCases, id: \.self) { unit in
                    Text(unit.rawValue + "s").tag(unit)
                }
            }
        }
    }
}

private struct CategorySection: View {
    @ObservedObject var viewModel: AddExpenseViewModel
    
    var body: some View {
        Section("Category") {
            if viewModel.isLoadingCategories {
                ProgressView()
            } else if viewModel.filteredCategories.isEmpty {
                Text("No categories available")
                    .foregroundColor(.secondary)
            } else {
                Picker("Category", selection: $viewModel.selectedCategoryID) {
                    ForEach(viewModel.filteredCategories) { category in
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

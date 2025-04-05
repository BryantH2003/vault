import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddExpenseViewModel()
    let userID: UUID
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $viewModel.title)
                    
                    TextField("Amount", value: $viewModel.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                    
                    TextField("Vendor (Optional)", text: $viewModel.vendor)
                    
                    DatePicker("Date", selection: $viewModel.date, displayedComponents: [.date])
                }
                
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
                
                Section {
                    Button(action: saveExpense) {
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
            }
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

@MainActor
class AddExpenseViewModel: ObservableObject {
    @Published var title = ""
    @Published var amount = 0.0
    @Published var vendor = ""
    @Published var date = Date()
    @Published var selectedCategoryID: UUID?
    @Published var categories: [Category] = []
    @Published var isLoadingCategories = false
    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let categoryService = CategoryService.shared
    private let expenseService = ExpenseService.shared
    
    var isValid: Bool {
        !title.isEmpty && amount > 0 && selectedCategoryID != nil
    }
    
    func loadCategories() async {
        isLoadingCategories = true
        do {
            categories = try await categoryService.getAllCategories()
            if let firstCategory = categories.first {
                selectedCategoryID = firstCategory.id
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoadingCategories = false
    }
    
    func saveExpense(userID: UUID) async -> Bool {
        guard isValid, let categoryID = selectedCategoryID else { return false }
        
        isSaving = true
        do {
            let expense = Expense(
                userID: userID,
                categoryID: categoryID,
                title: title,
                amount: amount,
                transactionDate: date,
                vendor: vendor.isEmpty ? nil : vendor
            )
            
            _ = try await expenseService.createExpense(expense)
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isSaving = false
            return false
        }
    }
} 

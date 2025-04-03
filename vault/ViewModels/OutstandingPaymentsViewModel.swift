import Foundation
import FirebaseFirestore

class OutstandingPaymentsViewModel: ObservableObject {
    @Published var outstandingPayments: [OutstandingPayment] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }
    
    func loadOutstandingPayments(for userId: String) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let payments = try await databaseService.getOutstandingPayments(for: userId)
                await MainActor.run {
                    self.outstandingPayments = payments
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    func updatePaymentProgress(payment: OutstandingPayment, newAmount: Double) {
        Task {
            do {
                try await databaseService.updateOutstandingPayment(payment, newAmount: newAmount)
                await MainActor.run {
                    if let index = self.outstandingPayments.firstIndex(where: { $0.uniqueKey == payment.uniqueKey }) {
                        var updatedPayment = payment
                        updatedPayment.paidAmount = newAmount
                        updatedPayment.updatedAt = Date()
                        self.outstandingPayments[index] = updatedPayment
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
} 

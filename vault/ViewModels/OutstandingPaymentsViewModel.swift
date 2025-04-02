import Foundation
import SwiftUI

@MainActor
class OutstandingPaymentsViewModel: ObservableObject {
    @Published var payments: [OutstandingPayment] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let databaseService: DatabaseService
    private let userId: String
    
    init(databaseService: DatabaseService, userId: String) {
        self.databaseService = databaseService
        self.userId = userId
    }
    
    func loadPayments() async {
        isLoading = true
        error = nil
        
        do {
            payments = try await databaseService.getOutstandingPayments(for: userId)
        } catch {
            self.error = error
            print("Error loading payments: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func addPayment(title: String, totalAmount: Double, paidAmount: Double, dueDate: Date, category: String, notes: String?) async {
        let payment = OutstandingPayment(
            uniqueKey: UUID().uuidString,
            userId: userId,
            title: title,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            dueDate: dueDate,
            category: category,
            notes: notes,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await databaseService.createOutstandingPayment(payment)
            await loadPayments()
        } catch {
            self.error = error
            print("Error adding payment: \(error.localizedDescription)")
        }
    }
    
    func updatePayment(_ payment: OutstandingPayment, title: String, totalAmount: Double, paidAmount: Double, dueDate: Date?, category: String, notes: String?) {
        let updatedPayment = OutstandingPayment(
            uniqueKey: payment.uniqueKey,
            userId: payment.userId,
            title: title,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            dueDate: dueDate,
            category: category,
            notes: notes,
            createdAt: payment.createdAt,
            updatedAt: Date()
        )
        
        Task {
            do {
                try await databaseService.updateOutstandingPayment(updatedPayment)
                await MainActor.run {
                    if let index = payments.firstIndex(where: { $0.uniqueKey == payment.uniqueKey }) {
                        payments[index] = updatedPayment
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func deletePayment(_ paymentId: String) async {
        do {
            try await databaseService.deleteOutstandingPayment(paymentId)
            await loadPayments()
        } catch {
            self.error = error
            print("Error deleting payment: \(error.localizedDescription)")
        }
    }
} 

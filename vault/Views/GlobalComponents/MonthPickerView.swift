//
//  MonthPickerView.swift
//  vault
//
//  Created by Bryant Huynh on 4/9/25.
//
import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Binding var showPicker: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Available years (5 years back, 2 years forward)
    private let years: [Int] = {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((currentYear-5)...(currentYear+2))
    }()
    
    // All months
    private let months = Calendar.current.monthSymbols
    
    // Selected components
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    
    init(selectedDate: Binding<Date>, showPicker: Binding<Bool>) {
        _selectedDate = selectedDate
        _showPicker = showPicker
        
        let calendar = Calendar.current
        _selectedYear = State(initialValue: calendar.component(.year, from: selectedDate.wrappedValue))
        _selectedMonth = State(initialValue: calendar.component(.month, from: selectedDate.wrappedValue) - 1)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    // Month Picker
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(0..<months.count, id: \.self) { index in
                            Text(months[index])
                                .figtreeFont(.regular, size: 16)
                                .tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: UIScreen.main.bounds.width * 0.5)
                    
                    // Year Picker
                    Picker("Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { year in
                            Text(String(year))
                                .figtreeFont(.regular, size: 16)
                                .tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                }
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        updateSelectedDate()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func updateSelectedDate() {
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth + 1
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}

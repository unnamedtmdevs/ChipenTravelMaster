//
//  ExpenseTrackerView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct ExpenseTrackerView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @AppStorage("preferredCurrency") private var currency = "USD"
    
    @State private var showingAddExpense = false
    @State private var selectedCategory: String = "All"
    
    var filteredExpenses: [ExpenseEntity] {
        if selectedCategory == "All" {
            return viewModel.expenses
        }
        return viewModel.expenses.filter { $0.category == selectedCategory }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Total Expenses Card
                        VStack(spacing: 10) {
                            Text("Total Expenses")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text(formatCurrency(viewModel.totalExpenses()))
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "fcc418"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Category Breakdown
                        if !viewModel.expenses.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("By Category")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                CategoryChart(categoryData: viewModel.expensesByCategory(), currency: currency)
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Category Filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryFilterButton(title: "All", isSelected: selectedCategory == "All") {
                                    selectedCategory = "All"
                                }
                                
                                ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                    CategoryFilterButton(
                                        title: category.rawValue,
                                        isSelected: selectedCategory == category.rawValue
                                    ) {
                                        selectedCategory = category.rawValue
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Expenses List
                        if filteredExpenses.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "dollarsign.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(Color(hex: "fcc418"))
                                
                                Text("No expenses yet")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("Start tracking your travel spending")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredExpenses, id: \.id) { expense in
                                    ExpenseRow(expense: expense, currency: currency)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteExpense(expense)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Expense Tracker")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "fcc418"))
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

struct CategoryChart: View {
    let categoryData: [String: Double]
    let currency: String
    
    var total: Double {
        categoryData.values.reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(categoryData.sorted(by: { $0.value > $1.value }), id: \.key) { category, amount in
                HStack {
                    // Category info
                    HStack(spacing: 8) {
                        if let expenseCategory = ExpenseCategory.allCases.first(where: { $0.rawValue == category }) {
                            Image(systemName: expenseCategory.icon)
                                .foregroundColor(Color(hex: "fcc418"))
                                .frame(width: 25)
                        }
                        
                        Text(category)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(formatCurrency(amount))
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(hex: "3cc45b"))
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color(hex: "fcc418"))
                            .frame(width: geometry.size.width * (amount / total), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? Color(hex: "3e4464") : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "fcc418") : Color.white.opacity(0.1))
                .cornerRadius(20)
        }
    }
}

struct ExpenseRow: View {
    let expense: ExpenseEntity
    let currency: String
    
    var category: ExpenseCategory? {
        ExpenseCategory.allCases.first { $0.rawValue == expense.category }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: category?.icon ?? "dollarsign.circle.fill")
                .font(.title2)
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 40)
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.category)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                if let notes = expense.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(expense.amount))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "3cc45b"))
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @AppStorage("preferredCurrency") private var currency = "USD"
    @Environment(\.dismiss) var dismiss
    
    @State private var amount = ""
    @State private var selectedCategory = ExpenseCategory.food
    @State private var date = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Amount")) {
                        HStack {
                            Text(currencySymbol)
                                .foregroundColor(.white.opacity(0.6))
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    Section(header: Text("Category")) {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(ExpenseCategory.allCases, id: \.self) { category in
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Notes (Optional)")) {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let amountValue = Double(amount) {
                            viewModel.addExpense(
                                amount: amountValue,
                                category: selectedCategory,
                                date: date,
                                notes: notes.isEmpty ? nil : notes
                            )
                            dismiss()
                        }
                    }
                    .foregroundColor(Color(hex: "3cc45b"))
                    .disabled(amount.isEmpty || Double(amount) == nil)
                }
            }
        }
    }
    
    private var currencySymbol: String {
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.currencyCode.rawValue: currency]))
        return locale.currencySymbol ?? "$"
    }
}

#Preview {
    ExpenseTrackerView()
}


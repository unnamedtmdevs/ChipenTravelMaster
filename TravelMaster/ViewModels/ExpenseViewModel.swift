//
//  ExpenseViewModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData
import Combine

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [ExpenseEntity] = []
    
    private let dataService = DataService.shared
    
    init() {
        fetchExpenses()
    }
    
    func fetchExpenses() {
        let request: NSFetchRequest<ExpenseEntity> = ExpenseEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ExpenseEntity.date, ascending: false)]
        
        do {
            expenses = try dataService.viewContext.fetch(request)
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }
    
    func addExpense(amount: Double, category: ExpenseCategory, date: Date, notes: String?, trip: TripEntity? = nil) {
        _ = dataService.createExpense(for: trip, amount: amount, category: category.rawValue, date: date, notes: notes)
        fetchExpenses()
    }
    
    func deleteExpense(_ expense: ExpenseEntity) {
        dataService.deleteExpense(expense)
        fetchExpenses()
    }
    
    func totalExpenses() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    func expensesByCategory() -> [String: Double] {
        var categoryTotals: [String: Double] = [:]
        for expense in expenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }
        return categoryTotals
    }
}


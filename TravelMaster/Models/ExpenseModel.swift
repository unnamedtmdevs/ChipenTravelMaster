//
//  ExpenseModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData

@objc(ExpenseEntity)
public class ExpenseEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var date: Date
    @NSManaged public var notes: String?
    @NSManaged public var trip: TripEntity?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        amount = 0.0
        category = "Other"
        date = Date()
    }
}

extension ExpenseEntity {
    static func fetchRequest() -> NSFetchRequest<ExpenseEntity> {
        return NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
    }
}

struct Expense: Identifiable, Codable {
    var id: UUID
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String?
    
    init(id: UUID = UUID(), amount: Double, category: ExpenseCategory, date: Date, notes: String? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
}

enum ExpenseCategory: String, CaseIterable, Codable {
    case food = "Food"
    case transport = "Transport"
    case accommodation = "Accommodation"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .accommodation: return "bed.double.fill"
        case .entertainment: return "ticket.fill"
        case .shopping: return "bag.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}


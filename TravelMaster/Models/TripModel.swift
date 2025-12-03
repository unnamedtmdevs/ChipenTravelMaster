//
//  TripModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData

@objc(TripEntity)
public class TripEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var destination: String
    @NSManaged public var startDate: Date
    @NSManaged public var endDate: Date
    @NSManaged public var notes: String?
    @NSManaged public var activities: NSSet?
    @NSManaged public var expenses: NSSet?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        name = ""
        destination = ""
        startDate = Date()
        endDate = Date()
    }
}

extension TripEntity {
    static func fetchRequest() -> NSFetchRequest<TripEntity> {
        return NSFetchRequest<TripEntity>(entityName: "TripEntity")
    }
    
    var activitiesArray: [ActivityEntity] {
        let set = activities as? Set<ActivityEntity> ?? []
        return set.sorted {
            $0.date < $1.date
        }
    }
    
    var expensesArray: [ExpenseEntity] {
        let set = expenses as? Set<ExpenseEntity> ?? []
        return set.sorted {
            $0.date > $1.date
        }
    }
}

@objc(ActivityEntity)
public class ActivityEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var date: Date
    @NSManaged public var time: Date?
    @NSManaged public var location: String?
    @NSManaged public var notes: String?
    @NSManaged public var trip: TripEntity?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        name = ""
        date = Date()
    }
}

extension ActivityEntity {
    static func fetchRequest() -> NSFetchRequest<ActivityEntity> {
        return NSFetchRequest<ActivityEntity>(entityName: "ActivityEntity")
    }
}

struct Trip: Identifiable, Codable {
    var id: UUID
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var notes: String?
    
    init(id: UUID = UUID(), name: String, destination: String, startDate: Date, endDate: Date, notes: String? = nil) {
        self.id = id
        self.name = name
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.notes = notes
    }
}


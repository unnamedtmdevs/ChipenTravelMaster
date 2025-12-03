//
//  DataService.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData

class DataService {
    static let shared = DataService()
    private let persistenceController: PersistenceController
    
    private init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    var viewContext: NSManagedObjectContext {
        persistenceController.container.viewContext
    }
    
    func save() {
        let context = viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Error saving context: \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Trip Operations
    
    func createTrip(name: String, destination: String, startDate: Date, endDate: Date, notes: String?) -> TripEntity {
        let trip = TripEntity(context: viewContext)
        trip.id = UUID()
        trip.name = name
        trip.destination = destination
        trip.startDate = startDate
        trip.endDate = endDate
        trip.notes = notes
        save()
        return trip
    }
    
    func deleteTrip(_ trip: TripEntity) {
        viewContext.delete(trip)
        save()
    }
    
    // MARK: - Activity Operations
    
    func createActivity(for trip: TripEntity, name: String, date: Date, time: Date?, location: String?, notes: String?) -> ActivityEntity {
        let activity = ActivityEntity(context: viewContext)
        activity.id = UUID()
        activity.name = name
        activity.date = date
        activity.time = time
        activity.location = location
        activity.notes = notes
        activity.trip = trip
        save()
        return activity
    }
    
    func deleteActivity(_ activity: ActivityEntity) {
        viewContext.delete(activity)
        save()
    }
    
    // MARK: - Expense Operations
    
    func createExpense(for trip: TripEntity?, amount: Double, category: String, date: Date, notes: String?) -> ExpenseEntity {
        let expense = ExpenseEntity(context: viewContext)
        expense.id = UUID()
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.notes = notes
        expense.trip = trip
        save()
        return expense
    }
    
    func deleteExpense(_ expense: ExpenseEntity) {
        viewContext.delete(expense)
        save()
    }
    
    // MARK: - Journal Operations
    
    func createJournalEntry(title: String, content: String, date: Date, location: String?, photoData: Data?) -> JournalEntryEntity {
        let entry = JournalEntryEntity(context: viewContext)
        entry.id = UUID()
        entry.title = title
        entry.content = content
        entry.date = date
        entry.location = location
        entry.photoData = photoData
        save()
        return entry
    }
    
    func deleteJournalEntry(_ entry: JournalEntryEntity) {
        viewContext.delete(entry)
        save()
    }
    
    // MARK: - Itinerary Operations (UserDefaults)
    
    private let itineraryItemsKey = "itineraryItems"
    
    func loadItineraryItems() -> [ItineraryItem] {
        guard let data = UserDefaults.standard.data(forKey: itineraryItemsKey),
              let items = try? JSONDecoder().decode([ItineraryItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func saveItineraryItems(_ items: [ItineraryItem]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: itineraryItemsKey)
        }
    }
    
    // MARK: - Delete All Data
    
    func deleteAllData() {
        let entities = ["TripEntity", "ActivityEntity", "ExpenseEntity", "JournalEntryEntity"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try viewContext.execute(batchDeleteRequest)
                save()
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        
        // Delete itinerary items
        UserDefaults.standard.removeObject(forKey: itineraryItemsKey)
    }
}


//
//  PersistenceController.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TravelMaster")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<3 {
            let trip = TripEntity(context: viewContext)
            trip.id = UUID()
            trip.name = "Trip \(i + 1)"
            trip.destination = "City \(i + 1)"
            trip.startDate = Date().addingTimeInterval(TimeInterval(i * 86400))
            trip.endDate = Date().addingTimeInterval(TimeInterval((i + 5) * 86400))
            trip.notes = "Sample notes for trip \(i + 1)"
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
}


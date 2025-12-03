//
//  ItineraryViewModel.swift
//  Chipen Travel Master
//

import Foundation
import Combine

class ItineraryViewModel: ObservableObject {
    @Published var itineraryItems: [ItineraryItem] = []
    private let dataService = DataService.shared
    
    init() {
        loadItineraryItems()
    }
    
    func loadItineraryItems() {
        itineraryItems = dataService.loadItineraryItems()
    }
    
    func addItineraryItem(_ item: ItineraryItem) {
        itineraryItems.append(item)
        dataService.saveItineraryItems(itineraryItems)
    }
    
    func updateItineraryItem(_ item: ItineraryItem) {
        if let index = itineraryItems.firstIndex(where: { $0.id == item.id }) {
            itineraryItems[index] = item
            dataService.saveItineraryItems(itineraryItems)
        }
    }
    
    func deleteItineraryItem(_ item: ItineraryItem) {
        itineraryItems.removeAll { $0.id == item.id }
        dataService.saveItineraryItems(itineraryItems)
    }
    
    func toggleCompleted(_ item: ItineraryItem) {
        var updatedItem = item
        updatedItem.completed.toggle()
        updateItineraryItem(updatedItem)
    }
    
    func itemsForTrip(_ tripId: UUID) -> [ItineraryItem] {
        return itineraryItems
            .filter { $0.tripId == tripId }
            .sorted { $0.date < $1.date }
    }
}


//
//  TripViewModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData
import Combine

class TripViewModel: ObservableObject {
    @Published var trips: [TripEntity] = []
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTrips()
    }
    
    func fetchTrips() {
        let request: NSFetchRequest<TripEntity> = TripEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TripEntity.startDate, ascending: false)]
        
        do {
            trips = try dataService.viewContext.fetch(request)
        } catch {
            print("Error fetching trips: \(error)")
        }
    }
    
    func addTrip(name: String, destination: String, startDate: Date, endDate: Date, notes: String?) {
        _ = dataService.createTrip(name: name, destination: destination, startDate: startDate, endDate: endDate, notes: notes)
        fetchTrips()
    }
    
    func updateTrip(_ trip: TripEntity, name: String, destination: String, startDate: Date, endDate: Date, notes: String?) {
        trip.name = name
        trip.destination = destination
        trip.startDate = startDate
        trip.endDate = endDate
        trip.notes = notes
        dataService.save()
        fetchTrips()
    }
    
    func deleteTrip(_ trip: TripEntity) {
        dataService.deleteTrip(trip)
        fetchTrips()
    }
    
    func addActivity(to trip: TripEntity, name: String, date: Date, time: Date?, location: String?, notes: String?) {
        _ = dataService.createActivity(for: trip, name: name, date: date, time: time, location: location, notes: notes)
        fetchTrips()
    }
    
    func deleteActivity(_ activity: ActivityEntity) {
        dataService.deleteActivity(activity)
        fetchTrips()
    }
}


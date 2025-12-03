//
//  JournalViewModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData
import UIKit
import Combine

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntryEntity] = []
    
    private let dataService = DataService.shared
    
    init() {
        fetchEntries()
    }
    
    func fetchEntries() {
        let request: NSFetchRequest<JournalEntryEntity> = JournalEntryEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntryEntity.date, ascending: false)]
        
        do {
            entries = try dataService.viewContext.fetch(request)
        } catch {
            print("Error fetching journal entries: \(error)")
        }
    }
    
    func addEntry(title: String, content: String, date: Date, location: String?, photo: UIImage?) {
        let photoData = photo?.jpegData(compressionQuality: 0.8)
        _ = dataService.createJournalEntry(title: title, content: content, date: date, location: location, photoData: photoData)
        fetchEntries()
    }
    
    func updateEntry(_ entry: JournalEntryEntity, title: String, content: String, location: String?, photo: UIImage?) {
        entry.title = title
        entry.content = content
        entry.location = location
        if let photo = photo {
            entry.photoData = photo.jpegData(compressionQuality: 0.8)
        }
        dataService.save()
        fetchEntries()
    }
    
    func deleteEntry(_ entry: JournalEntryEntity) {
        dataService.deleteJournalEntry(entry)
        fetchEntries()
    }
}


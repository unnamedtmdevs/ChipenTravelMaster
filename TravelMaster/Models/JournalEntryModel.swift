//
//  JournalEntryModel.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import Foundation
import CoreData
import UIKit

@objc(JournalEntryEntity)
public class JournalEntryEntity: NSManagedObject, Identifiable {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var content: String
    @NSManaged public var date: Date
    @NSManaged public var location: String?
    @NSManaged public var photoData: Data?
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        title = ""
        content = ""
        date = Date()
    }
}

extension JournalEntryEntity {
    static func fetchRequest() -> NSFetchRequest<JournalEntryEntity> {
        return NSFetchRequest<JournalEntryEntity>(entityName: "JournalEntryEntity")
    }
    
    var photo: UIImage? {
        get {
            guard let data = photoData else { return nil }
            return UIImage(data: data)
        }
        set {
            photoData = newValue?.jpegData(compressionQuality: 0.8)
        }
    }
}

struct JournalEntry: Identifiable, Codable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var location: String?
    
    init(id: UUID = UUID(), title: String, content: String, date: Date, location: String? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.location = location
    }
}


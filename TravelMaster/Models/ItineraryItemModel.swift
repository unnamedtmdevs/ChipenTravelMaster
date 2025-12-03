//
//  ItineraryItemModel.swift
//  Chipen Travel Master
//

import Foundation

struct ItineraryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var tripId: UUID
    var title: String
    var location: String
    var date: Date
    var time: String
    var category: ItineraryCategory
    var notes: String
    var completed: Bool
    
    enum ItineraryCategory: String, Codable, CaseIterable {
        case transportation = "Transportation"
        case accommodation = "Accommodation"
        case activity = "Activity"
        case dining = "Dining"
        case sightseeing = "Sightseeing"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .transportation: return "airplane"
            case .accommodation: return "bed.double.fill"
            case .activity: return "figure.walk"
            case .dining: return "fork.knife"
            case .sightseeing: return "binoculars.fill"
            case .other: return "star.fill"
            }
        }
    }
}


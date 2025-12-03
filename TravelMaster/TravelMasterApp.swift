//
//  TravelMasterApp.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

@main
struct TravelMasterApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

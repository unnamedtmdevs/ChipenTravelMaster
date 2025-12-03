//
//  ContentView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
    }
    
    var mainTabView: some View {
        TabView(selection: $selectedTab) {
            PlannerView()
                .tabItem {
                    Label("Planner", systemImage: "map.fill")
                }
                .tag(0)
            
            ItineraryView()
                .tabItem {
                    Label("Itinerary", systemImage: "list.bullet.clipboard")
                }
                .tag(1)
            
            ExpenseTrackerView()
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle.fill")
                }
                .tag(2)
            
            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "book.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .accentColor(Color(hex: "fcc418"))
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

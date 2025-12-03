//
//  SettingsView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("preferredCurrency") private var preferredCurrency = "USD"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    @State private var showingDeleteAlert = false
    @State private var showingResetOnboardingAlert = false
    @State private var tempUserName = ""
    
    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "RUB"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                Form {
                    // Profile Section
                    Section(header: Text("Profile")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Your Name", text: $userName)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    // Preferences Section
                    Section(header: Text("Preferences")) {
                        Picker("Currency", selection: $preferredCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                    }
                    
                    // App Information
                    Section(header: Text("About")) {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("App Category")
                            Spacer()
                            Text("Travel")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Data Management
                    Section(header: Text("Data Management")) {
                        Button(action: {
                            showingResetOnboardingAlert = true
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Onboarding")
                            }
                            .foregroundColor(Color(hex: "fcc418"))
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete All Data")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    // Help & Support
                    Section(header: Text("Help & Support")) {
                        Link(destination: URL(string: "https://www.apple.com/support/")!) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                Text("Help Center")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.apple.com/legal/privacy/")!) {
                            HStack {
                                Image(systemName: "hand.raised")
                                Text("Privacy Policy")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                        }
                        
                        Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                            HStack {
                                Image(systemName: "doc.text")
                                Text("Terms of Service")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Delete All Data", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
            } message: {
                Text("This will permanently delete all your trips, expenses, and journal entries. This action cannot be undone.")
            }
            .alert("Reset Onboarding", isPresented: $showingResetOnboardingAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    hasCompletedOnboarding = false
                }
            } message: {
                Text("This will show the onboarding screens again when you restart the app.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func deleteAllData() {
        // Delete all Core Data
        DataService.shared.deleteAllData()
        
        // Reset user preferences
        userName = ""
        preferredCurrency = "USD"
        hasCompletedOnboarding = false
    }
}

#Preview {
    SettingsView()
}


//
//  OnboardingView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("preferredCurrency") private var preferredCurrency = "USD"
    @AppStorage("userName") private var userName = ""
    
    @State private var currentPage = 0
    @State private var showingPersonalization = false
    @State private var tempUserName = ""
    @State private var tempCurrency = "USD"
    
    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY", "RUB"]
    
    var body: some View {
        ZStack {
            Color(hex: "3e4464")
                .ignoresSafeArea()
            
            if !showingPersonalization {
                TabView(selection: $currentPage) {
                    OnboardingPage(
                        icon: "map.fill",
                        title: "Plan Your Journey",
                        description: "Create detailed itineraries with dates, activities, and locations. Keep everything organized in one place.",
                        accentColor: Color(hex: "fcc418")
                    )
                    .tag(0)
                    
                    OnboardingPage(
                        icon: "location.fill",
                        title: "Discover Nearby",
                        description: "Find restaurants, attractions, and points of interest wherever you go. Navigate with confidence using Apple Maps integration.",
                        accentColor: Color(hex: "3cc45b")
                    )
                    .tag(1)
                    
                    OnboardingPage(
                        icon: "dollarsign.circle.fill",
                        title: "Track Expenses",
                        description: "Monitor your spending by category and stay within budget. Get visual reports of your travel costs.",
                        accentColor: Color(hex: "fcc418")
                    )
                    .tag(2)
                    
                    OnboardingPage(
                        icon: "book.fill",
                        title: "Journal Your Adventures",
                        description: "Document your memories with photos and notes. Keep your travel stories safe and accessible offline.",
                        accentColor: Color(hex: "3cc45b")
                    )
                    .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .overlay(alignment: .bottom) {
                    VStack(spacing: 20) {
                        if currentPage == 3 {
                            Button(action: {
                                showingPersonalization = true
                            }) {
                                Text("Get Started")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "3e4464"))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "fcc418"))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 50)
                        }
                    }
                }
            } else {
                personalizationView
            }
        }
    }
    
    var personalizationView: some View {
        VStack(spacing: 30) {
            Text("Personalize Your Experience")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Enter your name", text: $tempUserName)
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Preferred Currency")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Picker("Currency", selection: $tempCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                userName = tempUserName
                preferredCurrency = tempCurrency
                hasCompletedOnboarding = true
            }) {
                Text("Complete Setup")
                    .font(.headline)
                    .foregroundColor(Color(hex: "3e4464"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "3cc45b"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .padding(.top, 100)
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 100))
                .foregroundColor(accentColor)
            
            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}


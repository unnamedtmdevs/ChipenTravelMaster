//
//  PlannerView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI

struct PlannerView: View {
    @StateObject private var viewModel = TripViewModel()
    @State private var showingAddTrip = false
    @State private var selectedTrip: TripEntity?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                if viewModel.trips.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "fcc418"))
                        
                        Text("No Trips Yet")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Start planning your next adventure!")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(action: { showingAddTrip = true }) {
                            Label("Create Your First Trip", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "3e4464"))
                                .padding()
                                .background(Color(hex: "fcc418"))
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.trips, id: \.id) { trip in
                                TripCard(trip: trip)
                                    .onTapGesture {
                                        selectedTrip = trip
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Travel Planner")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTrip = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "fcc418"))
                    }
                }
            }
            .sheet(isPresented: $showingAddTrip) {
                AddTripView(viewModel: viewModel)
            }
            .sheet(item: $selectedTrip) { trip in
                TripDetailView(trip: trip, viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TripCard: View {
    let trip: TripEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(trip.destination)
                            .font(.system(size: 14, design: .rounded))
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack {
                Label(trip.startDate.formatted(date: .abbreviated, time: .omitted),
                      systemImage: "calendar")
                
                Image(systemName: "arrow.right")
                
                Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
            }
            .font(.caption)
            .foregroundColor(.white.opacity(0.7))
            
            if let notes = trip.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AddTripView: View {
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(86400 * 7)
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Trip Details")) {
                        TextField("Trip Name", text: $name)
                        TextField("Destination", text: $destination)
                    }
                    
                    Section(header: Text("Dates")) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Notes")) {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addTrip(
                            name: name,
                            destination: destination,
                            startDate: startDate,
                            endDate: endDate,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "3cc45b"))
                    .disabled(name.isEmpty || destination.isEmpty)
                }
            }
        }
    }
}

struct TripDetailView: View {
    let trip: TripEntity
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingAddActivity = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Trip Info
                        VStack(alignment: .leading, spacing: 10) {
                            Text(trip.destination)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "fcc418"))
                            
                            HStack {
                                Image(systemName: "calendar")
                                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            
                            if let notes = trip.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.7))
                                    .padding(.top, 5)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Activities
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Activities")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: { showingAddActivity = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(Color(hex: "3cc45b"))
                                        .font(.title2)
                                }
                            }
                            
                            if trip.activitiesArray.isEmpty {
                                Text("No activities yet. Add your first activity!")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .padding()
                            } else {
                                ForEach(trip.activitiesArray, id: \.id) { activity in
                                    ActivityRow(activity: activity)
                                }
                            }
                        }
                        .padding()
                    }
                    .padding()
                }
            }
            .navigationTitle(trip.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(trip: trip, viewModel: viewModel)
            }
            .alert("Delete Trip", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteTrip(trip)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this trip? This action cannot be undone.")
            }
        }
    }
}

struct ActivityRow: View {
    let activity: ActivityEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(activity.date.formatted(date: .abbreviated, time: .omitted))
                    if let time = activity.time {
                        Text("at \(time.formatted(date: .omitted, time: .shortened))")
                    }
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                
                if let location = activity.location {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                        Text(location)
                    }
                    .font(.caption)
                    .foregroundColor(Color(hex: "fcc418"))
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(8)
    }
}

struct AddActivityView: View {
    let trip: TripEntity
    @ObservedObject var viewModel: TripViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var date = Date()
    @State private var includeTime = false
    @State private var time = Date()
    @State private var location = ""
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Activity Details")) {
                        TextField("Activity Name", text: $name)
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                        
                        Toggle("Include Time", isOn: $includeTime)
                        if includeTime {
                            DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        }
                    }
                    
                    Section(header: Text("Location")) {
                        TextField("Location (optional)", text: $location)
                    }
                    
                    Section(header: Text("Notes")) {
                        TextEditor(text: $notes)
                            .frame(height: 80)
                    }
                }
            }
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addActivity(
                            to: trip,
                            name: name,
                            date: date,
                            time: includeTime ? time : nil,
                            location: location.isEmpty ? nil : location,
                            notes: notes.isEmpty ? nil : notes
                        )
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "3cc45b"))
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    PlannerView()
}


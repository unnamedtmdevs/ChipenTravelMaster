//
//  ItineraryView.swift
//  Chipen Travel Master
//

import SwiftUI

struct ItineraryView: View {
    @StateObject private var viewModel = ItineraryViewModel()
    @StateObject private var tripViewModel = TripViewModel()
    @State private var showingAddItem = false
    @State private var selectedTrip: TripEntity?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Trip selector
                if !tripViewModel.trips.isEmpty {
                    tripSelectorSection
                }
                
                // Itinerary list
                if let trip = selectedTrip {
                    itineraryListSection(for: trip)
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Itinerary")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if selectedTrip != nil {
                        Button(action: { showingAddItem = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                if let trip = selectedTrip {
                    AddItineraryItemView(tripId: trip.id ?? UUID(), viewModel: viewModel)
                }
            }
        }
        .onAppear {
            tripViewModel.fetchTrips()
            if selectedTrip == nil, let firstTrip = tripViewModel.trips.first {
                selectedTrip = firstTrip
            }
        }
    }
    
    private var tripSelectorSection: some View {
        Picker("Select Trip", selection: $selectedTrip) {
            ForEach(tripViewModel.trips, id: \.id) { trip in
                Text(trip.name ?? "Unnamed Trip").tag(trip as TripEntity?)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .padding()
        .background(Color(hex: "fcc418").opacity(0.1))
    }
    
    private func itineraryListSection(for trip: TripEntity) -> some View {
        let items = viewModel.itemsForTrip(trip.id ?? UUID())
        
        return Group {
            if items.isEmpty {
                emptyItineraryView
            } else {
                List {
                    ForEach(groupedItemsByDate(items).keys.sorted(), id: \.self) { date in
                        Section(header: Text(formatDateHeader(date))) {
                            ForEach(groupedItemsByDate(items)[date] ?? []) { item in
                                ItineraryItemRow(item: item, viewModel: viewModel)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Trip Selected")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Create a trip in the Planner to start building your itinerary")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyItineraryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "map")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Itinerary Items")
                .font(.title2)
                .foregroundColor(.gray)
            Text("Tap + to add your first activity")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func groupedItemsByDate(_ items: [ItineraryItem]) -> [Date: [ItineraryItem]] {
        Dictionary(grouping: items) { item in
            Calendar.current.startOfDay(for: item.date)
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}

struct ItineraryItemRow: View {
    let item: ItineraryItem
    @ObservedObject var viewModel: ItineraryViewModel
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(Color(hex: "fcc418"))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                    .strikethrough(item.completed)
                
                Text(item.location)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text(item.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text(item.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: "fcc418"))
                }
            }
            
            Spacer()
            
            Button(action: {
                viewModel.toggleCompleted(item)
            }) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(item.completed ? Color(hex: "fcc418") : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                viewModel.deleteItineraryItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditItineraryItemView(item: item, viewModel: viewModel)
        }
    }
}

struct AddItineraryItemView: View {
    @Environment(\.presentationMode) var presentationMode
    let tripId: UUID
    @ObservedObject var viewModel: ItineraryViewModel
    
    @State private var title = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var time = ""
    @State private var category: ItineraryItem.ItineraryCategory = .activity
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItineraryItem.ItineraryCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }.tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Time (e.g., 10:00 AM)", text: $time)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveItem()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    private func saveItem() {
        let item = ItineraryItem(
            tripId: tripId,
            title: title,
            location: location,
            date: date,
            time: time.isEmpty ? "All day" : time,
            category: category,
            notes: notes,
            completed: false
        )
        viewModel.addItineraryItem(item)
        presentationMode.wrappedValue.dismiss()
    }
}

struct EditItineraryItemView: View {
    @Environment(\.presentationMode) var presentationMode
    let item: ItineraryItem
    @ObservedObject var viewModel: ItineraryViewModel
    
    @State private var title: String
    @State private var location: String
    @State private var date: Date
    @State private var time: String
    @State private var category: ItineraryItem.ItineraryCategory
    @State private var notes: String
    
    init(item: ItineraryItem, viewModel: ItineraryViewModel) {
        self.item = item
        self.viewModel = viewModel
        _title = State(initialValue: item.title)
        _location = State(initialValue: item.location)
        _date = State(initialValue: item.date)
        _time = State(initialValue: item.time)
        _category = State(initialValue: item.category)
        _notes = State(initialValue: item.notes)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("Title", text: $title)
                    TextField("Location", text: $location)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItineraryItem.ItineraryCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue)
                            }.tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Time", text: $time)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty || location.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedItem = item
        updatedItem.title = title
        updatedItem.location = location
        updatedItem.date = date
        updatedItem.time = time
        updatedItem.category = category
        updatedItem.notes = notes
        viewModel.updateItineraryItem(updatedItem)
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ItineraryView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


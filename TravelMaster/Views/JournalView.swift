//
//  JournalView.swift
//  TravelMaster
//
//  Created by Simon Bakhanets on 03.12.2025.
//

import SwiftUI
import PhotosUI

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingAddEntry = false
    @State private var selectedEntry: JournalEntryEntity?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                if viewModel.entries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color(hex: "3cc45b"))
                        
                        Text("No Journal Entries")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("Start documenting your travel memories!")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Button(action: { showingAddEntry = true }) {
                            Label("Create First Entry", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .foregroundColor(Color(hex: "3e4464"))
                                .padding()
                                .background(Color(hex: "3cc45b"))
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(viewModel.entries, id: \.id) { entry in
                                JournalEntryCard(entry: entry)
                                    .onTapGesture {
                                        selectedEntry = entry
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            viewModel.deleteEntry(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Travel Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddEntry = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color(hex: "fcc418"))
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                AddJournalEntryView(viewModel: viewModel)
            }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry, viewModel: viewModel)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntryEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Photo if available
            if let photo = entry.photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(8)
            }
            
            // Title and date
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text(entry.date.formatted(date: .long, time: .omitted))
                        .font(.caption)
                }
                .foregroundColor(Color(hex: "fcc418"))
                
                if let location = entry.location, !location.isEmpty {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: "3cc45b"))
                }
            }
            
            // Content preview
            Text(entry.content)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct JournalEntryDetailView: View {
    let entry: JournalEntryEntity
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Photo
                        if let photo = entry.photo {
                            Image(uiImage: photo)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(12)
                        }
                        
                        // Title
                        Text(entry.title)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        // Metadata
                        HStack {
                            Image(systemName: "calendar")
                            Text(entry.date.formatted(date: .long, time: .omitted))
                        }
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "fcc418"))
                        
                        if let location = entry.location, !location.isEmpty {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                Text(location)
                            }
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "3cc45b"))
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        // Content
                        Text(entry.content)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .lineSpacing(6)
                    }
                    .padding()
                }
            }
            .navigationTitle("Entry Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "fcc418"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingShareSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "3cc45b"))
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [generateShareText()])
            }
        }
    }
    
    private func generateShareText() -> String {
        var text = "\(entry.title)\n\n"
        text += "📅 \(entry.date.formatted(date: .long, time: .omitted))\n"
        if let location = entry.location {
            text += "📍 \(location)\n"
        }
        text += "\n\(entry.content)"
        return text
    }
}

struct AddJournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var content = ""
    @State private var date = Date()
    @State private var location = ""
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "3e4464")
                    .ignoresSafeArea()
                
                Form {
                    Section(header: Text("Title")) {
                        TextField("Entry Title", text: $title)
                    }
                    
                    Section(header: Text("Date")) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    
                    Section(header: Text("Location (Optional)")) {
                        TextField("Where were you?", text: $location)
                    }
                    
                    Section(header: Text("Photo (Optional)")) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                            
                            Button("Remove Photo") {
                                selectedImage = nil
                            }
                            .foregroundColor(.red)
                        } else {
                            Button(action: { showingImagePicker = true }) {
                                HStack {
                                    Image(systemName: "photo")
                                    Text("Add Photo")
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Your Story")) {
                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                    }
                }
            }
            .navigationTitle("New Entry")
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
                        viewModel.addEntry(
                            title: title,
                            content: content,
                            date: date,
                            location: location.isEmpty ? nil : location,
                            photo: selectedImage
                        )
                        dismiss()
                    }
                    .foregroundColor(Color(hex: "3cc45b"))
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
    }
}

// Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    JournalView()
}


//
//  CertificateGeneratorView.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import Photos
import SwiftData

struct CertificateGeneratorView: View {
    
    let tier: Tier?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var user: User?
    @State private var selectedTemplate: CertificateTemplate
    @State private var customization = CertificateCustomization()
    @State private var generatedImage: UIImage?
    @State private var showingShareSheet = false
    @State private var showingSaveAlert = false
    @State private var isGenerating = false
    
    let templates = [
        CertificateTemplate(
            name: "Classic",
            templateDescription: "Clean and elegant design",
            previewImage: "certificate.classic"
        ),
        CertificateTemplate(
            name: "Modern",
            templateDescription: "Bold and contemporary",
            previewImage: "certificate.modern"
        ),
        CertificateTemplate(
            name: "Minimal",
            templateDescription: "Simple and refined",
            previewImage: "certificate.minimal"
        )
    ]
    
    init(tier: Tier? = nil) {
        self.tier = tier
        _selectedTemplate = State(initialValue: templates[0])
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Preview
                    previewSection
                    
                    // Templates
                    templateSection
                    
                    // Customization
                    customizationSection
                    
                    // Actions
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Create Certificate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadUser()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let image = generatedImage {
                    ShareSheet(items: [image])
                }
            }
            .alert("Saved!", isPresented: $showingSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Certificate saved to your photo library")
            }
        }
    }
    
    private var previewSection: some View {
        VStack(spacing: 12) {
            Text("Preview")
                .font(.headline)
            
            ZStack {
                if let image = generatedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .aspectRatio(9/16, contentMode: .fit)
                        .cornerRadius(12)
                        .overlay {
                            if isGenerating {
                                ProgressView()
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("Preview will appear here")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                }
            }
            
            Button {
                generateCertificate()
            } label: {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                        Text("Generate Preview")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(isGenerating || user == nil || tier == nil)
        }
    }
    
    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Template")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(templates) { template in
                        TemplateCard(
                            template: template,
                            isSelected: selectedTemplate.id == template.id
                        )
                        .onTapGesture {
                            selectedTemplate = template
                            generatedImage = nil // Reset preview
                        }
                    }
                }
            }
        }
    }
    
    private var customizationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Customization")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Background Color
                HStack {
                    Text("Background Color")
                    Spacer()
                    ColorPicker("", selection: $customization.backgroundColor)
                }
                
                Divider()
                
                // Pattern
                Toggle("Show Pattern", isOn: $customization.showPattern)
                
                Divider()
                
                // QR Code
                Toggle("Include QR Code", isOn: $customization.includeQRCode)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                saveToPhotos()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save to Photos")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(generatedImage == nil)
            
            Button {
                showingShareSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .disabled(generatedImage == nil)
        }
    }
    
    private func loadUser() {
        let descriptor = FetchDescriptor<User>()
        user = try? modelContext.fetch(descriptor).first
    }
    
    private func generateCertificate() {
        guard let tier = tier, let user = user else { return }
        
        isGenerating = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            let image = CertificateGenerator.shared.generateCertificate(
                tier: tier,
                user: user,
                template: selectedTemplate,
                customization: customization
            )
            
            DispatchQueue.main.async {
                generatedImage = image
                isGenerating = false
            }
        }
    }
    
    private func saveToPhotos() {
        guard let image = generatedImage else { return }
        
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    showingSaveAlert = true
                }
            }
        }
    }
}

struct TemplateCard: View {
    let template: CertificateTemplate
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 200)
                .overlay {
                    VStack {
                        Image(systemName: "doc.richtext")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        
                        Text(template.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 3)
                    }
                }
            
            Text(template.templateDescription)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 120)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    CertificateGeneratorView(
        tier: Tier(
            role: .marathoner,
            currentTier: .gold,
            currentGrade: 2,
            lp: 2650
        )
    )
    .modelContainer(for: [User.self, Tier.self], inMemory: true)
}

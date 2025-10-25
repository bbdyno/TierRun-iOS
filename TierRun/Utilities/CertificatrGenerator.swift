//
//  CertificatrGenerator.swift
//  TierRun
//
//  Created by tngtng on 10/25/25.
//

import Foundation
import SwiftUI
import UIKit

class CertificateGenerator {
    
    static let shared = CertificateGenerator()
    
    private init() {}
    
    func generateCertificate(
        tier: Tier,
        user: User,
        template: CertificateTemplate,
        customization: CertificateCustomization
    ) -> UIImage? {
        
        let size = CGSize(width: 1080, height: 1920) // Instagram story size
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let ctx = context.cgContext
            
            // Background
            drawBackground(ctx: ctx, size: size, customization: customization)
            
            // Tier Badge
            drawTierBadge(ctx: ctx, size: size, tier: tier)
            
            // User Name
            drawUserName(ctx: ctx, size: size, name: user.name)
            
            // Tier Name
            drawTierName(ctx: ctx, size: size, tier: tier)
            
            // Stats
            drawStats(ctx: ctx, size: size, tier: tier, user: user)
            
            // Date
            drawDate(ctx: ctx, size: size)
            
            // App Branding
            drawBranding(ctx: ctx, size: size)
            
            // QR Code (optional)
            if customization.includeQRCode {
                drawQRCode(ctx: ctx, size: size, tier: tier)
            }
        }
        
        return image
    }
    
    private func drawBackground(ctx: CGContext, size: CGSize, customization: CertificateCustomization) {
        // Gradient background
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            customization.backgroundColor.cgColor!,
            customization.backgroundColor.opacity(0.7).cgColor!
        ] as CFArray
        
        guard let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors,
            locations: [0, 1]
        ) else { return }
        
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: size.width, y: size.height),
            options: []
        )
        
        // Pattern overlay
        if customization.showPattern {
            drawPattern(ctx: ctx, size: size)
        }
    }
    
    private func drawPattern(ctx: CGContext, size: CGSize) {
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.05).cgColor)
        
        let circleSize: CGFloat = 100
        let spacing: CGFloat = 150
        
        for x in stride(from: -circleSize, to: size.width + circleSize, by: spacing) {
            for y in stride(from: -circleSize, to: size.height + circleSize, by: spacing) {
                ctx.fillEllipse(in: CGRect(
                    x: x,
                    y: y,
                    width: circleSize,
                    height: circleSize
                ))
            }
        }
    }
    
    private func drawTierBadge(ctx: CGContext, size: CGSize, tier: Tier) {
        let badgeSize: CGFloat = 300
        let badgeRect = CGRect(
            x: (size.width - badgeSize) / 2,
            y: 300,
            width: badgeSize,
            height: badgeSize
        )
        
        // Outer glow
        ctx.setShadow(
            offset: CGSize(width: 0, height: 0),
            blur: 40,
            color: tier.currentTier.uiColor.withAlphaComponent(0.6).cgColor
        )
        
        // Badge circle
        ctx.setFillColor(tier.currentTier.uiColor.cgColor)
        ctx.fillEllipse(in: badgeRect)
        
        // Inner circle
        ctx.setShadow(offset: .zero, blur: 0)
        ctx.setFillColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        let innerRect = badgeRect.insetBy(dx: 30, dy: 30)
        ctx.fillEllipse(in: innerRect)
        
        // Crown icon (simplified)
        drawCrownIcon(ctx: ctx, rect: badgeRect)
    }
    
    private func drawCrownIcon(ctx: CGContext, rect: CGRect) {
        let iconSize: CGFloat = 120
        let iconRect = CGRect(
            x: rect.midX - iconSize / 2,
            y: rect.midY - iconSize / 2,
            width: iconSize,
            height: iconSize
        )
        
        ctx.setFillColor(UIColor.white.cgColor)
        
        // Simple crown shape
        let path = UIBezierPath()
        path.move(to: CGPoint(x: iconRect.minX + 20, y: iconRect.maxY))
        path.addLine(to: CGPoint(x: iconRect.minX, y: iconRect.minY + 40))
        path.addLine(to: CGPoint(x: iconRect.minX + 30, y: iconRect.midY))
        path.addLine(to: CGPoint(x: iconRect.midX, y: iconRect.minY))
        path.addLine(to: CGPoint(x: iconRect.maxX - 30, y: iconRect.midY))
        path.addLine(to: CGPoint(x: iconRect.maxX, y: iconRect.minY + 40))
        path.addLine(to: CGPoint(x: iconRect.maxX - 20, y: iconRect.maxY))
        path.close()
        
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }
    
    private func drawUserName(ctx: CGContext, size: CGSize, name: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: name, attributes: attributes)
        let stringSize = attributedString.size()
        
        let rect = CGRect(
            x: (size.width - stringSize.width) / 2,
            y: 650,
            width: stringSize.width,
            height: stringSize.height
        )
        
        attributedString.draw(in: rect)
    }
    
    private func drawTierName(ctx: CGContext, size: CGSize, tier: Tier) {
        let tierText = "\(tier.currentTier.rawValue.uppercased()) \(tier.currentGrade)"
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 72, weight: .black),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: tierText, attributes: attributes)
        let stringSize = attributedString.size()
        
        let rect = CGRect(
            x: (size.width - stringSize.width) / 2,
            y: 730,
            width: stringSize.width,
            height: stringSize.height
        )
        
        attributedString.draw(in: rect)
        
        // Role subtitle
        let roleText = tier.role == .marathoner ? "Marathoner" : "Sprinter"
        let roleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .medium),
            .foregroundColor: UIColor.white.withAlphaComponent(0.8)
        ]
        
        let roleString = NSAttributedString(string: roleText, attributes: roleAttributes)
        let roleSize = roleString.size()
        
        let roleRect = CGRect(
            x: (size.width - roleSize.width) / 2,
            y: 820,
            width: roleSize.width,
            height: roleSize.height
        )
        
        roleString.draw(in: roleRect)
    }
    
    private func drawStats(ctx: CGContext, size: CGSize, tier: Tier, user: User) {
        let statsY: CGFloat = 950
        let statSpacing: CGFloat = 200
        
        // Total LP
        drawStat(
            ctx: ctx,
            x: size.width / 2 - statSpacing,
            y: statsY,
            value: "\(tier.lp)",
            label: "Total LP"
        )
        
        // Rank %
        let rankPercentage = calculateRankPercentage(tier: tier)
        drawStat(
            ctx: ctx,
            x: size.width / 2,
            y: statsY,
            value: "Top \(String(format: "%.1f", rankPercentage))%",
            label: "Rank"
        )
        
        // Season
        drawStat(
            ctx: ctx,
            x: size.width / 2 + statSpacing,
            y: statsY,
            value: "S\(getCurrentSeason())",
            label: "Season"
        )
    }
    
    private func drawStat(ctx: CGContext, x: CGFloat, y: CGFloat, value: String, label: String) {
        // Value
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedDigitSystemFont(ofSize: 36, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let valueString = NSAttributedString(string: value, attributes: valueAttributes)
        let valueSize = valueString.size()
        
        let valueRect = CGRect(
            x: x - valueSize.width / 2,
            y: y,
            width: valueSize.width,
            height: valueSize.height
        )
        
        valueString.draw(in: valueRect)
        
        // Label
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7)
        ]
        
        let labelString = NSAttributedString(string: label, attributes: labelAttributes)
        let labelSize = labelString.size()
        
        let labelRect = CGRect(
            x: x - labelSize.width / 2,
            y: y + valueSize.height + 8,
            width: labelSize.width,
            height: labelSize.height
        )
        
        labelString.draw(in: labelRect)
    }
    
    private func drawDate(ctx: CGContext, size: CGSize) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        let dateString = "Achieved on \(dateFormatter.string(from: Date()))"
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.6)
        ]
        
        let attributedString = NSAttributedString(string: dateString, attributes: attributes)
        let stringSize = attributedString.size()
        
        let rect = CGRect(
            x: (size.width - stringSize.width) / 2,
            y: 1150,
            width: stringSize.width,
            height: stringSize.height
        )
        
        attributedString.draw(in: rect)
    }
    
    private func drawBranding(ctx: CGContext, size: CGSize) {
        let brandText = "RunClimb"
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 32, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSAttributedString(string: brandText, attributes: attributes)
        let stringSize = attributedString.size()
        
        let rect = CGRect(
            x: (size.width - stringSize.width) / 2,
            y: size.height - 150,
            width: stringSize.width,
            height: stringSize.height
        )
        
        attributedString.draw(in: rect)
    }
    
    private func drawQRCode(ctx: CGContext, size: CGSize, tier: Tier) {
        // Generate QR code with tier verification data
        let qrData = "runclimb://verify/\(tier.id.uuidString)"
        
        if let qrImage = generateQRCode(from: qrData) {
            let qrSize: CGFloat = 150
            let qrRect = CGRect(
                x: size.width - qrSize - 50,
                y: size.height - qrSize - 50,
                width: qrSize,
                height: qrSize
            )
            
            qrImage.draw(in: qrRect)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else { return nil }
        
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func calculateRankPercentage(tier: Tier) -> Double {
        // Mock calculation - in real app, would query from server
        switch tier.currentTier {
        case .iron: return 95.0
        case .bronze: return 85.0
        case .silver: return 70.0
        case .gold: return 55.0
        case .platinum: return 40.0
        case .emerald: return 25.0
        case .diamond: return 15.0
        case .master: return 5.0
        case .grandmaster: return 2.0
        case .challenger: return 0.5
        }
    }
    
    private func getCurrentSeason() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = calendar.component(.month, from: Date())
        
        // 4 seasons per year (3 months each)
        let seasonInYear = (month - 1) / 3 + 1
        return (year - 2025) * 4 + seasonInYear
    }
}

// Extension for TierLevel colors
extension TierLevel {
    var uiColor: UIColor {
        switch self {
        case .iron: return UIColor.systemGray
        case .bronze: return UIColor(red: 0.8, green: 0.5, blue: 0.2, alpha: 1.0)
        case .silver: return UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        case .gold: return UIColor.systemYellow
        case .platinum: return UIColor.systemCyan
        case .emerald: return UIColor.systemGreen
        case .diamond: return UIColor.systemBlue
        case .master: return UIColor.systemPurple
        case .grandmaster: return UIColor.systemRed
        case .challenger: return UIColor.systemOrange
        }
    }
}

// Extension for Color to CGColor
extension Color {
    var cgColor: CGColor? {
        return UIColor(self).cgColor
    }
}

struct CertificateTemplate: Identifiable {
    let id = UUID()
    let name: String
    let templateDescription: String
    let previewImage: String
}

struct CertificateCustomization {
    var backgroundColor: Color = .blue
    var showPattern: Bool = true
    var includeQRCode: Bool = false
    var fontStyle: String = "System"
}

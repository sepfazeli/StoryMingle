//
//  SharedComponents.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07.
//  Updated: 2025-05-08
//

import SwiftUI

// MARK: - Text field with leading SF-Symbol
struct IconTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var keyboardType: UIKeyboardType = .default

    @FocusState private var focused: Bool

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary.opacity(0.8))

            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(AppColors.primary)
                    .focused($focused)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .foregroundColor(AppColors.primary)
                    .focused($focused)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(AppColors.background.opacity(0.15))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.primary.opacity(focused ? 0.9 : 0.3), lineWidth: 1)
        )
    }
}

// MARK: - Glass-style button label
struct GlassButtonLabel: View {
    let text: String
    var systemImage: String? = nil        // optional SF-Symbol

    var body: some View {
        Group {
            if let symbol = systemImage {
                Label(text, systemImage: symbol)
                    .labelStyle(.titleAndIcon)
            } else {
                Text(text)
            }
        }
        .font(.headline.weight(.bold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppColors.primary.opacity(0.9))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.primary.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Frosted-glass card container
extension View {
    /// Wraps its content in a frosted-glass rounded rectangle.
    @ViewBuilder
    func glassCard<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(AppColors.background.opacity(0.25), lineWidth: 0.5)
            )
    }
}

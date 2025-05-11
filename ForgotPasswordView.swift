//
//  ForgotPasswordView.swift
//  StoryMingle
//
//  Updated: 2025-05-09 – uses identifier (username / phone /)
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authVM: AuthViewModel

    @State private var identifier  = ""
    @State private var info        = ""
    @State private var showInfo    = false
    @FocusState private var typing : Bool

    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.accent, AppColors.secondary],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Text("Forgot Password?")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                glassCard {
                    VStack(spacing: 20) {
                        IconTextField(icon: "person.crop.circle",
                                      placeholder: "Username / Phone",
                                      text: $identifier,
                                      isSecure: false,
                                      keyboardType: .default)
                            .focused($typing)

                        if showInfo {
                            Text(info)
                                .font(AppFonts.caption)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }

                        Button { sendReset() } label: {
                            GlassButtonLabel(text: "Send Reset Link",
                                             systemImage: "paperplane.fill")
                        }
                        .disabled(identifier.isEmpty)
                    }
                    .padding(24)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 32)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func sendReset() {
        guard !identifier.isEmpty else { return }
        authVM.resetPassword(identifier: identifier)
        info     = "If an account exists for **\(identifier)** a reset link is on its way."
        showInfo = true
        typing   = false
    }
}

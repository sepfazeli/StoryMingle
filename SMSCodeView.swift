//
//  SMSCodeView.swift
//  StoryMingle
//

import SwiftUI

struct SMSCodeView: View {
    enum Mode { case signUp, signIn }
    
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    let mode: Mode
    let phone: String
    
    @State private var code = ""
    @FocusState private var focus: Bool
    @State private var showError = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [AppColors.accent, AppColors.primary],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                Text(mode == .signUp ? "Verify Your Phone" : "Two-Step Verification")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                
                Text("Enter the 6-digit code sent to")
                    .foregroundColor(.white.opacity(0.9))
                + Text("\n\(phone)")
                    .foregroundColor(.white).bold()
                
                glassCard {
                    VStack(spacing: 20) {
                        TextField("123456", text: $code)
                            .keyboardType(.numberPad)
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .focused($focus)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    focus = true
                                }
                            }
                        
                        if showError {
                            Text(authVM.authError ?? "")
                                .font(AppFonts.caption)
                                .foregroundColor(.black)
                        }
                        
                        Button {
                            verify()
                        } label: {
                            GlassButtonLabel(text: "Confirm", systemImage: "checkmark.seal.fill")
                        }
                        .disabled(code.count != 6)
                    }
                    .padding(24)
                }
                
                Spacer()
            }
            .padding(.horizontal, 32)
            .onReceive(authVM.$authError) { error in
                showError = error != nil
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private func verify() {
        guard code.count == 6 else {
            authVM.authError = "Please enter a valid 6-digit code"
            return
        }
        
        switch mode {
        case .signUp:
            authVM.completeSignUp(smsCode: code)      // ← no “$”
        case .signIn:
            authVM.confirmSignInCode(smsCode: code)
        }
        
        dismiss()
    }
}

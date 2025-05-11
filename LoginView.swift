//
//  LoginView.swift
//  StoryMingle
//
//  Updated 2025-05-11 – login button uses 0.1 opacity when fields incomplete but remains tappable
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject private var authVM: AuthViewModel

#if DEBUG
    @State private var identifier = "demoUser"
    @State private var password   = "StoryMingle123!"
#else
    @State private var identifier = ""
    @State private var password   = ""
#endif

    @State private var err     = ""
    @State private var showErr = false

    private var canSubmit: Bool { !identifier.isEmpty && !password.isEmpty }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [AppColors.accent, AppColors.primary],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Text("StoryMingle")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    glassCard {
                        VStack(spacing: 20) {
                            IconTextField(icon: "person.crop.circle",
                                          placeholder: "Username or Phone",
                                          text: $identifier,
                                          isSecure: false)

                            IconTextField(icon: "lock",
                                          placeholder: "Password",
                                          text: $password,
                                          isSecure: true)

                            if showErr {
                                Text(err)
                                    .font(AppFonts.caption)
                                    .foregroundColor(.black)
                            }

                            // Login Button: always tappable, but low opacity when fields are incomplete
                            Button(action: {
                                authVM.signIn(identifier: identifier, password: password)
                            }) {
                                GlassButtonLabel(text: "Log In",
                                                 systemImage: "arrow.right.circle.fill")
                                    .opacity(canSubmit ? 1 : 0.1)
                            }

                            Button(action: {
                                authVM.signInAnon()
                            }) {
                                GlassButtonLabel(text: "Continue as Guest",
                                                 systemImage: "sparkles")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            .background(.ultraThinMaterial.opacity(0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 12))

                            HStack {
                                NavigationLink("Sign Up") { SignUpView() }
                                Spacer()
                                NavigationLink("Forgot?") { ForgotPasswordView() }
                            }
                            .font(AppFonts.body.weight(.semibold))
                        }
                        .padding(24)
                    }

                    Spacer(minLength: 0)

                    // Navigate when SMS challenge triggered.
                    NavigationLink(isActive: Binding(
                        get: { authVM.pendingResolver != nil },
                        set: { _ in }
                    )) {
                        SMSCodeView(mode: .signIn,
                                    phone: (authVM.pendingResolver?
                                              .hints.first as? PhoneMultiFactorInfo)?
                                             .phoneNumber ?? "")
                    } label: { EmptyView() }
                }
                .padding(.horizontal, 32)
                .onReceive(authVM.$authError) { newErr in
                    if let newErr {
                        err     = newErr
                        showErr = true
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
    }
}

//
//  SignUpView.swift
//  StoryMingle
//
//  Created by Sepehr Fazely on 2025-05-07
//  Updated: 2025-05-11 – username & phone availability check with Firestore and Auth
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @EnvironmentObject private var authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var username            = ""
    @State private var usernameAvailable   : Bool? = nil
    @State private var isCheckingUsername  = false

    @State private var selectedCountry     : Country = countries.first!
    @State private var phoneNumber         = ""
    @State private var phoneAvailable      : Bool? = nil
    @State private var isCheckingPhone     = false
    @State private var expectedPhoneDigits : Int = 0

    @State private var password            = ""
    @State private var confirmPassword     = ""
    @State private var showError           = false

    private let countryList = countries

    private var showSMS: Binding<Bool> {
        Binding(
            get: { authVM.pendingSignUp != nil },
            set: { newValue in if !newValue { authVM.pendingSignUp = nil } }
        )
    }

    // Button enabled when both checks pass and passwords match
    private var canSubmit: Bool {
        (usernameAvailable == true) &&
        (phoneAvailable == true) &&
        !password.isEmpty &&
        password == confirmPassword
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Create Account")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                glassCard {
                    VStack(spacing: 16) {
                        // Username field with Firestore check
                        IconTextField(
                            icon: "person",
                            placeholder: "Username",
                            text: $username,
                            isSecure: false
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    usernameAvailable == nil ? Color.clear :
                                    usernameAvailable! ? Color.green : Color.red,
                                    lineWidth: 2
                                )
                        )
                        .onChange(of: username) { new in
                            usernameAvailable = nil
                            guard new.count >= 4 else {
                                usernameAvailable = false
                                return
                            }
                            isCheckingUsername = true
                            Firestore.firestore()
                                .collection("users")
                                .whereField("name", isEqualTo: new)
                                .getDocuments { snap, _ in
                                    isCheckingUsername = false
                                    usernameAvailable = snap?.documents.isEmpty == true
                                }
                        }
                        // Username feedback
                        if !username.isEmpty {
                            if username.count < 4 {
                                Text("Must be at least 4 characters")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.red)
                            } else if isCheckingUsername {
                                Text("Checking username…")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            } else if let avail = usernameAvailable {
                                Text(avail ? "Username available" : "Username taken")
                                    .font(AppFonts.caption)
                                    .foregroundColor(avail ? .green : .red)
                            }
                        }

                        // Phone input and Auth check
                        HStack {
                            Menu {
                                ForEach(countryList, id: \.self) { c in
                                    Button(action: {
                                        selectedCountry = c
                                        expectedPhoneDigits = c.example.filter { $0.isNumber }.count
                                        phoneAvailable = nil
                                    }) {
                                        Text("\(c.name) \(c.code)")
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCountry.code)
                                    Image(systemName: "chevron.down")
                                }
                                .frame(width: 60)
                            }
                            IconTextField(
                                icon: "phone",
                                placeholder: selectedCountry.example,
                                text: $phoneNumber,
                                isSecure: false,
                                keyboardType: .phonePad
                            )
                        }
                        .onAppear {
                            expectedPhoneDigits = selectedCountry.example.filter { $0.isNumber }.count
                        }
                        .onChange(of: phoneNumber) { new in
                            phoneAvailable = nil
                            let digits = new.filter { $0.isNumber }.count
                            if digits < expectedPhoneDigits {
                                phoneAvailable = false
                            } else {
                                isCheckingPhone = true
                                let fullNumber = selectedCountry.code + new.filter { $0.isNumber }
                                let email = "\(fullNumber)@storymingle.app"
                                Auth.auth().fetchSignInMethods(forEmail: email) { methods, _ in
                                    isCheckingPhone = false
                                    phoneAvailable = (methods ?? []).isEmpty
                                }
                            }
                        }
                        // Phone feedback
                        if !phoneNumber.isEmpty {
                            let digits = phoneNumber.filter { $0.isNumber }.count
                            if digits < expectedPhoneDigits {
                                Text("Incomplete number: need \(expectedPhoneDigits) digits")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.red)
                            } else if isCheckingPhone {
                                Text("Checking phone…")
                                    .font(AppFonts.caption)
                                    .foregroundColor(.secondary)
                            } else if let avail = phoneAvailable {
                                Text(avail ? "Phone available" : "Phone already used")
                                    .font(AppFonts.caption)
                                    .foregroundColor(avail ? .green : .red)
                            }
                        }

                        // Password fields
                        IconTextField(
                            icon: "lock",
                            placeholder: "Password",
                            text: $password,
                            isSecure: true
                        )
                        IconTextField(
                            icon: "lock.rotation",
                            placeholder: "Confirm Password",
                            text: $confirmPassword,
                            isSecure: true
                        )

                        // General errors
                        if showError, let msg = authVM.authError {
                            Text(msg)
                                .font(AppFonts.caption)
                                .foregroundColor(.black)
                        }

                        // Sign Up button
                        Button(action: validateAndSignUp) {
                            GlassButtonLabel(
                                text: "Sign Up",
                                systemImage: "person.badge.plus.fill"
                            )
                            .opacity(canSubmit ? 1 : 0.5)
                        }
                        .disabled(!canSubmit)
                    }
                    .padding(24)
                }
                Spacer()
            }
            .padding(.horizontal, 32)
            .onReceive(authVM.$authError) { showError = $0 != nil }
            .background(
                NavigationLink(
                    destination: SMSCodeView(
                        mode: .signUp,
                        phone: authVM.pendingSignUp?.phone ?? ""
                    )
                    .environmentObject(authVM),
                    isActive: showSMS
                ) { EmptyView() }
                .hidden()
            )
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
    }

    private func validateAndSignUp() {
        guard password == confirmPassword else {
            authVM.authError = "Passwords do not match."
            showError = true
            return
        }
        let fullPhone = selectedCountry.code + phoneNumber.filter { $0.isNumber }
        authVM.startSignUp(
            username: username,
            phone: fullPhone,
            password: password
        )
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignUpView()
                .environmentObject(AuthViewModel())
        }
    }
}

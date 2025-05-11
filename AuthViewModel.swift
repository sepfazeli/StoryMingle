//
//  AuthViewModel.swift
//  StoryMingle
//
//  Updated 2025-05-09 – added detailed Firebase error logging
//  Updated 2025-05-12 – improved fetchUser to fall back to Auth data and create missing user docs
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthViewModel: ObservableObject {

    // ───────────────────────────── Published State
    @Published var user                : User?
    @Published var isSignedIn          = false
    @Published var authError           : String?

    // Sign-up flow
    @Published var pendingSignUp       : PendingSignUp?
    struct PendingSignUp {
        let username      : String
        let phone         : String
        let password      : String
        let verificationID: String
    }

    // Sign-in (2-FA) flow
    @Published var pendingResolver       : MultiFactorResolver?
    @Published var pendingVerificationID : String?

    // ───────────────────────────── Init
    init() {
        checkAuth()
    }

    // ───────────────────────────── Auth helpers
    func checkAuth() {
        isSignedIn = AuthService.shared.currentUserID != nil
        if isSignedIn {
            fetchUser()
        }
    }

    /// Fetch the user record from Firestore; if missing, fall back to Auth.currentUser and create a new doc
    func fetchUser() {
        FirestoreService.shared.fetchCurrentUser { [weak self] fetched in
            if let fetched = fetched {
                self?.user = fetched
            } else if let current = Auth.auth().currentUser {
                // No Firestore doc → derive from Auth and write fallback
                let uid      = current.uid
                let email    = current.email ?? ""
                let name     = email
                                .split(separator: "@")
                                .first
                                .map(String.init) ?? email
                let phone    = current.phoneNumber
                let fallback = User(
                    id:        uid,
                    name:      name,
                    bio:       "",
                    phone:     phone,
                    avatarURL: nil
                )
                self?.user = fallback

                FirestoreService.shared.createUser(
                    id:        uid,
                    name:      name,
                    bio:       "",
                    avatarURL: nil,
                    phone:     phone
                ) { err in
                    if let err = err {
                        print("⚠️ [AuthViewModel] createUser fallback error:", err)
                    }
                }
            } else {
                // No authenticated user
                self?.user = nil
            }
        }
    }

    // ╔═══════════════════════════╗
    // MARK: – SIGN-UP (username + phone + password → SMS)
    // ╚═══════════════════════════╝

    func startSignUp(username: String, phone raw: String, password: String) {
        authError = nil

        guard let phone = canonicalPhone(raw) else {
            authError = "Phone number must start with “+” followed by country code."
            return
        }

        print("🔔 APNs token state:", Auth.auth().apnsToken != nil ? "Exists" : "MISSING")

        guard Auth.auth().apnsToken != nil else {
            // Observe for APNs token ready…
            waitForAPNSToken(username: username, phone: phone, password: password)
            return
        }

        reallyStartSignUp(username: username, phone: phone, password: password)
    }

    private func reallyStartSignUp(username: String, phone: String, password: String) {
        guard Auth.auth().apnsToken != nil else {
            print("🛑 APNs token still nil — retrying in 1s")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.reallyStartSignUp(username: username, phone: phone, password: password)
            }
            return
        }

        print("▶️ Calling verifyPhoneNumber for \(phone)")
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { [weak self] verificationID, error in
            guard let self = self else { return }

            if let nsError = error as NSError? {
                // Detailed error logging
                print("🔴 [PhoneAuth] verifyPhoneNumber failed:")
                print("     • Domain   =", nsError.domain)
                print("     • Code     =", nsError.code)
                print("     • Message  =", nsError.localizedDescription)
                print("     • userInfo=", nsError.userInfo)

                if let authCode = AuthErrorCode(rawValue: nsError.code) {
                    print("     → AuthErrorCode =", authCode)
                }

                self.authError = "Firebase Error: \(nsError.localizedDescription)"
                return
            }

            guard let verificationID = verificationID, !verificationID.isEmpty else {
                print("⚠️ [PhoneAuth] verifyPhoneNumber returned no error but ID is nil/empty")
                self.authError = "Failed to obtain verification ID."
                return
            }

            print("📲 SMS sent — verificationID:", verificationID)
            self.pendingSignUp = PendingSignUp(
                username:      username,
                phone:         phone,
                password:      password,
                verificationID: verificationID
            )
        }
    }

    // ╔═══════════════════════════╗
    // MARK: – COMPLETE SIGN-UP (after SMS)
    // ╚═══════════════════════════╝

    func completeSignUp(smsCode: String) {
        guard let p = pendingSignUp else { return }

        print("🔐 Completing sign-up for user:", p.username)
        AuthService.shared.signUp(
            username       : p.username,
            phone          : p.phone,
            password       : p.password,
            smsCode        : smsCode,
            verificationID : p.verificationID
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let uid):
                print("🎉 Sign-up success (UID: \(uid))")
                FirestoreService.shared.createUser(
                    id:        uid,
                    name:      p.username,
                    bio:       "",
                    avatarURL: nil,
                    phone:     p.phone
                ) { err in
                    if let err = err {
                        print("⚠️ Firestore createUser error:", err.localizedDescription)
                    }
                }
                self.pendingSignUp = nil
                self.checkAuth()

            case .failure(let error):
                let nsError = error as NSError
                print("❌ Sign-up failed:")
                print("     • Domain   =", nsError.domain)
                print("     • Code     =", nsError.code)
                print("     • Message  =", nsError.localizedDescription)
                print("     • userInfo=", nsError.userInfo)
                self.authError = self.friendly(error)
            }
        }
    }

    // ╔═══════════════════════════╗
    // MARK: – SIGN-IN (email/username + password → optional SMS)
    // ╚═══════════════════════════╝

    func signIn(identifier: String, password: String) {
        authError = nil

        AuthService.shared.signIn(identifier: identifier, password: password) { [weak self] error, resolver in
            guard let self = self else { return }

            if let error = error {
                let nsError = error as NSError
                print("❌ signIn failed:")
                print("     • Domain   =", nsError.domain)
                print("     • Code     =", nsError.code)
                print("     • Message  =", nsError.localizedDescription)
                self.authError = self.friendly(error)
                return
            }

            if let resolver = resolver {
                print("🔑 2FA required — initiating SMS multi-factor")
                guard let phoneInfo = resolver.hints.first as? PhoneMultiFactorInfo else {
                    self.authError = "Phone factor missing."
                    return
                }
                PhoneAuthProvider.provider()
                    .verifyPhoneNumber(
                        with: phoneInfo,
                        uiDelegate         : nil,
                        multiFactorSession : resolver.session
                    ) { [weak self] id, smsErr in
                        guard let self = self else { return }
                        if let smsErr = smsErr {
                            let nsErr = smsErr as NSError
                            print("❌ Multi-factor verifyPhoneNumber failed:", nsErr.localizedDescription)
                            self.authError = self.friendly(smsErr)
                        } else if let id = id {
                            print("📲 SMS sent (sign-in) — verificationID:", id)
                            self.pendingResolver       = resolver
                            self.pendingVerificationID = id
                        } else {
                            self.authError = "Unable to send SMS."
                        }
                    }
            } else {
                print("🚀 Signed in without 2FA")
                self.checkAuth()
            }
        }
    }

    func confirmSignInCode(smsCode: String) {
        guard let resolver = pendingResolver,
              let vID      = pendingVerificationID else { return }

        print("🔓 Confirming sign-in SMS code")
        AuthService.shared.resolveSignIn(
            resolver       : resolver,
            verificationID : vID,
            smsCode        : smsCode
        ) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                let nsError = error as NSError
                print("❌ resolveSignIn failed:", nsError.localizedDescription)
                self.authError = self.friendly(error)
            } else {
                print("✅ 2FA sign-in complete")
                self.pendingResolver       = nil
                self.pendingVerificationID = nil
                self.checkAuth()
            }
        }
    }

    // ╔═══════════════════════════╗
    // MARK: – PASSWORD RESET / ANON / SIGN-OUT
    // ╚═══════════════════════════╝

    func resetPassword(identifier: String) {
        AuthService.shared.sendPasswordReset(identifier: identifier) { [weak self] error in
            if let error = error {
                print("❌ resetPassword error:", error.localizedDescription)
                self?.authError = self?.friendly(error)
            } else {
                print("📧 Password-reset email sent")
            }
        }
    }

    func signInAnon() {
        AuthService.shared.signInAnonymously { [weak self] error in
            if let error = error {
                print("❌ Anonymous sign-in error:", error.localizedDescription)
                self?.authError = self?.friendly(error)
            } else {
                print("👤 Signed in anonymously")
                self?.checkAuth()
            }
        }
    }

    func signOut() {
        print("🚪 Signing out")
        AuthService.shared.signOut()
        isSignedIn = false
        user       = nil
    }

    // ╔═══════════════════════════╗
    // MARK: – Helpers
    // ╚═══════════════════════════╝

    private func waitForAPNSToken(username: String, phone: String, password: String) {
        print("⚠️ APNs token not ready — observing .apnsTokenReady")
        final class RetryContext { var count = 0; var observer: NSObjectProtocol? }
        let ctx = RetryContext()

        ctx.observer = NotificationCenter.default.addObserver(
            forName: .apnsTokenReady,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            guard Auth.auth().apnsToken != nil else {
                print("‼️ Got .apnsTokenReady but token still nil")
                return
            }
            ctx.count += 1
            guard ctx.count <= 3 else {
                self.authError = "Verification timeout. Restart the app."
                if let obs = ctx.observer {
                    NotificationCenter.default.removeObserver(obs)
                }
                return
            }
            print("✅ Retrying verifyPhoneNumber (attempt \(ctx.count))")
            NotificationCenter.default.removeObserver(ctx.observer!)
            self.reallyStartSignUp(username: username, phone: phone, password: password)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            if Auth.auth().apnsToken == nil {
                self.authError = "Service unavailable. Check network."
                if let obs = ctx.observer {
                    NotificationCenter.default.removeObserver(obs)
                }
            }
        }
    }

    /// Normalizes input into basic E.164 style; returns `nil` if invalid.
    private func canonicalPhone(_ raw: String) -> String? {
        let cleaned = raw
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(
                of: "[^0-9+]",
                with: "",
                options: .regularExpression
            )
        if cleaned.hasPrefix("+"), cleaned.count >= 11 {
            return cleaned
        }
        return nil
    }

    /// Converts Firebase/Auth errors into short, user-friendly text.
    private func friendly(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == AuthErrorDomain,
           let code = AuthErrorCode(rawValue: ns.code) {
            switch code {
            case .wrongPassword:        return "Incorrect password."
            case .userNotFound:         return "Account not found."
            case .emailAlreadyInUse:    return "Username already taken."
            case .weakPassword:         return "Password too weak (min 6)."
            case .invalidCredential:    return "Invalid SMS code."
            case .networkError:         return "Check your connection."
            case .secondFactorRequired: return "Please enter the SMS code."
            default: break
            }
        }
        return error.localizedDescription
    }
}

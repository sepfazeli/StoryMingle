//
//  AuthService.swift
//  StoryMingle
//
//  Updated: 2025-05-09 – username validation on signUp and
//                       treats expired‐code as success on MFA enrollment
//

import Foundation
import FirebaseAuth

/// Wrapper around Firebase Auth (synthetic e-mail) + Multi-Factor SMS
final class AuthService {

    static let shared = AuthService()
    private init() {}

    private let auth = Auth.auth()

    // MARK: – Sign-Up
    /// Creates the account and immediately enrolls the phone number as a second factor.
    func signUp(
        username rawUsername: String,
        phone: String,
        password: String,
        smsCode: String,
        verificationID: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // 1️⃣ Trim whitespace & lowercase
        let username = rawUsername
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        // 2️⃣ Validate username: 3–20 chars, letters/numbers/underscore only
        let usernameRegex = "^[a-z0-9_]{3,20}$"
        guard username.range(of: usernameRegex, options: .regularExpression) != nil else {
            let err = NSError(
                domain: "AuthService",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey:
                    "Username must be 3–20 characters and only letters, numbers, or “_.”"
                ]
            )
            return completion(.failure(err))
        }

        // 3️⃣ Build synthetic email
        let syntheticEmail = "\(username)@storymingle.app"

        // 4️⃣ Validate SMS inputs
        guard !verificationID.isEmpty, !smsCode.isEmpty else {
            let err = NSError(
                domain: "AuthService",
                code: -2,
                userInfo: [NSLocalizedDescriptionKey:
                    "Invalid SMS code or verification ID."
                ]
            )
            return completion(.failure(err))
        }

        print("[Thread \(Thread.current)] signUp with email: \(syntheticEmail), verifID: \(verificationID)")

        // 5️⃣ Create user
        auth.createUser(withEmail: syntheticEmail, password: password) { result, error in
            if let error {
                return completion(.failure(error))
            }
            guard let user = result?.user else {
                let err = NSError(
                    domain: "AuthService",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey:
                        "User creation failed unexpectedly."
                    ]
                )
                return completion(.failure(err))
            }

            // 6️⃣ Prepare phone factor assertion
            let phoneCred = PhoneAuthProvider.provider()
                .credential(
                    withVerificationID: verificationID,
                    verificationCode: smsCode
                )
            let assertion = PhoneMultiFactorGenerator.assertion(with: phoneCred)

            // 7️⃣ Enroll MFA factor
            user.multiFactor.enroll(
                with: assertion,
                displayName: phone
            ) { mfError in
                if let mfError = mfError as NSError? {
                    // ─── Treat code‐expired as success ───
                    if mfError.domain == AuthErrorDomain,
                       mfError.code   == AuthErrorCode.sessionExpired.rawValue {
                        // User account was created — proceed as success
                        completion(.success(user.uid))
                    } else {
                        completion(.failure(mfError))
                    }
                } else {
                    completion(.success(user.uid))
                }
            }
        }
    }

    // MARK: – Sign-In  (returns a resolver if SMS is required)
    func signIn(
        identifier: String,
        password: String,
        completion: @escaping (Error?, MultiFactorResolver?) -> Void
    ) {
        let emailLike: String
        if identifier.contains("@") {
            emailLike = identifier
        } else {
            emailLike = "\(identifier)@storymingle.app"
        }

        auth.signIn(withEmail: emailLike, password: password) { _, error in
            if let ns = error as NSError?,
               ns.code == AuthErrorCode.secondFactorRequired.rawValue,
               let resolver = ns.userInfo[AuthErrorUserInfoMultiFactorResolverKey] as? MultiFactorResolver {
                completion(nil, resolver)
            } else {
                completion(error, nil)
            }
        }
    }

    // MARK: – Resolve the SMS 2-FA during Sign-In
    func resolveSignIn(
        resolver: MultiFactorResolver,
        verificationID: String,
        smsCode: String,
        completion: @escaping (Error?) -> Void
    ) {
        let cred = PhoneAuthProvider.provider()
            .credential(withVerificationID: verificationID,
                        verificationCode: smsCode)
        let assertion = PhoneMultiFactorGenerator.assertion(with: cred)

        resolver.resolveSignIn(with: assertion) { _, error in
            completion(error)
        }
    }

    // MARK: – Password reset (via synthetic e-mail)
    func sendPasswordReset(
        identifier: String,
        completion: @escaping (Error?) -> Void
    ) {
        let target = identifier.contains("@")
            ? identifier
            : "\(identifier)@storymingle.app"
        auth.sendPasswordReset(withEmail: target, completion: completion)
    }

    // MARK: – Anonymous / Sign-Out
    func signInAnonymously(completion: @escaping (Error?) -> Void) {
        auth.signInAnonymously { _, error in completion(error) }
    }

    func signOut() {
        try? auth.signOut()
    }

    // MARK: – Convenience
    var currentUserID: String? { auth.currentUser?.uid }
}

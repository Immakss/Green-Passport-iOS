import FirebaseCore
import Foundation
import GoogleSignIn
import UIKit

final class GoogleSignInProvider {
    private static let urlTypesKey = "CFBundleURLTypes"
    private static let urlSchemesKey = "CFBundleURLSchemes"
    private static let clientIdSeparator = "."

    func requestTokens() async throws -> GoogleTokens {
        guard let clientId = FirebaseApp.app()?.options.clientID,
              isUrlSchemeRegistered(for: clientId),
              let presenter = Self.topViewController() else {
            throw AuthFailureError(failure: .googleUnavailable)
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthFailureError(failure: .googleUnavailable)
            }
            return GoogleTokens(idToken: idToken, accessToken: result.user.accessToken.tokenString)
        } catch let error as GIDSignInError where error.code == .canceled {
            throw AuthFailureError(failure: .cancelled)
        } catch let error as AuthFailureError {
            throw error
        } catch {
            throw AuthFailureError(failure: .googleUnavailable)
        }
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }

    private func isUrlSchemeRegistered(for clientId: String) -> Bool {
        let reversedClientId = clientId
            .components(separatedBy: Self.clientIdSeparator)
            .reversed()
            .joined(separator: Self.clientIdSeparator)
        let urlTypes = Bundle.main.object(forInfoDictionaryKey: Self.urlTypesKey) as? [[String: Any]] ?? []
        let schemes = urlTypes.flatMap { return $0[Self.urlSchemesKey] as? [String] ?? [] }
        return schemes.contains(reversedClientId)
    }

    private static func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { return $0 as? UIWindowScene }
            .first { return $0.activationState == .foregroundActive }
        var controller = scene?.keyWindow?.rootViewController
        while let presented = controller?.presentedViewController {
            controller = presented
        }
        return controller
    }
}

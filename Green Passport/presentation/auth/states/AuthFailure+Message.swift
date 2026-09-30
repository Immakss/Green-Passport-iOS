import Foundation

extension AuthFailure {
    var message: LocalizedStringResource {
        switch self {
        case .invalidCredentials:
            return .wrongEmailOrPassword
        case .invalidEmail:
            return .enterValidEmail
        case .emailAlreadyInUse:
            return .emailAlreadyRegistered
        case .weakPassword:
            return .passwordTooWeak
        case .network:
            return .noInternetConnection
        case .tooManyRequests:
            return .tooManyAttemptsMsg
        case .signInMethodDisabled:
            return .signInMethodDisabledMsg
        case .cancelled, .unknown:
            return .couldNotSignInMsg
        case .googleUnavailable:
            return .googleSignInUnavailableMsg
        }
    }
}

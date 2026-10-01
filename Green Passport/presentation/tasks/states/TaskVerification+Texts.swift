import Foundation

extension TaskVerification {
    var title: LocalizedStringResource {
        switch self {
        case .selfReported:
            return .noProofNeeded
        case .photo:
            return .photoConfirmation
        case .qr:
            return .qrCodeOnSite
        }
    }

    var hint: LocalizedStringResource {
        switch self {
        case .selfReported:
            return .upTo3SuchTasksPerDayMsg
        case .photo:
            return .moderatorChecksPhotoMsg
        case .qr:
            return .organizerShowsQrCodeMsg
        }
    }

    var systemImage: String {
        switch self {
        case .selfReported:
            return "hand.raised.fill"
        case .photo:
            return "camera.fill"
        case .qr:
            return "qrcode.viewfinder"
        }
    }

    func confirmTitle(submissionStatus: SubmissionStatus?) -> LocalizedStringResource {
        switch self {
        case .selfReported:
            return .markAsDone
        case .qr:
            return .scanQrCode
        case .photo:
            return submissionStatus == .rejected ? .sendAnotherPhoto : .attachPhoto
        }
    }
}

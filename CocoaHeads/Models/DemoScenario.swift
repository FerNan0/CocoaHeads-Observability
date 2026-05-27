import Foundation

enum DemoScenario: String, CaseIterable, Identifiable {
    case ok
    case missingField
    case invalidDeeplink
    case customError
    case timeout
    case exception
    case silentGuardFail

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ok: return "ok"
        case .missingField: return "missing_field"
        case .invalidDeeplink: return "invalid_deeplink"
        case .customError: return "custom_error"
        case .timeout: return "timeout"
        case .exception: return "exception"
        case .silentGuardFail: return "silent_guard_fail"
        }
    }
}

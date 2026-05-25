import Foundation

enum DemoRoute: Hashable {
    case success(PromoResponse)
    case failure(BackendError)
}

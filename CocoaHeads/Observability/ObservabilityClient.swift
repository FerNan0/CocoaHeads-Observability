import Foundation

protocol ObservabilityClient {
    func log(_ model: ObservabilityModel)
}

struct ConsoleObservabilityClient: ObservabilityClient {
    func log(_ model: ObservabilityModel) {
        print("\(model.eventName) severity=\(model.severity) message=\(model.message) exception_locale=\(model.exceptionLocale)")
    }
}

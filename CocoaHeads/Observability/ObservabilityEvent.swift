import Foundation

/// Tipos de eventos de observabilidade centralizados
enum ObservabilityEventType {
    // Success
    case success

    // Backend errors
    case backendError(message: String, correlationID: String)
    case backendErrorDecodeFailed(error: Error)

    // Request/Network errors
    case requestFailed(error: Error)
    case invalidHttpResponse(error: Error)
    case invalidUrl
    case noInternet
    case dnsError
    case sslError(error: Error)

    // Response errors
    case responseDecodeFailed(error: Error)

    // Timeout
    case timeout

    // Deep link
    case deepLinkFailed(url: String)

    // Silent guard let failures
    case silentGuardLetFailed(field: String, index: String, arrayCount: Int, expectedCount: Int)

    // Custom generic error
    case genericError

    // MARK: - Properties

    var eventName: String {
        switch self {
        case .success:
            return "promo_card_success"
        case .backendError, .backendErrorDecodeFailed:
            return "promo_card_backend_error"
        case .requestFailed, .invalidHttpResponse, .invalidUrl, .responseDecodeFailed, .timeout, .noInternet, .dnsError, .sslError:
            return "promo_card_generic_error"
        case .deepLinkFailed:
            return "promo_card_deeplink_error"
        case .silentGuardLetFailed:
            return "silent_guard_let_failed"
        case .genericError:
            return "promo_card_generic_error"
        }
    }

    var severity: Int {
        switch self {
        case .success:
            return 1  // Info
        case .backendError, .timeout, .noInternet, .dnsError:
            return 2  // Warning
        case .deepLinkFailed, .invalidUrl, .invalidHttpResponse, .sslError, .silentGuardLetFailed:
            return 3  // Error
        case .backendErrorDecodeFailed, .requestFailed, .responseDecodeFailed, .genericError:
            return 4  // Critical
        }
    }

    var message: String {
        switch self {
        case .success:
            return "success"
        case .backendError(let msg, _):
            return msg
        case .backendErrorDecodeFailed:
            return "backend_error_decode_failed"
        case .requestFailed:
            return "request_failed"
        case .invalidHttpResponse:
            return "invalid_http_response"
        case .invalidUrl:
            return "invalid_url"
        case .responseDecodeFailed:
            return "response_decode_failed"
        case .timeout:
            return "timeout"
        case .noInternet:
            return "no_internet_connection"
        case .dnsError:
            return "dns_resolution_failed"
        case .sslError:
            return "ssl_certificate_error"
        case .deepLinkFailed:
            return "open_url_rejected"
        case .silentGuardLetFailed(let field, _, _, _):
            return "guard_let_failed_field_\(field)"
        case .genericError:
            return "generic_error"
        }
    }

    var exceptionLocale: String {
        switch self {
        case .success:
            return "none"
        case .backendError(let message, _):
            return message
        case .backendErrorDecodeFailed(let error):
            return decodingLocale(from: error).locale
        case .requestFailed(let error):
            return error.localizedDescription
        case .invalidHttpResponse(let error):
            return error.localizedDescription
        case .invalidUrl:
            return "invalid_base_url"
        case .responseDecodeFailed(let error):
            return decodingLocale(from: error).locale
        case .timeout:
            return "timeout"
        case .noInternet:
            return "NSURLErrorNotConnectedToInternet"
        case .dnsError:
            return "NSURLErrorCannotFindHost"
        case .sslError(let error):
            return error.localizedDescription
        case .deepLinkFailed(let url):
            return url
        case .silentGuardLetFailed(let field, let index, _, _):
            return "SilentGuardLetDemo.processUserDataGood[field=\(field), index=\(index)]"
        case .genericError:
            return "generic_error"
        }
    }

    var metadata: [String: String] {
        switch self {
        case .success:
            return [:]
        case .backendError(let msg, _):
            return ["reason": msg]
        case .backendErrorDecodeFailed:
            let info = decodingLocale(from: extractError(from: self))
            return ["reason": "backend_error_decode_failed", "field": info.field, "coding_path": info.codingPath]
        case .requestFailed:
            return ["reason": "request_failed"]
        case .invalidHttpResponse:
            return ["reason": "response_cast_failed"]
        case .invalidUrl:
            return ["reason": "invalid_base_url"]
        case .responseDecodeFailed:
            let info = decodingLocale(from: extractError(from: self))
            return ["reason": "response_decode_failed", "field": info.field, "coding_path": info.codingPath]
        case .timeout:
            return ["reason": "timeout"]
        case .noInternet:
            return ["reason": "no_internet", "type": "network_unavailable"]
        case .dnsError:
            return ["reason": "dns_failed", "type": "host_resolution"]
        case .sslError:
            return ["reason": "ssl_error", "type": "security"]
        case .deepLinkFailed(let url):
            return ["url": url]
        case .silentGuardLetFailed(let field, let index, let arrayCount, let expectedCount):
            return [
                "reason": "silent_guard_let_failed",
                "field": field,
                "index": index,
                "array_count": "\(arrayCount)",
                "expected_count": "\(expectedCount)",
                "type": "insufficient_data"
            ]
        case .genericError:
            return ["reason": "generic_error"]
        }
    }

    private func extractError(from event: ObservabilityEventType) -> Error {
        switch event {
        case .backendErrorDecodeFailed(let error), .responseDecodeFailed(let error):
            return error
        default:
            return NSError(domain: "Observability", code: -1)
        }
    }

    private func decodingLocale(from error: Error) -> (locale: String, field: String, codingPath: String) {
        guard let decodingError = error as? DecodingError else {
            let value = error.localizedDescription
            return (value, value, value)
        }

        switch decodingError {
        case let .keyNotFound(key, context):
            let path = context.codingPath.map(\.stringValue) + [key.stringValue]
            let joined = path.joined(separator: ".")
            return (joined, key.stringValue, joined)
        case let .typeMismatch(_, context), let .valueNotFound(_, context), let .dataCorrupted(context):
            let path = context.codingPath.map(\.stringValue).joined(separator: ".")
            let field = context.codingPath.last?.stringValue ?? "unknown"
            return (path.isEmpty ? decodingError.localizedDescription : path, field, path.isEmpty ? "unknown" : path)
        @unknown default:
            let value = error.localizedDescription
            return (value, value, value)
        }
    }
}

// MARK: - Extension para criar ObservabilityModel facilmente

extension ObservabilityModel {
    /// Factory method para criar modelo a partir de tipo de evento
    static func from(
        _ eventType: ObservabilityEventType,
        additionalMetadata: [String: String] = [:]
    ) -> ObservabilityModel {
        var finalMetadata = eventType.metadata
        additionalMetadata.forEach { finalMetadata[$0.key] = $0.value }

        return ObservabilityModel(
            eventName: eventType.eventName,
            severity: eventType.severity,
            message: eventType.message,
            exceptionLocale: eventType.exceptionLocale,
            metadata: finalMetadata
        )
    }
}

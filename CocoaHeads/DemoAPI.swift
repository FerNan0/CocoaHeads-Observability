import Foundation

struct APIErrorResponse: Decodable {
    let error: APIErrorDetail
}

struct APIErrorDetail: Decodable {
    let code: String
    let message: String
    let userMessage: String?
    let correlationID: String
    let details: [String: String]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case userMessage = "user_message"
        case correlationID = "correlation_id"
        case details
    }
}

protocol PromoRequestProtocol {
    func fetchPromo(
        scenario: DemoScenario,
        onObservability: ((ObservabilityModel) -> Void)?
    ) async -> Result<PromoResponse, BackendError>
}

struct DemoRequest: PromoRequestProtocol {
    let baseURL: URL
    let requestTimeout: TimeInterval = 3

    func fetchPromo(
        scenario: DemoScenario,
        onObservability: ((ObservabilityModel) -> Void)? = nil
    ) async -> Result<PromoResponse, BackendError> {
        let queryItems = [
            URLQueryItem(name: "scenario", value: scenario.title)
        ]
        return await DemoAPI(baseURL: baseURL).request(
            urlPath: "v1/promo-card",
            urlQuery: queryItems,
            timeout: requestTimeout,
            onObservability: onObservability
        )
    }
}

enum DemoError: LocalizedError {
    case server(statusCode: Int)
    case genericError

    var errorDescription: String? {
        switch self {
        case let .server(statusCode):
            return "Erro do servidor \(statusCode)"
        case .genericError:
            return "Falha genérica ao processar resposta"
        }
    }
}

protocol DemoAPIProtocol {
    func request<T: Decodable>(
        urlPath: String,
        urlQuery: [URLQueryItem],
        timeout: TimeInterval,
        onObservability: ((ObservabilityModel) -> Void)?
    ) async -> Result<T, BackendError>
}

struct DemoAPI: DemoAPIProtocol {
    let baseURL: URL

    func request<T: Decodable>(
        urlPath: String,
        urlQuery: [URLQueryItem],
        timeout: TimeInterval,
        onObservability: ((ObservabilityModel) -> Void)? = nil
    ) async -> Result<T, BackendError> {
        var components = URLComponents(url: baseURL.appendingPathComponent(urlPath), resolvingAgainstBaseURL: false)
        components?.queryItems = urlQuery

        guard let url = components?.url else {
            onObservability?(.from(.invalidUrl))
            return .failure(.generic)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                onObservability?(.from(.invalidHttpResponse(error: NSError(domain: "HTTPResponse", code: -1))))
                return .failure(.generic)
            }

            if httpResponse.statusCode >= 400 {
                do {
                    let apiError = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                    return .failure(.custom(error: .init(code: apiError.error.code, message: apiError.error.message, userMessage: apiError.error.userMessage, correlationID: apiError.error.correlationID, details: apiError.error.details)))
                } catch {
                    onObservability?(.from(.backendErrorDecodeFailed(error: error)))
                    return .failure(.generic)
                }
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                return .success(decoded)
            } catch {
                onObservability?(.from(.responseDecodeFailed(error: error)))
                return .failure(.generic)
            }
        } catch {
            let eventType = diagnoseNetworkError(error)
            onObservability?(.from(eventType))
            return .failure(.generic)
        }
    }

    // MARK: - Error Diagnosis

    private func diagnoseNetworkError(_ error: Error) -> ObservabilityEventType {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return .noInternet
            case .cannotFindHost, .dnsLookupFailed:
                return .dnsError
            case .serverCertificateUntrusted, .clientCertificateRejected:
                return .sslError(error: urlError)
            default:
                return .requestFailed(error: urlError)
            }
        }
        return .requestFailed(error: error)
    }
}

import Foundation

struct OpenSearchObservabilityDocument: Encodable {
    let timestamp: String
    let eventName: String
    let severity: Int
    let message: String
    let exceptionLocale: String
    let metadata: [String: String]

    enum CodingKeys: String, CodingKey {
        case timestamp = "@timestamp"
        case eventName
        case severity
        case message
        case exceptionLocale
        case metadata
    }
}

struct OpenSearchObservabilityClient: ObservabilityClient {
    private let endpointURL: URL? = URL(string: "http://localhost:9200/observability-events/_doc")

    func log(_ model: ObservabilityModel) {
        Task {
            var request: URLRequest?
            if let endpointURL {
                request = URLRequest(url: endpointURL)
            }
            
            request?.httpMethod = "POST"
            request?.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let document = OpenSearchObservabilityDocument(
                timestamp: formatter.string(from: Date()),
                eventName: model.eventName,
                severity: model.severity,
                message: model.message,
                exceptionLocale: model.exceptionLocale,
                metadata: model.metadata
            )

            do {
                request?.httpBody = try JSONEncoder().encode(document)
                guard let request else { return }
                _ = try await URLSession.shared.data(for: request)
            } catch {
                print("OpenSearch log failed: \(error.localizedDescription)")
            }
        }
    }
}

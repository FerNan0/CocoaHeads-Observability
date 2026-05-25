import Foundation

struct PromoResponse: Codable, Hashable {
    let scenario: String
    let id: String
    let title: String?
    let subtitle: String?
    let deeplink: String?
    let cta: String?
    let correlationID: String
    
    enum CodingKeys: String, CodingKey {
        case scenario
        case id
        case title
        case subtitle
        case deeplink
        case cta
        case correlationID = "correlation_id"
    }
}

extension PromoResponse {
    var prettyPrinted: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(self),
              let string = String(data: data, encoding: .utf8) else {
            return "Unable to render payload"
        }
        return string
    }
}

struct PromoCardFailureResponse: Decodable {
    let error: CustomError
}

enum BackendError: Error, Hashable {
    case custom(error: CustomError)
    case generic
}

extension BackendError: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        if let errorContainer = try? container.nestedContainer(keyedBy: CustomError.CodingKeys.self, forKey: DynamicCodingKeys(stringValue: "error")!) {
            let error = CustomError(
                code: try errorContainer.decode(String.self, forKey: .code),
                message: try errorContainer.decode(String.self, forKey: .message),
                userMessage: try errorContainer.decodeIfPresent(String.self, forKey: .userMessage),
                correlationID: try errorContainer.decode(String.self, forKey: .correlationID),
                details: try errorContainer.decodeIfPresent([String: String].self, forKey: .details)
            )
            self = .custom(error: error)
        } else {
            self = .generic
        }
    }
}

struct CustomError: Decodable, Hashable {
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

private struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
    }

    init?(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "\(intValue)"
    }
}

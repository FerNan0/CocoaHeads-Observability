import Foundation

/// Demonstra o problema: guard let que falha silenciosamente
struct SilentGuardLetDemo {

    /// ❌ RUIM: Guard let sem logging — fluxo é cortado, ninguém sabe
    func processUserDataBad(array: [String]) {
        guard let userName = array[safe: 0] else {
            // SILENT FAIL: retorna sem aviso, bug invisível
            return
        }

        guard let userEmail = array[safe: 1] else {
            // SILENT FAIL: segunda falha, ainda invisível
            return
        }

        print("User: \(userName), Email: \(userEmail)")
    }

    /// ✅ BOM: Guard let com observabilidade — erro é capturado
    func processUserDataGood(array: [String], onObservability: ((ObservabilityModel) -> Void)? = nil) {
        guard let userName = array[safe: 0] else {
            let errorModel = ObservabilityModel(
                eventName: "guard_let_failed",
                severity: 2,
                message: "Failed to extract userName from array at index 0",
                exceptionLocale: "SilentGuardLetDemo.processUserDataGood",
                metadata: [
                    "field": "userName",
                    "index": "0",
                    "array_count": "\(array.count)",
                    "expected_count": "2",
                    "reason": "insufficient_data"
                ]
            )
            onObservability?(errorModel)
            return
        }

        guard let userEmail = array[safe: 1] else {
            let errorModel = ObservabilityModel(
                eventName: "guard_let_failed",
                severity: 2,
                message: "Failed to extract userEmail from array at index 1",
                exceptionLocale: "SilentGuardLetDemo.processUserDataGood",
                metadata: [
                    "field": "userEmail",
                    "index": "1",
                    "array_count": "\(array.count)",
                    "expected_count": "2",
                    "reason": "insufficient_data"
                ]
            )
            onObservability?(errorModel)
            return
        }

        print("User: \(userName), Email: \(userEmail)")
    }

    /// Exemplo real: API response com array incompleto
    func parsePromoCardsArrayFail(
        jsonArray: [[String: Any]],
        onObservability: ((ObservabilityModel) -> Void)? = nil
    ) -> [PromoResponse]? {
        var promos: [PromoResponse] = []

        for (index, item) in jsonArray.enumerated() {
            // ❌ Sem observabilidade, essas falhas são invisíveis
            guard let title = item["title"] as? String else {
                // SILENT RETURN — O resto do array é ignorado, ninguém sabe
                onObservability?(.from(
                    .backendError(
                        message: "Promo card missing required field 'title'",
                        correlationID: UUID().uuidString
                    ),
                    additionalMetadata: [
                        "card_index": "\(index)",
                        "total_cards": "\(jsonArray.count)",
                        "missing_field": "title"
                    ]
                ))
                return nil
            }

            guard let deeplink = item["deeplink"] as? String else {
                onObservability?(.from(
                    .backendError(
                        message: "Promo card missing required field 'deeplink'",
                        correlationID: UUID().uuidString
                    ),
                    additionalMetadata: [
                        "card_index": "\(index)",
                        "total_cards": "\(jsonArray.count)",
                        "missing_field": "deeplink"
                    ]
                ))
                return nil
            }

            promos.append(PromoResponse(
                scenario: "promo_card",
                id: UUID().uuidString,
                title: title,
                subtitle: item["subtitle"] as? String,
                deeplink: deeplink,
                cta: item["cta"] as? String,
                correlationID: UUID().uuidString
            ))
        }

        return promos
    }
}

extension Array {
    /// Safe subscript para evitar crashes, mas permite observabilidade
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

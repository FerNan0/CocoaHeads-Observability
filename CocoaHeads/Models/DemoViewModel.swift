import Foundation

@MainActor
final class DemoViewModel: ObservableObject {
    @Published var selectedScenario: DemoScenario = .ok
    @Published var mockoonBaseURL = "http://localhost:8001"
    @Published var isLoading = false
    @Published var route: DemoRoute?
    @Published var timeline: [String] = ["Aguardando ação do usuário"]
    @Published var latencyMs = 0
    @Published var statusCode = 0
    @Published var errorType = "-"
    @Published var responseSummary = "Nenhuma jornada executada ainda."
    @Published var observabilityLog: [String] = []

    func runScenario() async {
        resetState()
        let start = Date()

        guard let baseURL = URL(string: mockoonBaseURL) else {
            handleInvalidUrl(elapsed: elapsedSince(start))
            isLoading = false
            return
        }

        let request: PromoRequestProtocol = DemoRequest(baseURL: baseURL)
        let result = await request.fetchPromo(scenario: selectedScenario) { [weak self] observability in
            Task { @MainActor in
                self?.logObservabilityEvent(observability)
            }
        }

        let elapsed = elapsedSince(start)
        switch result {
        case let .success(response):
            handleSuccess(response, elapsed: elapsed)
        case let .failure(error):
            handleError(error, elapsed: elapsed)
        }

        isLoading = false
    }

    // MARK: - Private Helpers

    private func resetState() {
        isLoading = true
        route = nil
        timeline = ["Início da jornada", "Chamando endpoint mockado..."]
        statusCode = 0
        errorType = "-"
        responseSummary = "Executando \(selectedScenario.title)..."
        observabilityLog = []
    }

    private func elapsedSince(_ start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }

    private func handleInvalidUrl(elapsed: Int) {
        latencyMs = elapsed
        statusCode = 0
        errorType = "genericError"
        responseSummary = "Falha genérica ao processar resposta."
        route = .failure(.generic)

        logObservabilityEvent(
            .from(.invalidUrl, additionalMetadata: baseMetadata(statusCode: latencyMs))
        )
    }

    private func handleSuccess(_ response: PromoResponse, elapsed: Int) {
        latencyMs = elapsed
        statusCode = 200
        errorType = "none"
        timeline.append("Renderização concluída com sucesso")
        responseSummary = "Tela renderizada corretamente."
        route = .success(response)

        logObservabilityEvent(
            .from(.success, additionalMetadata: baseMetadata(
                statusCode: statusCode,
                latency: latencyMs
            ))
        )
    }

    private func handleError(_ error: BackendError, elapsed: Int) {
        latencyMs = elapsed

        switch error {
        case let .custom(details):
            handleCustomError(details, elapsed: elapsed)
        case .generic:
            handleGenericError(elapsed: elapsed)
        }
    }

    private func handleCustomError(_ error: CustomError, elapsed: Int) {
        statusCode = Int(error.code.filter { $0.isNumber }) ?? 400
        errorType = "server"
        timeline.append("Erro de backend capturado: \(error.code)")
        responseSummary = "Erro customizado do backend: \(error.message)"
        route = .failure(.custom(error: error))

        logObservabilityEvent(
            .from(
                .backendError(message: error.message, correlationID: error.correlationID),
                additionalMetadata: baseMetadata(
                    statusCode: statusCode,
                    latency: latencyMs,
                    extra: [
                        "error_code": error.code,
                        "correlation_id": error.correlationID
                    ]
                )
            )
        )
    }

    private func handleGenericError(elapsed: Int) {
        statusCode = 0
        errorType = "genericError"
        timeline.append("Erro genérico capturado")
        responseSummary = "Falha genérica ao processar resposta."
        route = .failure(.generic)

        logObservabilityEvent(
            .from(.genericError, additionalMetadata: baseMetadata(latency: latencyMs))
        )
    }

    private func baseMetadata(
        statusCode: Int? = nil,
        latency: Int? = nil,
        extra: [String: String] = [:]
    ) -> [String: String] {
        var metadata: [String: String] = ["scenario": selectedScenario.title]

        if let statusCode {
            metadata["status_code"] = "\(statusCode)"
        }
        if let latency {
            metadata["latency_ms"] = "\(latency)"
        }

        metadata.merge(extra) { _, new in new }
        return metadata
    }

    @MainActor
    private func logObservabilityEvent(_ model: ObservabilityModel) {
        ConsoleObservabilityClient().log(model)

        OpenSearchObservabilityClient().log(model)

        let metadata = model.metadata
            .map { "\($0.key)=\($0.value)" }
            .sorted()
            .joined(separator: ", ")

        observabilityLog.append("\(model.eventName) { severity=\(model.severity), message=\(model.message), exception_locale=\(model.exceptionLocale), metadata={ \(metadata) } }")
    }
}


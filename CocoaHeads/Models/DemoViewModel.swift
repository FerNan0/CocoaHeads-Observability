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
        isLoading = true
        route = nil
        timeline = ["Início da jornada", "Chamando endpoint mockado..."]
        statusCode = 0
        errorType = "-"
        responseSummary = "Executando \(selectedScenario.title)..."
        observabilityLog = []

        let start = Date()

        guard let baseURL = URL(string: mockoonBaseURL) else {
            let elapsed = Int(Date().timeIntervalSince(start) * 1000)
            latencyMs = elapsed
            statusCode = 0
            errorType = "genericError"
            responseSummary = "Falha genérica ao processar resposta."
            route = .failure(.generic)
            logObservabilityEvent(
                .from(.invalidUrl, additionalMetadata: [
                    "scenario": selectedScenario.title,
                    "latency_ms": "\(latencyMs)"
                ])
            )
            isLoading = false
            return
        }

        let request: PromoRequestProtocol = DemoRequest(baseURL: baseURL)
        let result = await request.fetchPromo(scenario: selectedScenario) { [weak self] observability in
            Task { @MainActor in
                self?.logObservabilityEvent(observability)
            }
        }
        switch result {
        case let .success(response):
            let elapsed = Int(Date().timeIntervalSince(start) * 1000)
            latencyMs = elapsed
            statusCode = 200
            errorType = "none"
            timeline.append("Renderização concluída com sucesso")
            responseSummary = "Tela renderizada corretamente."
            route = .success(response)
            logObservabilityEvent(
                .from(.success, additionalMetadata: [
                    "scenario": selectedScenario.title,
                    "latency_ms": "\(latencyMs)",
                    "status_code": "\(statusCode)"
                ])
            )
        case let .failure(backendError):
            let elapsed = Int(Date().timeIntervalSince(start) * 1000)
            latencyMs = elapsed
            switch backendError {
            case let .custom(error):
                statusCode = Int(error.code.filter { $0.isNumber }) ?? 400
                errorType = "server"
                timeline.append("Erro de backend capturado: \(error.code)")
                responseSummary = "Erro customizado do backend: \(error.message)"
                route = .failure(backendError)
                logObservabilityEvent(
                    .from(.backendError(message: error.message, correlationID: error.correlationID), additionalMetadata: [
                        "scenario": selectedScenario.title,
                        "latency_ms": "\(latencyMs)",
                        "status_code": "\(statusCode)",
                        "error_code": error.code,
                        "correlation_id": error.correlationID
                    ])
                )
            case .generic:
                statusCode = 0
                errorType = "genericError"
                timeline.append("Erro genérico capturado")
                responseSummary = "Falha genérica ao processar resposta."
                route = .failure(backendError)
                logObservabilityEvent(
                    .from(.genericError, additionalMetadata: [
                        "scenario": selectedScenario.title,
                        "latency_ms": "\(latencyMs)"
                    ])
                )
            }
        }

        isLoading = false
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

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DemoViewModel()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    baseURLField
                    observabilityEndpointField
                    scenarioPicker
                    executeButton
                    responseCard
                    timelineCard
                    metricsCard
                    observabilityCard
                }
                .padding()
            }
            .navigationTitle("CocoaHeads Demo")
            .navigationDestination(for: DemoRoute.self) { route in
                switch route {
                case let .success(response):
                    SuccessView(response: response)
                case let .failure(error):
                    FailureView(error: error)
                }
            }
            .onChange(of: viewModel.route) { oldValue, newValue in
                guard let route = newValue else { return }
                path = NavigationPath()
                path.append(route)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Observability Playground")
                .font(.largeTitle.bold())
            Text("Uma jornada iOS com respostas controladas do Mockoon.")
                .foregroundStyle(.secondary)
        }
    }

    private var scenarioPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cenário")
                .font(.headline)
            Picker("Cenário", selection: $viewModel.selectedScenario) {
                ForEach(DemoScenario.allCases) { scenario in
                    Text(scenario.title).tag(scenario)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var baseURLField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mockoon host")
                .font(.headline)
            TextField("http://localhost:8001", text: $viewModel.mockoonBaseURL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
            Text("Use o host do Mockoon aqui. Ex: `http://localhost:8001` ou `http://192.168.x.x:8001`.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var observabilityEndpointField: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenSearch endpoint")
                .font(.headline)           
            Text("Se existir, o evento vai ser enviado para esse endpoint e também fica no log local.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var executeButton: some View {
        Button {
            path = NavigationPath()
            Task { await viewModel.runScenario() }
        } label: {
            HStack {
                Spacer()
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Executar jornada")
                        .font(.headline)
                }
                Spacer()
            }
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
            .foregroundStyle(.white)
        }
        .disabled(viewModel.isLoading)
    }

    private var responseCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resposta").font(.headline)
            Text(viewModel.responseSummary).font(.body)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.headline)
            ForEach(viewModel.timeline, id: \.self) { step in
                Text("• \(step)")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var metricsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Métricas")
                .font(.headline)
            HStack {
                metricItem(label: "Latência", value: "\(viewModel.latencyMs) ms")
                metricItem(label: "Status", value: "\(viewModel.statusCode)")
                metricItem(label: "Erro", value: viewModel.errorType)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var observabilityCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("OpenSearch events")
                .font(.headline)
            if viewModel.observabilityLog.isEmpty {
                Text("Nenhum evento ainda.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.observabilityLog, id: \.self) { entry in
                    Text(entry)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func metricItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}

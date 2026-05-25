# Refactor de Observabilidade - Guia de Uso

## O Problema Anterior ❌

Antes, você tinha que passar manualmente todos os parâmetros toda vez:

```swift
onObservability?(ObservabilityModel(
    eventName: "promo_card_generic_error",
    severity: 4,
    message: "backend_error_decode_failed",
    exceptionLocale: error.localizedDescription,
    metadata: ["reason": "backend_error_decode_failed"]
))
```

**Problemas:**
- Repetição de código
- Fácil cometer erros (severity inconsistente, message faltando, etc)
- Difícil de manter
- Severity, message e metadata estavam descentralizadas

---

## A Solução ✅

Agora existe `ObservabilityEvent.swift` com um enum centralizado:

```swift
enum ObservabilityEventType {
    case success
    case backendError(message: String, correlationID: String)
    case backendErrorDecodeFailed(error: Error)
    case requestFailed(error: Error)
    case invalidHttpResponse(error: Error)
    case invalidUrl
    case responseDecodeFailed(error: Error)
    case timeout
    case deepLinkFailed(url: String)
    case genericError
}
```

**Cada tipo já define automaticamente:**
- ✅ `eventName` (promo_card_success, promo_card_generic_error, etc)
- ✅ `severity` (1=info, 2=warning, 3=error, 4=critical)
- ✅ `message` (descritivo para o evento)
- ✅ `exceptionLocale` (erro, correlationID, URL, etc)

---

## Como Usar

### Caso 1: Evento Simples (Sucesso)

**Antes:**
```swift
logObservabilityEvent(ObservabilityModel(
    eventName: "promo_card_success",
    severity: 1,
    message: "success",
    exceptionLocale: "none",
    metadata: ["scenario": selectedScenario.title]
))
```

**Depois:**
```swift
logObservabilityEvent(
    .from(.success, additionalMetadata: [
        "scenario": selectedScenario.title
    ])
)
```

---

### Caso 2: Erro com Contexto

**Antes:**
```swift
onObservability?(ObservabilityModel(
    eventName: "promo_card_backend_error",
    severity: 2,
    message: error.message,
    exceptionLocale: error.correlationID,
    metadata: [
        "error_code": error.code,
        "correlation_id": error.correlationID
    ]
))
```

**Depois:**
```swift
onObservability?(.from(
    .backendError(message: error.message, correlationID: error.correlationID),
    additionalMetadata: [
        "error_code": error.code,
        "correlation_id": error.correlationID
    ]
))
```

---

### Caso 3: Exceção/Erro

**Antes:**
```swift
onObservability?(ObservabilityModel(
    eventName: "promo_card_generic_error",
    severity: 4,
    message: "request_failed",
    exceptionLocale: error.localizedDescription,
    metadata: ["reason": "request_failed"]
))
```

**Depois:**
```swift
onObservability?(.from(.requestFailed(error: error)))
```

> Note: não precisa nem de `additionalMetadata` se não tiver contexto extra

---

### Caso 4: Deep Link Error

**Antes:**
```swift
let model = ObservabilityModel(
    eventName: "promo_card_deeplink_error",
    severity: 3,
    message: "open_url_rejected",
    exceptionLocale: deeplink,
    metadata: [
        "deeplink": deeplink,
        "reason": "invalid"
    ]
)
```

**Depois:**
```swift
let model = ObservabilityModel.from(
    .deepLinkFailed(url: deeplink),
    additionalMetadata: ["reason": "invalid"]
)
```

---

## Tipos de Eventos Disponíveis

| Tipo | Severity | EventName | Quando usar |
|------|----------|-----------|-------------|
| `.success` | 1 | promo_card_success | Requisição OK |
| `.backendError(msg, corrID)` | 2 | promo_card_backend_error | Erro do servidor esperado |
| `.backendErrorDecodeFailed(error)` | 4 | promo_card_generic_error | Erro ao decodificar resposta do servidor |
| `.requestFailed(error)` | 4 | promo_card_generic_error | Network/conexão falhou |
| `.invalidHttpResponse(error)` | 3 | promo_card_generic_error | Response não é HTTP válido |
| `.invalidUrl` | 3 | promo_card_generic_error | URL/endpoint inválido |
| `.responseDecodeFailed(error)` | 4 | promo_card_generic_error | Erro ao decodificar JSON |
| `.timeout` | 2 | promo_card_generic_error | Request timeout |
| `.deepLinkFailed(url)` | 3 | promo_card_deeplink_error | Deep link inválido |
| `.genericError` | 4 | promo_card_generic_error | Erro genérico |

---

## Benefícios

✅ **DRY (Don't Repeat Yourself)** — Define uma vez, usa em qualquer lugar  
✅ **Type-safe** — Enum garante que você passa os parâmetros certos  
✅ **Consistência** — Severity/message sempre corretos para cada tipo  
✅ **Fácil manutenção** — Muda em um lugar, afeta tudo  
✅ **Self-documenting** — Código fica mais legível  
✅ **Menos bugs** — Menos chance de esquecer metadata ou severity  

---

## Exemplo Completo Real

```swift
// Na DemoAPI, quando request falha
catch {
    // Antes: 6 linhas, muita repetição
    // Depois: 1 linha, claro e conciso
    onObservability?(.from(.requestFailed(error: error)))
    return .failure(.generic)
}
```

```swift
// Em SuccessView, ao tentar abrir deep link
UIApplication.shared.open(deeplink) { _ in
    self.logDeeplinkFailure(deeplink: deeplink, reason: "open_url_rejected")
}

// Método que antes tinha 11 linhas
private func logDeeplinkFailure(deeplink: String, reason: String) {
    let model = ObservabilityModel.from(
        .deepLinkFailed(url: deeplink),
        additionalMetadata: ["reason": reason]
    )
    OpenSearchObservabilityClient().log(model)
}
```

---

## Adicionando Novo Tipo de Evento

Se precisa de um novo tipo de evento:

1. Adicione em `ObservabilityEventType`:
```swift
case customEvent(param: String)
```

2. Implemente as properties:
```swift
var eventName: String {
    switch self {
    case .customEvent:
        return "promo_card_custom"
    // ...
    }
}

var severity: Int {
    switch self {
    case .customEvent:
        return 2  // ou o que faz sentido
    // ...
    }
}

// ... e assim para message, exceptionLocale, metadata
```

3. Use em qualquer lugar:
```swift
onObservability?(.from(.customEvent(param: "valor")))
```

---

## Estrutura Final

```
CocoaHeads/
├── ObservabilityEvent.swift         ← NOVO: Centralizado enum + factory
├── ObservabilityModel.swift          ← Não muda (apenas extension)
├── OpenSearchObservabilityClient.swift
├── DemoViewModel.swift              ← Refatorado (usa novo enum)
├── DemoAPI.swift                    ← Refatorado (usa novo enum)
└── SuccessView.swift                ← Refatorado (usa novo enum)
```

**Resultado:** Menos repetição, mais clareza, melhor manutenção! 🎯

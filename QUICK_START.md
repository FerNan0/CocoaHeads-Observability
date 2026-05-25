# CocoaHeads Demo - Quick Start ⚡

**Seu projeto está 100% pronto!** Aqui está tudo que você precisa para a talk do dia 28.

---

## ✅ O Que Foi Preparado

### Código da App
- ✅ **OpenSearchObservabilityClient.swift** — Cliente para logar no OpenSearch
- ✅ **DemoViewModel.swift** — Integrado com logging automático
- ✅ **Pontos de log** — Já implementados em success/error/timeout/exception

### Infraestrutura
- ✅ **docker-compose.yml** — OpenSearch + Dashboards pré-configurado
- ✅ **Índice mapeado** — Schema de eventos pronto
- ✅ **Dashboard JSON** — Visualizações prontas (na pasta `opensearch/`)

### Scripts Executáveis
- 🟢 **START_HERE.sh** ← **EXECUTE ISTO PRIMEIRO**
- 📄 opensearch/setup.sh — Alternativa se precisar reconfigurar
- 📄 opensearch/smoke-test.sh — Teste rápido de conectividade

### Documentação
- 📋 **PRESENTATION_GUIDE.md** — Roteiro completo para a talk
- 📋 opensearch/README.md — Referência técnica
- 📋 QUICK_START.md — Este arquivo

---

## 🚀 Inicialização (Execute 1 vez)

### Pré-requisito
Ter Docker Desktop rodando na máquina.

### Execute este comando NO TERMINAL

```bash
bash /Users/ferskt/Desktop/Things/Study/CocoaHeads/START_HERE.sh
```

**O que ele faz (automático):**
1. Sobe containers OpenSearch + Dashboards
2. Aguarda ficar pronto (~60s na primeira vez)
3. Cria índice com schema correto
4. Insere evento de teste
5. Verifica tudo está funcionando

**Você saberá que terminou quando aparecer:**
```
╔════════════════════════════════════════════════════════╗
║   ✅ SETUP COMPLETO! Tudo pronto para a talk         ║
╚════════════════════════════════════════════════════════╝
```

---

## 📱 Usando na Demo

### 1️⃣ Abra o Simulator/Device
```bash
# No Xcode
Cmd + Shift + 2  # Escolher dispositivo
Cmd + R          # Build + Run
```

### 2️⃣ Abra Dashboard em outra janela
```
http://localhost:5601
Menu (☰) > Discover > Índice: observability-events
```

### 3️⃣ Execute cenários
Na app, clique em cada botão:
- ✅ **Ok** — Sucesso (log severity=1)
- ⚠️ **Missing Field** — Erro esperado (severity=2)
- 🔴 **Custom Error** — Erro customizado (severity=2)
- ⛔ **Exception** — Exceção crítica (severity=3)
- ⏱️ **Timeout** — Timeout (severity=2)

### 4️⃣ Observe em tempo real
Cada ação aparece no Dashboard em **segundos**.

---

## 🎯 O Que Mostrar ao Público

### Na APP (esquerda)
```
Timeline:
├─ Início da jornada
├─ Chamando endpoint mockado...
├─ Renderização concluída com sucesso
└─ [Latência, Status Code, Observability Log]
```

### No DASHBOARD (direita)
```
Discover view:
├─ Eventos aparecem em tempo real
├─ Expandir → ver:
│  ├─ @timestamp
│  ├─ eventName (success/error/timeout)
│  ├─ severity (1-3)
│  ├─ message
│  └─ metadata (cenário, latência, correlation ID)
```

### Ponto-chave para enfatizar:
> "Observabilidade não é apenas logs. É logs estruturados com contexto. 
> Vamos cada requisição com timestamp, severidade, e metadata rica. 
> Em produção, isso ajuda a debugar problemas reais."

---

## 🛑 Quando Terminar (Cleanup)

```bash
cd /Users/ferskt/Desktop/Things/Study/CocoaHeads
docker compose down -v
```

Isso remove:
- Containers
- Volumes (dados do OpenSearch)
- Networks

---

## ⚡ Checklist Dia 28

- [ ] Computador preparado com Docker Desktop ligado
- [ ] Ter rodado `START_HERE.sh` uma vez (não precisa de novo)
- [ ] iPhone Simulator com a app pronta (Cmd+R)
- [ ] Browser com Dashboard aberto (http://localhost:5601)
- [ ] Ter 2 monitores OU janelas lado-a-lado
- [ ] Testar 1 cenário antes de começar apresentação
- [ ] Lembrar de fazer `docker compose down -v` depois

---

## 🆘 FAQ Rápida

**P: Como saber se está tudo ok?**
```bash
curl -s http://localhost:9200/observability-events/_count | jq .
# Deve retornar: { "count": 1, "status": 200 }
```

**P: App não conecta OpenSearch?**
- Verificar na app que "Observability Endpoint" é:
  `http://localhost:9200/observability-events/_doc`
- Verificar que OpenSearch está respondendo (curl acima)

**P: Dashboard está vazio?**
- Clicar Refresh (🔄) em Discover
- Ou executar 1 cenário no app

**P: Preciso resetar?**
```bash
docker compose down -v
bash START_HERE.sh
```

---

## 📞 Referência Rápida

| Componente | URL | Status |
|---|---|---|
| OpenSearch API | http://localhost:9200 | `curl http://localhost:9200` |
| Dashboards | http://localhost:5601 | Abrir no navegador |
| Índice | observability-events | Via Discover |
| Endpoint Ingest | http://localhost:9200/observability-events/_doc | Via app |

---

**Tudo pronto! Boa sorte na talk! 🚀**

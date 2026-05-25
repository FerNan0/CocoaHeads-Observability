# CocoaHeads Demo - Guia de Apresentação

## Layout Recomendado para a Demo

```
┌─────────────────────────────────────────────┐
│         Tela do Apresentador/Projetor       │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────┐   ┌────────────────┐  │
│  │  iPhone (Cmd+1)  │   │  Dashboard     │  │
│  │                  │   │  (Cmd+2)       │  │
│  │  • Cenários      │   │                │  │
│  │  • Logs locais   │   │ • Discover     │  │
│  │  • Timeline      │   │ • Events       │  │
│  │  • Latência      │   │ • Real-time    │  │
│  │                  │   │ • Visualizar   │  │
│  └──────────────────┘   └────────────────┘  │
│                                             │
└─────────────────────────────────────────────┘
```

## Fluxo da Apresentação (Passo-a-Passo)

### 🔧 Preparação (5 min antes)

```bash
cd /Users/ferskt/Desktop/Things/Study/CocoaHeads

# Ter já rodando
docker compose ps  # Verificar que tudo está UP

# Abrir 2 janelas lado a lado:
# Terminal 1: Xcode com iPhone Simulator
# Terminal 2: Safari com Dashboard
```

**URLs para ter abertas:**
- Dashboards: `http://localhost:5601`
- OpenSearch: `http://localhost:9200` (pra mostrar healthcheck)

---

### 📊 Demo - Cenas Sugeridas

#### Cena 1: Explicar o Setup (2 min)
```
"Aqui temos um iOS app simples que faz requisições.
Vamos rastrear cada requisição com observabilidade.
À direita temos OpenSearch Dashboards mostrando os logs em tempo real."
```

**Ação:**
1. Mostrar: `curl http://localhost:9200/` → resposta JSON
2. Mostrar: OpenSearch Dashboards em http://localhost:5601
3. Mostrar: Menu → Discover → Índice `observability-events`

---

#### Cena 2: Success Path (3 min)
```
"Primeira requisição: cenário OK"
```

**Na app:**
1. Cenários picker → Selecionar "ok"
2. Clicar "Run Journey"
3. Esperar terminar (~2s)

**No Dashboard:**
1. Refresh (🔄) em Discover
2. Aparecem eventos com `eventName: promo_card_success`
3. Expandir linha → Ver @timestamp, severity, metadata

**Narrar:**
- "Severidade 1 = sucesso, nenhum problema"
- "Latência ~500ms, status 200"
- "Metadata inclui todo contexto: scenario, latency_ms, status_code"

---

#### Cena 3: Error Path (3 min)
```
"Segundo teste: cenário de erro customizado"
```

**Na app:**
1. Cenários picker → Selecionar "custom_error"
2. Clicar "Run Journey"
3. Esperar terminar

**No Dashboard:**
1. Refresh (🔄)
2. Aparecem eventos com `eventName: promo_card_backend_error`
3. Severidade 2 (warning/error)

**Narrar:**
- "Severidade 2 = erro do servidor"
- "Capturamos: código de erro, correlation ID, mensagem customizada"
- "Tudo isso automático via observabilidade"

---

#### Cena 4: Exceção (2 min)
```
"Terceiro teste: exceção não tratada"
```

**Na app:**
1. Cenários picker → Selecionar "exception"
2. Clicar "Run Journey"
3. Esperar terminar

**No Dashboard:**
1. Refresh (🔄)
2. Eventos com `eventName: promo_card_generic_error`
3. Severidade 3 (critical)

**Narrar:**
- "Severidade 3 = crítico"
- "Conseguimos rastrear até as exceções não tratadas"
- "Isso que é observabilidade: ver TUDO que acontece"

---

## 🎯 Pontos-Chave para Enfatizar

1. **Observabilidade ≠ Logs Simples**
   - Logs estruturados com contexto
   - Metadata rica (cenário, latência, IDs)
   - Rastreável end-to-end

2. **Diferentes Severidades**
   - 1 = Info (sucesso)
   - 2 = Warning (erro esperado)
   - 3 = Critical (exceção)

3. **Rastreamento Automático**
   - `@timestamp` automático
   - Correlação via `exceptionLocale` (correlation ID)
   - Latência capturada

4. **Dashboard em Tempo Real**
   - Dados aparecem segundos após ação
   - Útil para debugging live
   - Visualizações ajudam a entender padrões

---

## 📝 Script Sugerido

```
"Observabilidade em iOS é crucial. Vamos ver como implementar.

A gente tem uma app simples que chama um endpoint mockado.
Para cada requisição, capturamos:
  • O que aconteceu (eventName)
  • Qual foi o resultado (status, severidade)
  • Quanto tempo levou (latency)
  • Contexto adicional (metadata)

E em tempo REAL, tudo aparece aqui no Dashboard.

Vamos ver alguns cenários:"

[Executar: ok]
"Sucesso total. Info log, sem erros."

[Executar: custom_error]
"Erro customizado do backend. Warning log com detalhes."

[Executar: exception]
"Exceção não tratada. Critical log para investigação."

[Apontando pro Dashboard]
"Vejam: em segundos, cada ação apareceu aqui.
Isso permite:
  • Debugging em produção
  • Identificar padrões de erro
  • Entender experiência do usuário real

Perguntas?"
```

---

## ⚡ Troubleshooting na Hora

**P: Dashboard não mostra dados?**
- Fazer Refresh (🔄) em Discover
- Ou esperar 5s (retentive do @timestamp)

**P: App não conecta OpenSearch?**
- Verificar URL: `http://localhost:9200/observability-events/_doc`
- Usar console da app para ver logs locais (tab Observability Log)

**P: OpenSearch está lento?**
- Normal na primeira requisição
- Segundas em diante são rápidas

---

## 📦 Checklist Dia-da-Talk

- [ ] `docker compose ps` — todos UP
- [ ] OpenSearch respondendo: `curl http://localhost:9200`
- [ ] Dashboards acessível: http://localhost:5601
- [ ] Discover mostra índice `observability-events`
- [ ] Pelo menos 1 evento de teste presente
- [ ] App buildada e no Simulator
- [ ] 2 monitores (ou janelas lado-a-lado)
- [ ] Fazer 1 test run antes de começar live

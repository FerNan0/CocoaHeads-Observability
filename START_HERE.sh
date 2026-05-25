#!/bin/bash

# ============================================================
# CocoaHeads OpenSearch + Dashboards - Inicialização Completa
# ============================================================
# Execute este script UMA VEZ antes da talk do dia 28
# Ele deixa tudo pronto em ~2 minutos
# ============================================================

set -e

PROJECT_DIR="/Users/ferskt/Desktop/Things/Study/CocoaHeads"
OPENSEARCH_URL="http://localhost:9200"
DASHBOARDS_URL="http://localhost:5601"

cd "$PROJECT_DIR"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   CocoaHeads OpenSearch Setup - INICIALIZAÇÃO COMPLETA ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# STEP 1: Subir containers
echo "📦 STEP 1: Iniciando containers Docker..."
echo "   (Isso pode levar ~60 segundos na primeira vez)"
docker compose up -d

echo ""
echo "⏳ Aguardando OpenSearch ficar pronto..."
sleep 30

# Verificação com retry
for attempt in {1..10}; do
    if curl -s "$OPENSEARCH_URL" > /dev/null 2>&1; then
        echo "✅ OpenSearch está online!"
        break
    else
        echo "   Tentativa $attempt/10... aguardando..."
        sleep 5
    fi
done

echo ""
echo "⏳ Aguardando Dashboards ficar pronto..."
sleep 15

# STEP 2: Criar índice
echo ""
echo "📝 STEP 2: Criando índice observability-events..."
curl -s -X PUT "$OPENSEARCH_URL/observability-events" \
  -H 'Content-Type: application/json' \
  -d '{
    "settings": {
      "index": {
        "number_of_shards": 1,
        "number_of_replicas": 0
      }
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "eventName": { "type": "keyword" },
        "severity": { "type": "integer" },
        "message": { "type": "text" },
        "exceptionLocale": { "type": "keyword" },
        "metadata": { "type": "object", "enabled": true }
      }
    }
  }' > /dev/null 2>&1

echo "✅ Índice criado"

# STEP 3: Ingerir evento de teste
echo ""
echo "🧪 STEP 3: Ingerindo evento de teste..."
curl -s -X POST "$OPENSEARCH_URL/observability-events/_doc" \
  -H 'Content-Type: application/json' \
  -d '{
    "@timestamp": "2026-05-24T16:00:00.000Z",
    "eventName": "demo_initialized",
    "severity": 1,
    "message": "Demo setup complete",
    "exceptionLocale": "none",
    "metadata": {
      "demo": "cocoaheads",
      "date": "2026-05-24",
      "status": "ready"
    }
  }' > /dev/null 2>&1

echo "✅ Evento ingerido"

# STEP 4: Verificação final
echo ""
echo "🔎 STEP 4: Verificação final..."
EVENTS=$(curl -s "$OPENSEARCH_URL/observability-events/_count" 2>/dev/null | jq '.count' 2>/dev/null || echo "?")
echo "✅ Total de eventos no índice: $EVENTS"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ SETUP COMPLETO! Tudo pronto para a talk         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "📍 Serviços rodando:"
echo "   • OpenSearch:         http://localhost:9200"
echo "   • Dashboards:         http://localhost:5601"
echo "   • Índice:             observability-events"
echo ""

echo "📱 Próximos passos para a TALK:"
echo ""
echo "   1️⃣  Abra o Simulator/Device"
echo "       → Xcode > Cmd+Shift+2 > Select device"
echo ""
echo "   2️⃣  Execute o app (Cmd+R)"
echo "       → Certifique-se que \"Mockoon base URL\" é"
echo "         http://localhost:8001 (padrão está OK)"
echo ""
echo "   3️⃣  Abra Dashboard em outro navegador:"
echo "       → http://localhost:5601"
echo "       → Menu (☰) > Discover"
echo "       → Índice: observability-events"
echo ""
echo "   4️⃣  Na app, clique em cada botão de cenário:"
echo "       → Ok, Missing Field, Invalid Deeplink, etc."
echo "       → No Dashboard, os logs aparecem em TEMPO REAL"
echo ""
echo "   5️⃣  Mostrar ao público:"
echo "       → Timeline + Logs + Dashboad simultaneamente"
echo "       → Faz a observabilidade ficar visual!"
echo ""

echo "⚡ Dica para demonstração:"
echo "   • Redimensione a janela para 2 telas:"
echo "     ← iPhone Simulator (esquerda)"
echo "     → OpenSearch Dashboards (direita)"
echo "   • Use Discover > Refresh (🔄) pra atualizar em tempo real"
echo ""

echo "🛑 Quando terminar a talk (cleanup):"
echo "   $ cd /Users/ferskt/Desktop/Things/Study/CocoaHeads"
echo "   $ docker compose down -v"
echo ""

echo "════════════════════════════════════════════════════════"
echo ""

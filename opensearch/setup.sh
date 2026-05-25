#!/bin/bash

set -e

OPENSEARCH_URL="http://localhost:9200"
DASHBOARDS_URL="http://localhost:5601"

echo "=================================="
echo "   CocoaHeads OpenSearch Setup"
echo "=================================="
echo ""

# Função para esperar OpenSearch ficar online
wait_for_opensearch() {
    echo "⏳ Aguardando OpenSearch ficar online..."
    for i in {1..60}; do
        if curl -s "$OPENSEARCH_URL" > /dev/null 2>&1; then
            echo "✅ OpenSearch está online!"
            return 0
        fi
        echo "   Tentativa $i/60... aguardando..."
        sleep 1
    done
    echo "❌ OpenSearch não respondeu em 60 segundos"
    exit 1
}

# Função para esperar Dashboards ficar online
wait_for_dashboards() {
    echo "⏳ Aguardando OpenSearch Dashboards ficar online..."
    for i in {1..60}; do
        if curl -s "$DASHBOARDS_URL/api/status" > /dev/null 2>&1; then
            echo "✅ Dashboards está online!"
            return 0
        fi
        echo "   Tentativa $i/60... aguardando..."
        sleep 1
    done
    echo "❌ Dashboards não respondeu em 60 segundos"
    exit 1
}

# Step 1: Aguardar OpenSearch
wait_for_opensearch
echo ""

# Step 2: Criar índice com mapeamento
echo "📝 Criando índice observability-events..."
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
  }' | jq -r '.acknowledged // .error.type'

echo "✅ Índice criado"
echo ""

# Step 3: Ingerir evento de teste
echo "🧪 Ingerindo evento de teste..."
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
      "status": "initialized"
    }
  }' | jq -r '._id // .error.type'

echo "✅ Evento de teste ingerido"
echo ""

# Step 4: Aguardar Dashboards
wait_for_dashboards
echo ""

# Step 5: Criar Index Pattern
echo "🔍 Criando Index Pattern no Dashboards..."
curl -s -X POST "$DASHBOARDS_URL/api/saved_objects/index-pattern/observability-events-*" \
  -H 'kbn-xsrf: true' \
  -H 'Content-Type: application/json' \
  -d '{
    "attributes": {
      "title": "observability-events*",
      "timeFieldName": "@timestamp",
      "fields": "[]",
      "sourceFilters": "[]",
      "fieldFormatMap": "{}"
    }
  }' 2>/dev/null | jq -r '.id // "Pattern criado ou já existe"' || echo "Index Pattern já existe"

echo "✅ Index Pattern pronto"
echo ""

# Step 6: Verificação final
echo "🔎 Verificando dados..."
EVENTS=$(curl -s "$OPENSEARCH_URL/observability-events/_count" | jq '.count')
echo "✅ Total de eventos: $EVENTS"
echo ""

echo "=================================="
echo "   ✅ SETUP CONCLUÍDO!"
echo "=================================="
echo ""
echo "Próximas ações:"
echo "  1️⃣  Abra Dashboards:"
echo "      → http://localhost:5601"
echo ""
echo "  2️⃣  Navegue até Discovery:"
echo "      → Menu > Discovery"
echo "      → Selecione índice 'observability-events*'"
echo ""
echo "  3️⃣  Execute a app iOS:"
echo "      → Clique em um botão de cenário"
echo "      → Os logs aparecerão em tempo real"
echo ""
echo "  4️⃣  Veja a timeline:"
echo "      → Os eventos aparecem no topo da página"
echo "      → Use refresh (🔄) para atualizar"
echo ""

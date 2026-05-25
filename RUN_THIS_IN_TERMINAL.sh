#!/bin/bash

# EXECUTE NO TERMINAL (não em background):
# bash /Users/ferskt/Desktop/Things/Study/CocoaHeads/RUN_THIS_IN_TERMINAL.sh

cd /Users/ferskt/Desktop/Things/Study/CocoaHeads

echo ""
echo "════════════════════════════════════════════════════════"
echo "   SUBINDO OPENSEARCH + DASHBOARDS"
echo "════════════════════════════════════════════════════════"
echo ""

echo "1️⃣  Iniciando containers..."
docker compose up -d

echo ""
echo "2️⃣  Status dos containers:"
docker compose ps

echo ""
echo "3️⃣  Aguardando OpenSearch ficar pronto (30s)..."
sleep 30

echo ""
echo "4️⃣  Criando índice..."
curl -X PUT "http://localhost:9200/observability-events" \
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
        "metadata": { "type": "object" }
      }
    }
  }'

echo ""
echo ""
echo "5️⃣  Inserindo evento de teste..."
curl -X POST "http://localhost:9200/observability-events/_doc" \
  -H 'Content-Type: application/json' \
  -d '{
    "@timestamp": "2026-05-24T16:00:00.000Z",
    "eventName": "demo_ready",
    "severity": 1,
    "message": "Setup OK",
    "exceptionLocale": "none",
    "metadata": {"status": "ready"}
  }'

echo ""
echo ""
echo "════════════════════════════════════════════════════════"
echo "   ✅ PRONTO!"
echo "════════════════════════════════════════════════════════"
echo ""
echo "Abra no navegador:"
echo "  → http://localhost:5601"
echo ""
echo "Execute a app no Xcode:"
echo "  → Cmd+R no Simulator"
echo ""

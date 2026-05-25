# OpenSearch Setup para CocoaHeads Demo

## Quick Start (2 passos)

### 1. Subir containers (primeira vez leva ~60s)
```bash
cd /Users/ferskt/Desktop/Things/Study/CocoaHeads
docker compose up -d
```

Aguarde até que ambos os containers estejam saudáveis:
```bash
docker compose ps
# Deve mostrar: cocoaheads-opensearch RUNNING
#               cocoaheads-dashboards RUNNING
```

### 2. Criar índice + testar
```bash
bash opensearch/setup.sh
```

Isso vai:
- ✅ Criar índice `observability-events` com mapeamento correto
- ✅ Ingerir um evento de teste
- ✅ Criar Index Pattern no Dashboards
- ✅ Verificar que está tudo funcionando

## URLs Após Setup

- **OpenSearch API**: http://localhost:9200
- **OpenSearch Dashboards**: http://localhost:5601

## Fluxo da Demo

1. Abra http://localhost:5601 no navegador
2. Vá em "Discover" → Selecione índice `observability-events`
3. Execute cenários no app iOS/Simulator
4. Os logs aparecem em tempo real no Dashboards

## Testando Manualmente

### Ver os logs capturados
```bash
curl -s "http://localhost:9200/observability-events/_search?pretty"
```

### Buscar por tipo de evento
```bash
curl -s -X POST "http://localhost:9200/observability-events/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "match": {
        "eventName": "promo_card_success"
      }
    }
  }' | jq '.hits.hits[].fields'
```

### Buscar por severidade >= 2 (erros)
```bash
curl -s -X POST "http://localhost:9200/observability-events/_search" \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "range": {
        "severity": {
          "gte": 2
        }
      }
    }
  }' | jq '.hits.hits[]._source'
```

## Quando Terminar (cleanup)

```bash
docker compose down -v
```

## Troubleshooting

**P: OpenSearch está lento na primeira vez?**
R: Normal! Na primeira inicialização ele usa ~30s. Deixa rodar.

**P: Dashboards diz "Waiting for data"?**
R: Espera o app logar algo primeiro (execute um cenário).

**P: Quer resetar tudo?**
R: `docker compose down -v && docker compose up -d && bash opensearch/setup.sh`

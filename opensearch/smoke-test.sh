#!/bin/sh

set -eu

curl -sS -X POST "http://localhost:9200/observability-events/_doc" \
  -H 'Content-Type: application/json' \
  -d '{
    "@timestamp": "2026-05-24T00:00:00.000Z",
    "eventName": "promo_card_backend_error",
    "severity": 2,
    "message": "validation_failed",
    "exceptionLocale": "corr-123",
    "metadata": {
      "scenario": "custom_error",
      "latency_ms": "42",
      "status_code": "400"
    }
  }'

curl -sS "http://localhost:9200/observability-events/_search?q=eventName:promo_card_backend_error&pretty"

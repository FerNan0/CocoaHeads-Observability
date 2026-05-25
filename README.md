# CocoaHeads Demo

SwiftUI demo app for an observability talk.

## Features

- One button to execute a journey.
- Scenario picker for `ok`, `missing_field`, `invalid_deeplink`, `custom_error`, `timeout`, and `exception`.
- Editable Mockoon host field, default `http://localhost:8001`.
- Success and failure routes with dedicated screens.
- Response card, timeline, metrics, and observability log.
- Editable OpenSearch endpoint field, default `http://localhost:9200/observability-events/_doc`.
- If reachable, the app POSTs observability events to that endpoint.

## Notes

- This is a lightweight demo scaffold.
- Replace `DemoAPI` with a real Mockoon endpoint when ready.
- Local OpenSearch is available via `docker compose up -d`.
- Dashboards runs at `http://localhost:5601`.

## Query examples

```json
GET observability-events/_search
{
  "query": {
    "term": {
      "eventName.keyword": "promo_card_backend_error"
    }
  }
}
```

```json
GET observability-events/_search
{
  "query": {
    "range": {
      "severity": {
        "gte": 3
      }
    }
  }
}
```

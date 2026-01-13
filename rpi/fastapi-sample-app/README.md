# FastAPI Sample Application

This is a sample FastAPI application that demonstrates how to create a simple web server with API endpoints.

## Project Structure

```
fastapi-sample-app
├── app
│   ├── main.py          # Entry point of the FastAPI application with opentelemetry output
│   ├── api
│   │   └── endpoints.py # API endpoints definition
│   └── models
│       └── __init__.py  # Data models (currently empty)
├── requirements.txt     # Project dependencies
└── README.md            # Project documentation
```

## Requirements

To run this application, you need to have Python installed. You can install the required dependencies using pip:

```bash
pip install -r requirements.txt
```

## Running the Application

To start the FastAPI server, run the following command:

```bash
uvicorn app.main:app --reload
```

This will start the server in development mode, and you can access the API at `http://127.0.0.1:8000`.

## API Endpoints

The application includes a sample endpoint that returns a greeting message. You can access it at:

```
GET /greet
```

This endpoint will return a JSON response with a greeting message.


## Tempo vs Jaeger

Tempo and Jaeger are two popular backends for storing and querying distributed traces. Briefly:

- **Tempo** (Grafana Tempo)
    - Maintained by Grafana Labs.
    - Designed for large-scale, cost-efficient trace storage using object stores (S3, GCS, or local).
    - Integrates tightly with Grafana for trace visualization and linking from metrics and logs.
    - Easy to operate in a Grafana-centric observability stack.

- **Jaeger**
    - Originally developed by Uber, now a CNCF project.
    - Provides its own UI, and supports backends like Elasticsearch or Cassandra for storage.
    - Mature ecosystem and rich feature set for trace sampling, storage and querying.

Both support OTLP ingestion from the OpenTelemetry Collector.

## Do you need tracing (Tempo/Jaeger)?

Consider adding a tracing backend (Tempo or Jaeger) if any of the following apply:

- You run a distributed system or multiple microservices and need to follow requests across services.
- You want to diagnose latency hotspots and see time spent in each service/span.
- You need causal context to correlate metrics and logs with traces for debugging.

You can skip adding Tempo/Jaeger if your needs are limited to:

- Basic metrics collection and alerting (Prometheus + Grafana).
- Application logging (Loki or other log backends) without distributed request flow analysis.

In short: tracing is optional but highly recommended for multi-service environments where end-to-end request visibility matters.



# OpenTelemetry, Prometheus, and Grafana Sequence Flow

```mermaid



sequenceDiagram
    %% Participants
    participant Client
    participant REST_API as REST API
    participant OTel_SDK as OpenTelemetry SDK
    participant OTel_Collector as OpenTelemetry Collector
    participant Prometheus
    participant Tempo/Jaeger
    participant Loki
    participant Elastic
    participant Splunk
    participant Grafana

    %% Request path and SDK generation
    Client->>REST_API: HTTP request
    REST_API->>OTel_SDK: Generate spans/traces/metrics/logs

    %% SDK exports to Collector
    OTel_SDK->>OTel_Collector: Export via OTLP (gRPC/HTTP)

    %% Metrics path
    OTel_Collector->>Prometheus: Metrics (remote_write) or expose scrape target
    Prometheus-->>Grafana: Time-series data
    Grafana->>Prometheus: PromQL queries

    %% Traces path
    OTel_Collector->>Tempo/Jaeger: Traces (OTLP)
    Grafana->>Tempo/Jaeger: Trace queries
    Tempo/Jaeger-->>Grafana: Trace results

    %% Logs paths
    OTel_Collector->>Loki: Logs (OTLP)
    Grafana->>Loki: Log queries
    Loki-->>Grafana: Log results

    %% Optional enterprise log backends
    OTel_Collector->>Elastic: Logs (OTLP/HTTP)
    OTel_Collector->>Splunk: Logs (HEC/OTLP via bridge)

    %% Optional queries (if configured)
    Grafana-->>Elastic: (optional) Query via datasource plugin
    %% Splunk is typically queried via Splunk UI; Grafana integration is uncommon

```
## License

This project is licensed under the MIT License.
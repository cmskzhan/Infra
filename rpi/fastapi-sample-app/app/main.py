from fastapi import FastAPI
from app.api import endpoints  
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
# from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter # <-- uncomment this line to use OTLP exporter
from opentelemetry.sdk.trace.export import ConsoleSpanExporter  # <-- console exporter for demonstration
from opentelemetry import trace

app = FastAPI()

app.include_router(endpoints.router)

@app.get("/")
def read_root():
    return {"message": "Welcome to the FastAPI Sample App!"}

# Health check endpoint for monitoring
@app.get("/health")
def health():
    return {"status": "ok"}

# OpenTelemetry setup
resource = Resource(attributes={"service.name": "fastapi-sample-app"})
provider = TracerProvider(resource=resource)
trace.set_tracer_provider(provider)

# otlp_exporter = OTLPSpanExporter()  # <-- uncomment this line to use OTLP exporter
otlp_exporter = ConsoleSpanExporter()  # <-- using console exporter for demonstration
span_processor = BatchSpanProcessor(otlp_exporter)
provider.add_span_processor(span_processor)

FastAPIInstrumentor.instrument_app(app)
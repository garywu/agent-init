# Monitoring and Observability Patterns

Comprehensive patterns for implementing monitoring, logging, metrics, and observability in development projects.

## Overview

Modern applications require comprehensive observability:
- **Metrics**: What's happening (counters, gauges, histograms)
- **Logs**: Why it's happening (events, errors, debug info)
- **Traces**: How it's happening (request flow, performance)
- **Health Checks**: Is it working (liveness, readiness)

## Local Development Stack

### 1. Docker Compose Observability Stack

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  # Metrics collection
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/usr/share/prometheus/console_libraries'
      - '--web.console.templates=/usr/share/prometheus/consoles'
    networks:
      - monitoring

  # Metrics visualization
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    volumes:
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - monitoring

  # Log aggregation
  loki:
    image: grafana/loki:latest
    ports:
      - "3100:3100"
    volumes:
      - ./monitoring/loki-config.yaml:/etc/loki/local-config.yaml
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - monitoring

  # Log shipping
  promtail:
    image: grafana/promtail:latest
    volumes:
      - ./monitoring/promtail-config.yaml:/etc/promtail/config.yml
      - /var/log:/var/log:ro
      - ./logs:/app/logs:ro
    command: -config.file=/etc/promtail/config.yml
    depends_on:
      - loki
    networks:
      - monitoring

  # Distributed tracing
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "5775:5775/udp"
      - "6831:6831/udp"
      - "6832:6832/udp"
      - "5778:5778"
      - "16686:16686"  # UI
      - "14268:14268"
      - "14250:14250"
      - "9411:9411"
    environment:
      - COLLECTOR_ZIPKIN_HOST_PORT=:9411
    networks:
      - monitoring

  # Alerts
  alertmanager:
    image: prom/alertmanager:latest
    ports:
      - "9093:9093"
    volumes:
      - ./monitoring/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
    networks:
      - monitoring

volumes:
  prometheus_data:
  grafana_data:
  loki_data:

networks:
  monitoring:
    driver: bridge
```

### 2. Configuration Files

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - alertmanager:9093

rule_files:
  - "alerts/*.yml"

scrape_configs:
  # Application metrics
  - job_name: 'app'
    static_configs:
      - targets: ['host.docker.internal:8080']
    metrics_path: '/metrics'
  
  # Node exporter for system metrics
  - job_name: 'node'
    static_configs:
      - targets: ['node-exporter:9100']
  
  # Container metrics
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']
```

```yaml
# monitoring/loki-config.yaml
auth_enabled: false

server:
  http_listen_port: 3100
  grpc_listen_port: 9096

ingester:
  wal:
    enabled: true
    dir: /loki/wal
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
    cache_location: /loki/boltdb-shipper-cache
    cache_ttl: 24h
  filesystem:
    directory: /loki/chunks

limits_config:
  enforce_metric_name: false
  reject_old_samples: true
  reject_old_samples_max_age: 168h
```

### 3. Application Instrumentation

#### Node.js Example

```javascript
// metrics.js
const prometheus = require('prom-client');
const { createLogger, format, transports } = require('winston');
const LokiTransport = require('winston-loki');

// Prometheus metrics
const register = new prometheus.Registry();

// Default metrics (CPU, memory, etc.)
prometheus.collectDefaultMetrics({ register });

// Custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.5, 1, 2, 5]
});
register.registerMetric(httpRequestDuration);

const httpRequestTotal = new prometheus.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});
register.registerMetric(httpRequestTotal);

// Winston logger with Loki transport
const logger = createLogger({
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    format.json()
  ),
  defaultMeta: {
    service: 'my-app',
    environment: process.env.NODE_ENV || 'development'
  },
  transports: [
    new transports.Console(),
    new LokiTransport({
      host: 'http://localhost:3100',
      labels: { app: 'my-app' },
      json: true,
      batching: true,
      batchInterval: 5
    })
  ]
});

// Express middleware
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    const labels = {
      method: req.method,
      route: req.route?.path || req.path,
      status_code: res.statusCode
    };
    
    httpRequestDuration.observe(labels, duration);
    httpRequestTotal.inc(labels);
    
    logger.info('HTTP Request', {
      ...labels,
      duration,
      ip: req.ip,
      userAgent: req.get('user-agent')
    });
  });
  
  next();
};

module.exports = { register, logger, metricsMiddleware };
```

#### Python Example

```python
# monitoring.py
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from opentelemetry import trace
from opentelemetry.exporter.jaeger import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
import logging
import json
from pythonjsonlogger import jsonlogger

# Prometheus metrics
request_count = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

request_duration = Histogram(
    'http_request_duration_seconds',
    'HTTP request duration',
    ['method', 'endpoint']
)

# Structured logging
class CustomJsonFormatter(jsonlogger.JsonFormatter):
    def add_fields(self, log_record, record, message_dict):
        super(CustomJsonFormatter, self).add_fields(log_record, record, message_dict)
        log_record['timestamp'] = record.created
        log_record['level'] = record.levelname
        log_record['service'] = 'my-app'

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = CustomJsonFormatter()
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)

# Jaeger tracing
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)

span_processor = BatchSpanProcessor(jaeger_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Flask middleware example
from flask import Flask, request, Response
import time

app = Flask(__name__)

@app.before_request
def before_request():
    request.start_time = time.time()
    
@app.after_request
def after_request(response):
    if hasattr(request, 'start_time'):
        duration = time.time() - request.start_time
        
        # Metrics
        request_count.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown',
            status=response.status_code
        ).inc()
        
        request_duration.labels(
            method=request.method,
            endpoint=request.endpoint or 'unknown'
        ).observe(duration)
        
        # Logging
        logger.info('http_request', extra={
            'method': request.method,
            'path': request.path,
            'status': response.status_code,
            'duration': duration,
            'ip': request.remote_addr
        })
    
    return response

@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)
```

### 4. Health Checks

```javascript
// healthcheck.js
class HealthChecker {
  constructor() {
    this.checks = new Map();
  }
  
  addCheck(name, checkFn) {
    this.checks.set(name, checkFn);
  }
  
  async runChecks() {
    const results = {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      checks: {}
    };
    
    for (const [name, checkFn] of this.checks) {
      try {
        const start = Date.now();
        const result = await checkFn();
        results.checks[name] = {
          status: 'healthy',
          duration: Date.now() - start,
          ...result
        };
      } catch (error) {
        results.status = 'unhealthy';
        results.checks[name] = {
          status: 'unhealthy',
          error: error.message
        };
      }
    }
    
    return results;
  }
}

// Usage
const health = new HealthChecker();

// Database check
health.addCheck('database', async () => {
  const result = await db.query('SELECT 1');
  return { connected: true };
});

// Redis check
health.addCheck('redis', async () => {
  await redis.ping();
  return { connected: true };
});

// External API check
health.addCheck('external_api', async () => {
  const response = await fetch('https://api.example.com/health');
  return { 
    status: response.status,
    reachable: response.ok 
  };
});

// Express routes
app.get('/health', async (req, res) => {
  const results = await health.runChecks();
  const statusCode = results.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(results);
});

// Kubernetes probes
app.get('/health/live', (req, res) => {
  // Simple liveness check
  res.status(200).json({ status: 'alive' });
});

app.get('/health/ready', async (req, res) => {
  // Readiness includes dependency checks
  const results = await health.runChecks();
  const statusCode = results.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(results);
});
```

### 5. Grafana Dashboards

```json
// monitoring/grafana/provisioning/dashboards/app-dashboard.json
{
  "dashboard": {
    "title": "Application Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Request Duration",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ],
        "type": "graph"
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(http_requests_total{status_code=~\"5..\"}[5m])",
            "legendFormat": "5xx errors"
          }
        ],
        "type": "graph"
      }
    ]
  }
}
```

### 6. Alerts Configuration

```yaml
# monitoring/alerts/app-alerts.yml
groups:
  - name: app_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status_code=~"5.."}[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"
      
      - alert: HighRequestLatency
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High request latency"
          description: "95th percentile latency is {{ $value }} seconds"
      
      - alert: ServiceDown
        expr: up{job="app"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service is down"
          description: "{{ $labels.instance }} is down"
```

## Production Patterns

### 1. Centralized Logging

```bash
#!/usr/bin/env bash
# setup-logging.sh

# Configure rsyslog for centralized logging
setup_rsyslog() {
    cat > /etc/rsyslog.d/50-app.conf << 'EOF'
# App logs
$ModLoad imfile
$InputFilePollInterval 10
$InputFileName /var/log/app/app.log
$InputFileTag app:
$InputFileStateFile app-log-state
$InputFileSeverity info
$InputFileFacility local0
$InputRunFileMonitor

# Forward to remote syslog
*.* @@remote-syslog.example.com:514
EOF
    
    systemctl restart rsyslog
}

# Configure journald forwarding
setup_journald() {
    mkdir -p /etc/systemd/journald.conf.d/
    cat > /etc/systemd/journald.conf.d/forward.conf << 'EOF'
[Journal]
ForwardToSyslog=yes
MaxRetentionSec=7day
SystemMaxUse=1G
EOF
    
    systemctl restart systemd-journald
}
```

### 2. APM Integration

```javascript
// apm.js - Application Performance Monitoring
const apm = require('elastic-apm-node');

// Start APM
const apmAgent = apm.start({
  serviceName: process.env.SERVICE_NAME || 'my-app',
  secretToken: process.env.ELASTIC_APM_SECRET_TOKEN,
  serverUrl: process.env.ELASTIC_APM_SERVER_URL || 'http://localhost:8200',
  environment: process.env.NODE_ENV || 'development',
  
  // Capture request body
  captureBody: 'all',
  
  // Error filtering
  errorOnAbortedRequests: true,
  
  // Transaction sampling
  transactionSampleRate: process.env.NODE_ENV === 'production' ? 0.1 : 1.0,
  
  // Custom context
  globalLabels: {
    region: process.env.AWS_REGION,
    deployment: process.env.DEPLOYMENT_ID
  }
});

module.exports = apmAgent;
```

### 3. Structured Logging Best Practices

```javascript
// logger.js
class StructuredLogger {
  constructor(service) {
    this.service = service;
    this.context = {};
  }
  
  setContext(context) {
    this.context = { ...this.context, ...context };
  }
  
  log(level, message, data = {}) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      service: this.service,
      message,
      ...this.context,
      ...data,
      
      // Add trace context if available
      trace_id: this.getTraceId(),
      span_id: this.getSpanId(),
      
      // Add error details
      ...(data.error && {
        error: {
          message: data.error.message,
          stack: data.error.stack,
          type: data.error.constructor.name
        }
      })
    };
    
    console.log(JSON.stringify(logEntry));
  }
  
  info(message, data) {
    this.log('info', message, data);
  }
  
  error(message, error, data = {}) {
    this.log('error', message, { ...data, error });
  }
  
  // Correlation with traces
  getTraceId() {
    // Implementation depends on tracing library
    return null;
  }
  
  getSpanId() {
    // Implementation depends on tracing library
    return null;
  }
}
```

## Debugging Patterns

### 1. Debug Mode Configuration

```bash
# Enable detailed debugging
export DEBUG=app:*
export LOG_LEVEL=debug
export TRACE_ENABLED=true
export PROFILE_ENABLED=true

# Run with debugging
node --inspect=0.0.0.0:9229 app.js
```

### 2. Performance Profiling

```javascript
// profiling.js
const v8Profiler = require('v8-profiler-next');
const fs = require('fs');

class Profiler {
  startCPUProfile(name) {
    v8Profiler.startProfiling(name, true);
    return () => {
      const profile = v8Profiler.stopProfiling(name);
      profile.export((error, result) => {
        fs.writeFileSync(`${name}-${Date.now()}.cpuprofile`, result);
        profile.delete();
      });
    };
  }
  
  takeHeapSnapshot(name) {
    const snapshot = v8Profiler.takeSnapshot(name);
    snapshot.export((error, result) => {
      fs.writeFileSync(`${name}-${Date.now()}.heapsnapshot`, result);
      snapshot.delete();
    });
  }
}

// Usage in Express
if (process.env.PROFILE_ENABLED === 'true') {
  const profiler = new Profiler();
  
  app.get('/debug/cpu-profile', (req, res) => {
    const stop = profiler.startCPUProfile('cpu-profile');
    setTimeout(() => {
      stop();
      res.send('CPU profile saved');
    }, 30000); // Profile for 30 seconds
  });
  
  app.get('/debug/heap-snapshot', (req, res) => {
    profiler.takeHeapSnapshot('heap-snapshot');
    res.send('Heap snapshot saved');
  });
}
```

## Best Practices

1. **Start Simple**
   - Begin with basic metrics and logs
   - Add complexity as needed
   - Focus on actionable data

2. **Standardize**
   - Use consistent metric names
   - Standardize log formats
   - Follow OpenTelemetry conventions

3. **Secure**
   - Don't log sensitive data
   - Secure metric endpoints
   - Use TLS for data transmission

4. **Optimize**
   - Sample high-volume data
   - Use appropriate retention
   - Batch operations when possible

## External References

- [Prometheus Best Practices](https://prometheus.io/docs/practices/)
- [OpenTelemetry Documentation](https://opentelemetry.io/docs/)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
- [Elastic APM](https://www.elastic.co/guide/en/apm/)
- [Jaeger Tracing](https://www.jaegertracing.io/docs/)
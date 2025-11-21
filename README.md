# .NET 8 Web API Sample with Docker and Datadog

A sample ASP.NET Core 8 Web API application with Docker support and Datadog integration.

## Features

- ✅ .NET 8 Web API with Swagger/OpenAPI
- ✅ Alpine-based Docker image (minimal size)
- ✅ Multi-stage Docker build
- ✅ Docker Compose setup with Datadog Agent
- ✅ Health check endpoints
- ✅ Structured logging
- ✅ Ready for Datadog APM integration
- ✅ Non-root container user (security best practice)

## Project Structure

```
dotnet-api-sample/
├── Controllers/
│   └── WeatherForecastController.cs
├── Models/
│   └── WeatherForecast.cs
├── Program.cs
├── DotNetApiSample.csproj
├── appsettings.json
├── appsettings.Development.json
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .env.example
└── README.md
```

## Prerequisites

- Docker 24.0.7+ (or compatible version)
- Docker Compose 3.8+
- .NET 8 SDK (for local development only)

## Quick Start

### 1. Clone and Setup

```bash
cd /Users/nuttee.jirattivongvibul/Projects/nuttee-se-gemini-cli/temp_working/AXONS/dotnet-api-sample

# Create .env file from example
cp .env.example .env

# Edit .env and add your Datadog API key
nano .env
```

### 2. Build and Run with Docker Compose

```bash
# Build and start all services
docker-compose up -d --build

# View logs
docker-compose logs -f dotnet-api

# View Datadog agent logs
docker-compose logs -f datadog-agent
```

### 3. Access the API

- **API Base URL**: http://localhost:5000
- **Swagger UI**: http://localhost:5000/swagger
- **Health Check**: http://localhost:5000/health
- **Info Endpoint**: http://localhost:5000/info

### 4. Test the API

```bash
# Get weather forecast
curl http://localhost:5000/api/weatherforecast

# Get specific day forecast
curl http://localhost:5000/api/weatherforecast/1

# Check health
curl http://localhost:5000/health

# Get service info
curl http://localhost:5000/info
```

## Available Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check endpoint |
| GET | `/info` | Service information |
| GET | `/api/weatherforecast` | Get 5-day weather forecast |
| GET | `/api/weatherforecast/{id}` | Get forecast for specific day |
| POST | `/api/weatherforecast` | Create new forecast |
| GET | `/swagger` | Swagger UI documentation |

## Docker Commands

### Build Only

```bash
docker build -t dotnet-api-sample:latest .
```

### Run Without Compose

```bash
docker run -d \
  --name dotnet-api \
  -p 5000:5000 \
  -e DD_ENV=sit \
  -e DD_SERVICE=dotnet-api-sample \
  -e DD_VERSION=1.0.0 \
  dotnet-api-sample:latest
```

### Docker Compose Commands

```bash
# Start services
docker-compose up -d

# Start with rebuild
docker-compose up -d --build

# Stop services
docker-compose down

# Stop and remove volumes
docker-compose down -v

# View logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f dotnet-api

# Restart a service
docker-compose restart dotnet-api

# Scale API service (optional)
docker-compose up -d --scale dotnet-api=3
```

## Local Development (Without Docker)

```bash
# Restore dependencies
dotnet restore

# Run the application
dotnet run

# Run with watch (auto-reload)
dotnet watch run

# Run tests (if you add them)
dotnet test
```

## Docker Image Details

### Base Images
- **Build Stage**: `mcr.microsoft.com/dotnet/sdk:8.0-alpine`
- **Runtime Stage**: `mcr.microsoft.com/dotnet/aspnet:8.0-alpine`

### Image Size
- Approximate size: ~110-130 MB (Alpine-based)
- Compare to: ~220 MB (Debian-based)

### Security Features
- ✅ Non-root user (appuser:1000)
- ✅ Minimal Alpine Linux base
- ✅ Multi-stage build (no SDK in final image)
- ✅ Health checks enabled
- ✅ Read-only root filesystem compatible

## Datadog Integration

### Automatic Instrumentation (Recommended)

The easiest way to enable Datadog APM is using automatic instrumentation:

1. **Uncomment the Datadog.Trace package** in `DotNetApiSample.csproj`:
```xml
<PackageReference Include="Datadog.Trace" Version="2.49.0" />
```

2. **Rebuild the image**:
```bash
docker-compose up -d --build
```

3. **Verify in Datadog**: Check APM → Services after a few minutes

### Environment Variables

The following Datadog environment variables are configured in `docker-compose.yml`:

| Variable | Value | Description |
|----------|-------|-------------|
| `DD_AGENT_HOST` | `dd-agent` | Datadog agent hostname |
| `DD_TRACE_AGENT_URL` | `unix:///var/run/datadog/apm.socket` | APM socket path |
| `DD_DOGSTATSD_URL` | `unix:///var/run/datadog/dsd.socket` | StatsD socket path |
| `DD_ENV` | `sit` | Environment tag |
| `DD_SERVICE` | `dotnet-api-sample` | Service name |
| `DD_VERSION` | `1.0.0` | Version tag |
| `DD_LOGS_INJECTION` | `true` | Inject trace IDs in logs |
| `DD_TRACE_ENABLED` | `true` | Enable tracing |
| `DD_PROFILING_ENABLED` | `true` | Enable profiling |

### What Gets Monitored

With Datadog integration enabled:
- ✅ **APM Traces**: HTTP requests, database calls, external services
- ✅ **Metrics**: Request rate, latency, error rate
- ✅ **Logs**: Application logs with trace correlation
- ✅ **Profiling**: CPU and memory profiling
- ✅ **Runtime Metrics**: GC stats, thread pool, etc.

## Health Checks

### Docker Health Check

The container includes a built-in health check:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1
```

### Check Container Health

```bash
# View health status
docker ps

# Check health logs
docker inspect dotnet-api-sample | jq '.[0].State.Health'
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs dotnet-api

# Check if port is already in use
lsof -i :5000

# Restart service
docker-compose restart dotnet-api
```

### Datadog Agent Issues

```bash
# Check agent status
docker exec -it dd-agent agent status

# Check APM
docker exec -it dd-agent agent status | grep -A 20 "APM Agent"

# Verify socket exists
docker exec -it dotnet-api-sample ls -la /var/run/datadog/
```

### No Traces in Datadog

1. **Verify Datadog.Trace package is installed**
2. **Check environment variables**:
   ```bash
   docker exec -it dotnet-api-sample env | grep DD_
   ```
3. **Ensure socket is mounted**:
   ```bash
   docker exec -it dotnet-api-sample ls -la /var/run/datadog/
   ```
4. **Check agent can receive traces**:
   ```bash
   docker exec -it dd-agent agent status | grep apm
   ```

### Logs Not Appearing

1. **Verify DD_LOGS_ENABLED=true** in agent
2. **Check container labels**:
   ```bash
   docker inspect dotnet-api-sample | jq '.[0].Config.Labels'
   ```
3. **Check agent log collection**:
   ```bash
   docker exec -it dd-agent agent status | grep -A 20 "Logs Agent"
   ```

## Performance Optimization

### Production Recommendations

1. **Enable ReadyToRun compilation** in `.csproj`:
```xml
<PropertyGroup>
  <PublishReadyToRun>true</PublishReadyToRun>
</PropertyGroup>
```

2. **Use tiered compilation** (enabled by default in .NET 8)

3. **Set memory limits** in docker-compose:
```yaml
deploy:
  resources:
    limits:
      memory: 512M
    reservations:
      memory: 256M
```

4. **Enable response compression** in `Program.cs`

## Monitoring Dashboards

### Key Metrics to Monitor

- **Request Rate**: requests/second
- **Response Time**: P50, P95, P99 latency
- **Error Rate**: 5xx responses
- **CPU Usage**: Container CPU %
- **Memory Usage**: GC heap size, allocations
- **Thread Pool**: Active threads, queue length

### Sample Datadog Queries

```
# Request rate
sum:trace.aspnet_core.request.hits{env:sit,service:dotnet-api-sample}.as_rate()

# Error rate
sum:trace.aspnet_core.request.errors{env:sit,service:dotnet-api-sample}.as_rate()

# Average latency
avg:trace.aspnet_core.request.duration{env:sit,service:dotnet-api-sample}

# GC collections
sum:runtime.dotnet.gc.count{env:sit,service:dotnet-api-sample}.as_count()
```

## Kubernetes Deployment (Optional)

If deploying to Kubernetes, see the Datadog Operator documentation for automatic injection of APM libraries.

## Security Best Practices

- ✅ Use secrets management for API keys (not hardcoded)
- ✅ Run as non-root user
- ✅ Keep base images updated
- ✅ Scan images for vulnerabilities
- ✅ Use minimal Alpine-based images
- ✅ Implement rate limiting
- ✅ Enable HTTPS in production

## Environment Variables Reference

### Application Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ASPNETCORE_ENVIRONMENT` | `Production` | ASP.NET environment |
| `ASPNETCORE_URLS` | `http://+:5000` | Listening URLs |

### Datadog Variables

See `docker-compose.yml` for complete list of Datadog environment variables.

## Additional Resources

- [.NET 8 Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Datadog .NET APM](https://docs.datadoghq.com/tracing/setup_overview/setup/dotnet-core/)
- [Alpine Linux](https://alpinelinux.org/)

## License

This is a sample project for demonstration purposes.

## Support

For issues related to:
- **.NET**: Check Microsoft documentation
- **Docker**: Check Docker documentation
- **Datadog**: Check Datadog support or documentation

## Reference Test Environment

### docker version
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:07:41 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:07:41 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v2.1.5
  GitCommit:        fcd43222d6b07379a4be9786bda52438f0dd16a1
 dd-shim:
  Version:          v0.0.1
  GitCommit:        
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

### ls -al /opt/datadog-packages/
total 68
drwxrwxrwx 11 root docker  4096 Nov 21 07:09 .
drwxr-xr-x  6 root root    4096 Nov 21 07:09 ..
drwxr-xr-x  3 root root    4096 Nov 21 07:08 datadog-apm-inject
drwxr-xr-x  3 root root    4096 Nov 21 07:09 datadog-apm-library-dotnet
drwxr-xr-x  3 root root    4096 Nov 21 07:08 datadog-apm-library-java
drwxr-xr-x  3 root root    4096 Nov 21 07:08 datadog-apm-library-js
drwxr-xr-x  3 root root    4096 Nov 21 07:09 datadog-apm-library-php
drwxr-xr-x  3 root root    4096 Nov 21 07:08 datadog-apm-library-python
drwxr-xr-x  3 root root    4096 Nov 21 07:08 datadog-apm-library-ruby
-rw-r--r--  1 root root   32768 Nov 21 07:09 packages.db
drwxr-xr-x  2 root root    4096 Nov 21 07:09 run
drwxrwxrwx  2 root docker  4096 Nov 21 07:09 tmp

---

**Created**: November 21, 2025  
**Last Updated**: November 21, 2025  
**Version**: 1.0.0


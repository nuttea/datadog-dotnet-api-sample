# Quick Start Guide

## TL;DR - Get Started in 3 Steps

```bash
# 1. Navigate to project directory
cd /Users/nuttee.jirattivongvibul/Projects/nuttee-se-gemini-cli/temp_working/AXONS/dotnet-api-sample

# 2. Start everything
./start.sh

# 3. Test the API
./test.sh
```

## What You Get

- ✅ .NET 8 Web API running on port 5000
- ✅ Datadog Agent for monitoring
- ✅ Swagger UI at http://localhost:5000/swagger
- ✅ Health checks and logging
- ✅ Alpine-based minimal Docker images

## Quick Commands

```bash
# Start services
./start.sh

# Test API endpoints
./test.sh

# View logs
docker-compose logs -f dotnet-api

# Stop everything
./stop.sh
# OR
docker-compose down

# Restart API only
docker-compose restart dotnet-api

# Check container status
docker-compose ps

# Access API directly
curl http://localhost:5000/api/weatherforecast
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/info` | GET | Service info |
| `/api/weatherforecast` | GET | Get 5-day forecast |
| `/api/weatherforecast/{id}` | GET | Get specific day |
| `/api/weatherforecast` | POST | Create forecast |
| `/swagger` | GET | Swagger UI |

## Datadog Setup (Optional)

1. Get your API key from [Datadog](https://app.datadoghq.com/organization-settings/api-keys)

2. Create `.env` file:
```bash
DD_API_KEY=your_actual_api_key_here
DD_SITE=datadoghq.com
```

3. Restart services:
```bash
docker-compose down
./start.sh
```

## Troubleshooting

### Port 5000 already in use
```bash
# Find and kill process
lsof -ti:5000 | xargs kill -9

# Or change port in docker-compose.yml
ports:
  - "5001:5000"  # Change 5001 to any available port
```

### API won't start
```bash
# Check logs
docker-compose logs dotnet-api

# Rebuild
docker-compose up -d --build --force-recreate
```

### Need to reset everything
```bash
docker-compose down -v
docker system prune -f
./start.sh
```

## Project Structure

```
dotnet-api-sample/
├── Controllers/           # API controllers
├── Models/               # Data models
├── Program.cs            # Application entry point
├── Dockerfile            # Multi-stage Docker build
├── docker-compose.yml    # Docker Compose configuration
├── start.sh             # Quick start script
├── test.sh              # API testing script
├── stop.sh              # Stop script
└── README.md            # Full documentation
```

## Next Steps

1. ✅ Start the services: `./start.sh`
2. ✅ Test the API: `./test.sh`
3. ✅ Open Swagger: http://localhost:5000/swagger
4. ✅ Check logs: `docker-compose logs -f`
5. ✅ Customize the API in `Controllers/WeatherForecastController.cs`
6. ✅ Add your Datadog API key to enable monitoring

## Full Documentation

See [README.md](README.md) for complete documentation including:
- Detailed configuration options
- Datadog integration guide
- Production deployment tips
- Security best practices
- Performance optimization
- Kubernetes deployment

---

**Need Help?** Check [README.md](README.md) or view logs with `docker-compose logs -f`


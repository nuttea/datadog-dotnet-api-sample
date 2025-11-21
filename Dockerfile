# Multi-stage Dockerfile for .NET 8 Web API
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY *.csproj ./
RUN dotnet restore --runtime linux-musl-x64

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o /app/publish \
    --no-restore \
    --runtime linux-musl-x64 \
    --self-contained false

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime
WORKDIR /app

# Install curl for health checks (optional but useful)
RUN apk add --no-cache curl

# Create a non-root user
RUN addgroup -g 1000 appuser && \
    adduser -u 1000 -G appuser -s /bin/sh -D appuser && \
    chown -R appuser:appuser /app

# Copy published app from build stage
COPY --from=build /app/publish .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 5000

# Environment variables (can be overridden in docker-compose)
ENV ASPNETCORE_URLS=http://+:5000 \
    ASPNETCORE_ENVIRONMENT=Production \
    DD_SERVICE=dotnet-api-sample \
    DD_ENV=sit \
    DD_VERSION=1.0.0

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Start the application
ENTRYPOINT ["dotnet", "DotNetApiSample.dll"]


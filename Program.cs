using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add health checks
builder.Services.AddHealthChecks();

// Configure Datadog (if using Datadog APM)
var ddAgentHost = Environment.GetEnvironmentVariable("DD_AGENT_HOST") ?? "dd-agent";
var ddEnv = Environment.GetEnvironmentVariable("DD_ENV") ?? "sit";
var ddService = Environment.GetEnvironmentVariable("DD_SERVICE") ?? "dotnet-api-sample";
var ddVersion = Environment.GetEnvironmentVariable("DD_VERSION") ?? "1.0.0";

// Log configuration
Console.WriteLine($"Starting {ddService} v{ddVersion} in {ddEnv} environment");
Console.WriteLine($"Datadog Agent Host: {ddAgentHost}");

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || true) // Always enable Swagger for demo
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Add custom middleware for request logging
app.Use(async (context, next) =>
{
    var stopwatch = Stopwatch.StartNew();
    await next();
    stopwatch.Stop();
    
    Console.WriteLine($"[{DateTime.UtcNow:yyyy-MM-dd HH:mm:ss}] {context.Request.Method} {context.Request.Path} - {context.Response.StatusCode} - {stopwatch.ElapsedMilliseconds}ms");
});

app.UseHttpsRedirection();
app.UseAuthorization();

// Health check endpoint
app.MapHealthChecks("/health");

// Info endpoint
app.MapGet("/info", () => new
{
    service = ddService,
    version = ddVersion,
    environment = ddEnv,
    timestamp = DateTime.UtcNow,
    hostname = Environment.MachineName
});

app.MapControllers();

app.Run();


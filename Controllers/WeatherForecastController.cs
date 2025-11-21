using Microsoft.AspNetCore.Mvc;

namespace DotNetApiSample.Controllers;

[ApiController]
[Route("api/[controller]")]
public class WeatherForecastController : ControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

    [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        _logger.LogInformation("Getting weather forecast");
        
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

    [HttpGet("{id}")]
    public ActionResult<WeatherForecast> GetById(int id)
    {
        _logger.LogInformation("Getting weather forecast for day {DayId}", id);
        
        if (id < 1 || id > 365)
        {
            _logger.LogWarning("Invalid day ID: {DayId}", id);
            return BadRequest(new { error = "Day ID must be between 1 and 365" });
        }

        var forecast = new WeatherForecast
        {
            Date = DateOnly.FromDateTime(DateTime.Now.AddDays(id)),
            TemperatureC = Random.Shared.Next(-20, 55),
            Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        };

        return Ok(forecast);
    }

    [HttpPost]
    public ActionResult<WeatherForecast> Create([FromBody] WeatherForecast forecast)
    {
        _logger.LogInformation("Creating new weather forecast for {Date}", forecast.Date);
        
        if (forecast.Date < DateOnly.FromDateTime(DateTime.Now))
        {
            _logger.LogWarning("Cannot create forecast for past date: {Date}", forecast.Date);
            return BadRequest(new { error = "Cannot create forecast for past dates" });
        }

        return CreatedAtAction(nameof(GetById), new { id = 1 }, forecast);
    }
}


using Microsoft.AspNetCore.Mvc;

namespace demo_jit_api.Controllers;

[ApiController]
[Route("/api/jit")]
public class DemoController : ControllerBase
{
    [HttpGet]
    public IEnumerable<Todo> Get() => new Todo[]
    {
        new(1, "Walk the dog", DateOnly.FromDateTime(DateTime.Now)),
        new(2, "Do the dishes", DateOnly.FromDateTime(DateTime.Now)),
        new(3, "Do the laundry", DateOnly.FromDateTime(DateTime.Now.AddDays(1))),
        new(4, "Clean the bathroom", DateOnly.FromDateTime(DateTime.Now.AddDays(1))),
        new(5, "Clean the car", DateOnly.FromDateTime(DateTime.Now.AddDays(2)))
    };
}

public record Todo(int Id, string? Title, DateOnly? DueBy = null, bool IsComplete = false);
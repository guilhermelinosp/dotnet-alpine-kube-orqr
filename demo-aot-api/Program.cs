using System.Text.Json.Serialization;

var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.TypeInfoResolverChain.Insert(0, AppJsonSerializerContext.Default);
});

var app = builder.Build();

app.MapGet("/api/aot/demo", () => new Todo[]
{
    new(1, "Walk the dog", DateOnly.FromDateTime(DateTime.Now)),
    new(2, "Do the dishes", DateOnly.FromDateTime(DateTime.Now)),
    new(3, "Do the laundry", DateOnly.FromDateTime(DateTime.Now.AddDays(1))),
    new(4, "Clean the bathroom", DateOnly.FromDateTime(DateTime.Now.AddDays(1))),
    new(5, "Clean the car", DateOnly.FromDateTime(DateTime.Now.AddDays(2)))
});

app.MapGet("/health", () => "Healthy");

await app.RunAsync();

public record Todo(int Id, string? Title, DateOnly? DueBy = null, bool IsComplete = false);

[JsonSerializable(typeof(Todo[]))]
internal partial class AppJsonSerializerContext : JsonSerializerContext;
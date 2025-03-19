var builder = WebApplication.CreateSlimBuilder(args);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

var app = builder.Build();

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.MapGet("/health", () => "Healthy");

await app.RunAsync();
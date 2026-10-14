using TaskManagerApi.Repositories;

var builder = WebApplication.CreateBuilder(args); 

// 1. Enable CORS for Web/Chrome requests from any origin
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Add controller and repository services
builder.Services.AddControllers();
builder.Services.AddSingleton<ITaskRepository, InMemoryTaskRepository>();

// Add Swagger services 
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build(); 

// Configure HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(); 
    app.UseSwaggerUI();
} 

// 2. Enable CORS policy
app.UseCors("AllowAll");

app.UseAuthorization(); 

app.MapControllers(); 

app.Run();

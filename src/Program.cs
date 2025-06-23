using Microsoft.EntityFrameworkCore;
using myWebApp.Data;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorPages();

// Add Entity Framework with cascading connection string configuration
var connectionString = GetConnectionString(builder.Configuration);
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(connectionString));

var app = builder.Build();

// Helper method for cascading connection string configuration
static string GetConnectionString(IConfiguration configuration)
{
    // 1. First priority: Environment variable CS_MSSQL_CONN
    var envConnectionString = Environment.GetEnvironmentVariable("CS_MSSQL_CONN");
    if (!string.IsNullOrWhiteSpace(envConnectionString))
    {
        Console.WriteLine("Using connection string from environment variable CS_MSSQL_CONN");
        return envConnectionString;
    }

    // 2. Second priority: Configuration (User Secrets in dev, appsettings in prod)
    var configConnectionString = configuration.GetConnectionString("DefaultConnection");
    if (!string.IsNullOrWhiteSpace(configConnectionString))
    {
        // Check if it's coming from User Secrets or config files
        var isFromSecrets = !configConnectionString.Contains("localhost") && 
                           !configConnectionString.Contains("LocalTestDB");
        
        if (isFromSecrets)
        {
            Console.WriteLine("Using connection string from User Secrets");
        }
        else
        {
            Console.WriteLine("Using connection string from configuration files");
        }
        return configConnectionString;
    }

    // 3. Final fallback: Default local connection
    var defaultConnectionString = "Server=localhost;Database=LocalTestDB;Integrated Security=true;TrustServerCertificate=true";
    Console.WriteLine("Using default fallback connection string");
    return defaultConnectionString;
}

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
}
else
{
    app.UseDeveloperExceptionPage();
}

app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();

// Make the implicit Program class public so it can be referenced by tests
public partial class Program { }

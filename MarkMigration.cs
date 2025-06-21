using Microsoft.Data.SqlClient;

var connectionString = "Server=ironforge.home.criders.org;Database=WebAppDB;User Id=sa;Password=!!2pacSecure!!;TrustServerCertificate=true;";

using var connection = new SqlConnection(connectionString);
connection.Open();

var command = new SqlCommand("INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion]) VALUES ('20250621165648_InitialCreate', '8.0.0')", connection);
try 
{
    var result = command.ExecuteNonQuery();
    Console.WriteLine($"Migration marked as applied. Rows affected: {result}");
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}

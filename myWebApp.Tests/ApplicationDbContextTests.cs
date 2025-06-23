using Microsoft.EntityFrameworkCore;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Tests;

public class ApplicationDbContextTests : IDisposable
{
    private readonly ApplicationDbContext _context;

    public ApplicationDbContextTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
    }

    [Fact]
    public async Task AddThing_ShouldSaveToDatabase()
    {
        // Arrange
        var thing = new Thing
        {
            Name = "Test Item",
            Purpose = "Testing database operations",
            CreatedOn = DateTime.Now,
            LastModified = DateTime.Now
        };

        // Act
        _context.Things.Add(thing);
        await _context.SaveChangesAsync();

        // Assert
        var savedThing = await _context.Things.FirstOrDefaultAsync();
        Assert.NotNull(savedThing);
        Assert.Equal("Test Item", savedThing.Name);
        Assert.Equal("Testing database operations", savedThing.Purpose);
    }

    [Fact]
    public async Task GetThings_ShouldReturnAllThings()
    {
        // Arrange
        var things = new List<Thing>
        {
            new Thing { Name = "Thing 1", Purpose = "Purpose 1" },
            new Thing { Name = "Thing 2", Purpose = "Purpose 2" },
            new Thing { Name = "Thing 3", Purpose = "Purpose 3" }
        };

        _context.Things.AddRange(things);
        await _context.SaveChangesAsync();

        // Act
        var retrievedThings = await _context.Things.ToListAsync();

        // Assert
        Assert.Equal(3, retrievedThings.Count);
        Assert.Contains(retrievedThings, t => t.Name == "Thing 1");
        Assert.Contains(retrievedThings, t => t.Name == "Thing 2");
        Assert.Contains(retrievedThings, t => t.Name == "Thing 3");
    }

    [Fact]
    public async Task UpdateThing_ShouldModifyExistingRecord()
    {
        // Arrange
        var thing = new Thing
        {
            Name = "Original Name",
            Purpose = "Original Purpose"
        };

        _context.Things.Add(thing);
        await _context.SaveChangesAsync();

        // Act
        thing.Name = "Updated Name";
        thing.Purpose = "Updated Purpose";
        thing.LastModified = DateTime.Now;
        await _context.SaveChangesAsync();

        // Assert
        var updatedThing = await _context.Things.FindAsync(thing.Id);
        Assert.NotNull(updatedThing);
        Assert.Equal("Updated Name", updatedThing.Name);
        Assert.Equal("Updated Purpose", updatedThing.Purpose);
    }

    [Fact]
    public async Task DeleteThing_ShouldRemoveFromDatabase()
    {
        // Arrange
        var thing = new Thing
        {
            Name = "To Be Deleted",
            Purpose = "Will be removed"
        };

        _context.Things.Add(thing);
        await _context.SaveChangesAsync();
        var thingId = thing.Id;

        // Act
        _context.Things.Remove(thing);
        await _context.SaveChangesAsync();

        // Assert
        var deletedThing = await _context.Things.FindAsync(thingId);
        Assert.Null(deletedThing);
    }

    public void Dispose()
    {
        _context.Dispose();
    }
}

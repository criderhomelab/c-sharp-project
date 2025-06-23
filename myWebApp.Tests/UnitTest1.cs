using Microsoft.EntityFrameworkCore;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Tests;

public class ThingModelTests
{
    [Fact]
    public void Thing_ShouldCreateWithDefaultValues()
    {
        // Arrange & Act
        var thing = new Thing();

        // Assert
        Assert.Equal(0, thing.Id);
        Assert.Equal(string.Empty, thing.Name);
        Assert.Equal(string.Empty, thing.Purpose);
        Assert.True(thing.CreatedOn <= DateTime.Now);
        Assert.True(thing.LastModified <= DateTime.Now);
    }

    [Fact]
    public void Thing_ShouldSetPropertiesCorrectly()
    {
        // Arrange
        var expectedName = "Test Thing";
        var expectedPurpose = "Testing purposes only";
        var expectedDate = new DateTime(2024, 1, 1);

        // Act
        var thing = new Thing
        {
            Id = 1,
            Name = expectedName,
            Purpose = expectedPurpose,
            CreatedOn = expectedDate,
            LastModified = expectedDate
        };

        // Assert
        Assert.Equal(1, thing.Id);
        Assert.Equal(expectedName, thing.Name);
        Assert.Equal(expectedPurpose, thing.Purpose);
        Assert.Equal(expectedDate, thing.CreatedOn);
        Assert.Equal(expectedDate, thing.LastModified);
    }

    [Theory]
    [InlineData("")]
    [InlineData("A")]
    [InlineData("This is exactly fifty characters long name test")]
    public void Thing_NameProperty_ShouldAcceptValidLengths(string name)
    {
        // Arrange & Act
        var thing = new Thing { Name = name };

        // Assert
        Assert.Equal(name, thing.Name);
    }

    [Theory]
    [InlineData("")]
    [InlineData("Short purpose")]
    [InlineData("This is a very long purpose that should still be valid as long as it's under the 255 character limit which is quite generous for most typical use cases and should accommodate detailed descriptions of the thing's intended purpose")]
    public void Thing_PurposeProperty_ShouldAcceptValidLengths(string purpose)
    {
        // Arrange & Act
        var thing = new Thing { Purpose = purpose };

        // Assert
        Assert.Equal(purpose, thing.Purpose);
    }
}
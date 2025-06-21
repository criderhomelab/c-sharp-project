using Microsoft.EntityFrameworkCore;
using myWebApp.Models;

namespace myWebApp.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
            : base(options)
        {
        }

        public DbSet<Thing> Things { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Thing>(entity =>
            {
                entity.ToTable("things");
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Id).HasColumnName("id").ValueGeneratedOnAdd();
                entity.Property(e => e.Name).HasColumnName("name").IsRequired().HasMaxLength(50);
                entity.Property(e => e.Purpose).HasColumnName("purpose").IsRequired().HasMaxLength(255);
                entity.Property(e => e.CreatedOn).HasColumnName("created_on").HasDefaultValueSql("GETDATE()");
                entity.Property(e => e.LastModified).HasColumnName("last_modified").HasColumnType("datetime");
            });
        }
    }
}

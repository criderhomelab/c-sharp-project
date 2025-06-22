using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Pages.Things
{
    public class IndexModel : PageModel
    {
        private readonly ApplicationDbContext _context;

        public IndexModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public IList<Thing> Things { get; set; } = default!;
        
        [BindProperty(SupportsGet = true)]
        public string SortField { get; set; } = "CreatedOn";
        
        [BindProperty(SupportsGet = true)]
        public string SortDirection { get; set; } = "desc";

        public async Task OnGetAsync()
        {
            var query = _context.Things.AsQueryable();

            // Apply sorting based on parameters
            query = SortField?.ToLower() switch
            {
                "name" => SortDirection == "desc" 
                    ? query.OrderByDescending(t => t.Name)
                    : query.OrderBy(t => t.Name),
                "purpose" => SortDirection == "desc"
                    ? query.OrderByDescending(t => t.Purpose)
                    : query.OrderBy(t => t.Purpose),
                "createdon" => SortDirection == "desc"
                    ? query.OrderByDescending(t => t.CreatedOn)
                    : query.OrderBy(t => t.CreatedOn),
                "lastmodified" => SortDirection == "desc"
                    ? query.OrderByDescending(t => t.LastModified)
                    : query.OrderBy(t => t.LastModified),
                _ => query.OrderByDescending(t => t.CreatedOn) // Default sort
            };

            Things = await query.ToListAsync();
        }

        public string GetSortDirection(string field)
        {
            if (SortField?.ToLower() == field.ToLower())
            {
                return SortDirection == "asc" ? "desc" : "asc";
            }
            return "asc";
        }

        public string GetSortIcon(string field)
        {
            if (SortField?.ToLower() != field.ToLower())
                return "fas fa-sort";
            
            return SortDirection == "asc" ? "fas fa-sort-up" : "fas fa-sort-down";
        }
    }
}

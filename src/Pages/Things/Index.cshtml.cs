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

        public async Task OnGetAsync()
        {
            Things = await _context.Things
                .OrderByDescending(t => t.CreatedOn)
                .ToListAsync();
        }
    }
}

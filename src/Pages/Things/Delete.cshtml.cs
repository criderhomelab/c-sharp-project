using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Pages.Things
{
    public class DeleteModel : PageModel
    {
        private readonly ApplicationDbContext _context;

        public DeleteModel(ApplicationDbContext context)
        {
            _context = context;
        }

        [BindProperty]
        public Thing Thing { get; set; } = default!;

        public async Task<IActionResult> OnGetAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var thing = await _context.Things.FirstOrDefaultAsync(m => m.Id == id);

            if (thing == null)
            {
                return NotFound();
            }
            
            Thing = thing;
            return Page();
        }

        public async Task<IActionResult> OnPostAsync(int? id)
        {
            if (id == null)
            {
                return NotFound();
            }

            var thing = await _context.Things.FindAsync(id);
            if (thing != null)
            {
                Thing = thing;
                _context.Things.Remove(Thing);
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Thing deleted successfully!";
            }

            return RedirectToPage("./Index");
        }
    }
}

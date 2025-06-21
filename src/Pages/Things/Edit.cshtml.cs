using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Pages.Things
{
    public class EditModel : PageModel
    {
        private readonly ApplicationDbContext _context;

        public EditModel(ApplicationDbContext context)
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

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            // Find the existing entity in the database
            var existingThing = await _context.Things.FindAsync(Thing.Id);
            if (existingThing == null)
            {
                return NotFound();
            }

            // Update only the fields that should be modified
            existingThing.Name = Thing.Name;
            existingThing.Purpose = Thing.Purpose;
            existingThing.LastModified = DateTime.Now;

            try
            {
                await _context.SaveChangesAsync();
                TempData["SuccessMessage"] = "Thing updated successfully!";
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!ThingExists(Thing.Id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return RedirectToPage("./Index");
        }

        private bool ThingExists(int id)
        {
            return _context.Things.Any(e => e.Id == id);
        }
    }
}

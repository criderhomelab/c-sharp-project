using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using myWebApp.Data;
using myWebApp.Models;

namespace myWebApp.Pages.Things
{
    public class CreateModel : PageModel
    {
        private readonly ApplicationDbContext _context;

        public CreateModel(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult OnGet()
        {
            return Page();
        }

        [BindProperty]
        public Thing Thing { get; set; } = default!;

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            Thing.CreatedOn = DateTime.Now;
            Thing.LastModified = DateTime.Now;
            _context.Things.Add(Thing);
            await _context.SaveChangesAsync();

            TempData["SuccessMessage"] = "Thing created successfully!";
            return RedirectToPage("./Index");
        }
    }
}

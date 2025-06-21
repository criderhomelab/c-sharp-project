using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace myWebApp.Models
{
    [Table("things")]
    public class Thing
    {
        [Column("id")]
        public int Id { get; set; }

        [Required]
        [Display(Name = "Name")]
        [StringLength(50)]
        [Column("name")]
        public string Name { get; set; } = string.Empty;

        [Required]
        [Display(Name = "Purpose")]
        [StringLength(255)]
        [Column("purpose")]
        public string Purpose { get; set; } = string.Empty;

        [Display(Name = "Created On")]
        [DataType(DataType.DateTime)]
        [Column("created_on")]
        public DateTime CreatedOn { get; set; } = DateTime.Now;

        [Display(Name = "Last Modified")]
        [DataType(DataType.DateTime)]
        [Column("last_modified")]
        public DateTime LastModified { get; set; } = DateTime.Now;
    }
}

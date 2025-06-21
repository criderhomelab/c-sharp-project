# Security Guidelines

## File Permissions Audit

This document records the security audit and file permission standards for this repository.

### Permission Standards

#### Executable Files (755)
- Scripts in `bin/` directory
- Binary executables

#### Source Code and Configuration Files (644)
- Source code files (`.cs`, `.cshtml`, `.js`, `.css`)
- Configuration files (`.json`, `.yaml`, `.config`)
- Documentation files (`.md`, `.txt`)
- License files

#### Secret Files (600)
- `.secret` file (database credentials)
- Any file containing sensitive information

#### Directories (755)
- All directories need to be accessible but not world-writable

### Audit History

#### 2024 Security Audit
- Audited all file permissions across the repository
- Fixed permissions for scripts in `bin/` to be executable (755)
- Set restrictive permissions on source, config, and documentation files (644)
- Set owner-only read permissions on secret file (600)
- Ensured all directories have appropriate access permissions (755)
- Fixed executable bit on `/src/wwwroot/lib/jquery-validation/LICENSE.md`

### Verification Commands

To verify current permissions are correct:

```bash
# Check that only scripts in bin/ are executable
find . -type f -executable -not -path './.git/*' -not -path './src/bin/*' -not -path './src/obj/*'

# Verify secret file permissions
ls -la .secret

# Check bin directory permissions
ls -la bin/
```

### Best Practices

1. **Never commit executable permissions** on source code files
2. **Always set restrictive permissions** on configuration files
3. **Use 600 permissions** for any file containing credentials or secrets
4. **Regularly audit** file permissions during security reviews
5. **Document any permission changes** in this file

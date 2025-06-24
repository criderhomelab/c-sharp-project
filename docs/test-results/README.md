# Test Results Archive

This directory contains archived test execution results and coverage reports for the ASP.NET Core web application.

## Files Included

### Test Execution Results
- **`TestResults.trx`** - Detailed test execution report in Microsoft Test Results XML format
  - Contains pass/fail status for all 17 tests
  - Execution timing and performance metrics
  - Test categorization and hierarchy

### Code Coverage Reports
- **`coverage.cobertura.xml`** - Code coverage data in Cobertura XML format
  - Line-by-line coverage analysis
  - Branch coverage metrics
  - Detailed per-file coverage breakdown
  - Compatible with most CI/CD coverage reporting tools

## How to View Results

### Test Results (TRX File)
- **Visual Studio**: File → Open → TestResults.trx
- **Command Line**: `vstest.console.exe TestResults.trx /logger:console`
- **CI/CD Tools**: Most platforms (Azure DevOps, GitHub Actions, etc.) support TRX natively

### Coverage Reports (Cobertura XML)
- **ReportGenerator**: `reportgenerator -reports:coverage.cobertura.xml -targetdir:coverage-html`
- **SonarQube**: Direct import support
- **Codecov/Coveralls**: Upload directly for web visualization
- **IDE Plugins**: Most IDEs have Cobertura coverage visualization plugins

## Result Summary
- **Total Tests**: 17
- **Pass Rate**: 100%
- **Execution Time**: 5.9463 seconds
- **Line Coverage**: 23.14% (100/432 lines)
- **Branch Coverage**: 25.51% (50/196 branches)

## Generation Commands
These results were generated using:
```bash
make test                    # Run all tests with coverage
dotnet test --collect:"XPlat Code Coverage"  # Coverage collection
```

*Results archived on June 24, 2025*

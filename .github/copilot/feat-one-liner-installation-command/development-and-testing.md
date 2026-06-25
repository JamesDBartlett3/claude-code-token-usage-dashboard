# Development and Testing Results

## Feature
Implemented release-based network-install bootstrap scripts for Windows PowerShell and Bash, plus a GitHub Actions release packaging workflow, so the project can be installed from a single zip asset published on GitHub Releases while still delegating the real work to the existing `drachometer-install.py` installer.

## Changes Made
- Added `.github/workflows/release-package.yml`:
  - Builds `drachometer.zip` when a GitHub release is published.
  - Uploads that zip to the release so installers can fetch one deterministic asset.
- Added `drachometer-install.ps1`:
  - Resolves the latest release from the GitHub Releases API.
  - Downloads the packaged zip asset to a temporary directory.
  - Extracts it and runs `drachometer-install.py`.
  - Supports the requested `irm <URL> | iex` installation style.
- Added `drachometer-install.sh`:
  - Resolves the latest release from the GitHub Releases API.
  - Downloads the packaged zip asset to a temporary directory.
  - Extracts it and runs `drachometer-install.py`.
  - Supports the requested `curl ... | bash` installation style for Mac, Linux, and WSL2.
- Updated `README.md`:
  - Documented both one-line install commands and the release-asset behavior.
  - Kept the existing Windows zip-based install flow.
  - Added the new bootstrap scripts and release workflow to the file list.

## Validation Performed
### Baseline (before changes)
- Ran the existing installer validation flow in an isolated temporary `HOME`:
  - `HOME=$(mktemp -d) python3 drachometer-install.py`
  - Result: PASS

### Targeted verification (after changes)
1. Bash bootstrap syntax check:
   - `bash -n drachometer-install.sh`
   - Result: PASS
2. Bash bootstrap end-to-end install using a mocked latest-release JSON response:
   - `HOME=<tmp> DRACHOMETER_RELEASES_API=<release.json> ./drachometer-install.sh`
   - Result: PASS
3. PowerShell bootstrap syntax parse:
   - `pwsh -NoLogo -NoProfile -Command '[System.Management.Automation.Language.Parser]::ParseFile(...)'`
   - Result: PASS
4. PowerShell bootstrap end-to-end install using a mocked latest-release JSON response:
   - `HOME=<tmp> DRACHOMETER_RELEASES_API=<release.json> pwsh -NoLogo -NoProfile -File ./drachometer-install.ps1`
   - Result: PASS
5. Release package build simulation:
  - `zip -r <tmp>/drachometer.zip README.md coin.svg hooks drachometer-install.bat drachometer-install.ps1 drachometer-install.py drachometer-install.sh migrations drachometer-dashboard.html drachometer-serve-report.py drachometer-version.json`
   - Result: PASS

### Security/quality checks
- Secret scan on changed files: PASS
- CodeQL check: no analyzable code changes detected for supported CodeQL languages
- GitHub Actions dependency advisory check:
  - `actions/checkout@v6.0.3`: no known advisories
  - `softprops/action-gh-release@v3.0.0`: no known advisories

## Notes
- The new scripts intentionally keep `drachometer-install.py` as the single source of truth for copying files, merging Claude hook settings, initializing the database, and running the smoke test.
- Both bootstraps support environment overrides for the release metadata endpoint and asset download location so the release-install path can be validated without a real published release.

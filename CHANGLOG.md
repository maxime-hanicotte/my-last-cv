# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.0.7] - 2025-09-09
### Added
- Support prawn-icon for contact data

## [0.0.6] - 2025-08-14
### Changed
- Enhance parser and renderer to support structured elements and paragraphs.
- Clean Gemfile
- Refactor and update gemspec file
- Add this change log to the project

---

## [0.0.5] - 2025-08-14
### Added
- Support for `###` elements inside sections.
- Safe Rake release tasks with preflight checks.

### Changed
- Cleaned up gemspec (runtime vs development dependencies).

---

## [0.0.4] - 2025-08-13
### Fixed
- Avoid crash when fonts directory is missing.

---

## [0.0.3] - 2025-08-13
### Changed
- Improved font directory resolution (`./fonts`, ENV override, gem fallback).

### Fixed
- Ensure `output/` directory is created when generating a PDF.

---

## [0.0.2] - 2025-08-13
### Added
- Custom fonts support (`./fonts`, ENV, or explicit `fonts_dir`).
- Accent color option in `Style`.
- RSpec tests setup.

### Changed
- Moved gem version management into `lib/my_last_cv/version.rb`.

---

## [0.0.1] - 2025-08-13
### Added
- Initial release.
- Parse Markdown `#` (header), `##` (sections), and list items.
- Generate styled PDF with Prawn.
- Basic styling options (fonts, sizes, margins).

# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
There is nothing here yet.

## [0.3.1] -- 2022-08-22
### Added
- Arithmetic expressions in a NumberEdit are done with floating point precision, then the result
  is rounded to the nearest integer. This allows for expressions such as `1 / 5 * 50` to be done.
  
### Changed
- The NumberEdit in "Add Entry" is now cleared after adding entry to the intake.

### Fixed
- Recalculate the total sum of an intake when editing an item.
- Fixed NumberEdit validating twice when the user presses Enter.

## [0.3] -- 2022-08-18
### Added
- The "Add Food Source" section has been moved into its own dialog window.
- Add a text bar specialized for numbers. It allows basic arithmetic operations (+-*/).

### Changed
- Some code refactors to make previously unique nodes nonunique.
- Updates to the error label.
- The newly added numerical text bar replaces the one previously used to edit the "Amount" column
  in intakes.
- Changed the "Edit Entry" label in each intake to say "Add Entry".

### Fixed
- The close-intake dialog used to not work because of a signal-connection error. Now that's been fixed.

## [0.2] -- 2022-07-05
### Added
- Implemented editable intake entries.
- Clears intake entries on the next day.

### Fixed
- Fixed an issue where the first intake entry added after a clear does not display.

## [0.1] -- 2022-06-30
### Added
- Initial project files.

[Unreleased]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.3...v0.3.1
[0.3]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.2...v0.3
[0.2]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.1...v0.2
[0.1]: https://github.com/JohnDevlopment/intake-monitor/compare/7d095bb...v0.1

<!-- https://github.com/JohnDevlopment/intake-monitor/compare/REV -->

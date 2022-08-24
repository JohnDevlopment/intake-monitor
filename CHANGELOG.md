# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased
There is nothing here yet.

## [1.0 alpha] -- 2022-08-24
### Added
- Floating point precision math in NumberEdit supported.
    - Allows for expressions like `1 / 5 * 30` to be evaluated.
- The file is saved after closing an intake monitor.
  
### Changed
- The NumberEdit in "Add Entry" is now cleared after adding entry to the intake.
- Changes to intake monitors[&ast;](#footnote-1)
    - Updates total when an intake is edited.
    - Refactored code.

### Fixed
- Fixed NumberEdit validating twice when the user presses Enter.

## [0.3] -- 2022-08-18
### Added
- Information tab[&ast;](#footnote-1): Move "Add Food Source" to a dialog window.
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

- - -

<a id="footnote-1"></a>
<small>\* See [<i>Definitions</i>](README.md#definitions) in README.md</small>

[Unreleased]: https://github.com/JohnDevlopment/intake-monitor/compare/v1.0-alpha1...HEAD
[1.0 alpha]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.3...v1.0-alpha1
[0.3]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.2...v0.3
[0.2]: https://github.com/JohnDevlopment/intake-monitor/compare/v0.1...v0.2
[0.1]: https://github.com/JohnDevlopment/intake-monitor/compare/7d095bb...v0.1

<!-- https://github.com/JohnDevlopment/intake-monitor/compare/REV -->

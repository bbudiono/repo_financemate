# CODE_QUALITY.md



## Code Quality Standards for FinanceMate

- Follow SwiftLint rules (add SwiftLint.yml to project root)
- Use 2-space indentation
- Use camelCase for variables, PascalCase for types
- Document all public types and functions with ///
- No force unwraps (!), use guard/if-let
- Use protocols for abstraction and testability
- Keep functions <40 lines, files <400 lines
- Use MARK: for code organization
- Follow MVVM and service patterns (see ARCHITECTURE_GUIDE.md)
- Write unit/UI tests for all features
- Fix all linter and build warnings before commit
- Use `./scripts/fix-swiftlint.sh` to auto-fix common style issues before committing.
- The pre-commit hook (`./scripts/pre-commit-hook.sh`) and CI/CD pipeline (`_macOS/scripts/ci_validate_project.sh`) enforce code style and build/test gates automatically.
- All code must pass SwiftLint and build/test gates before merging.
- For troubleshooting build or lint failures, consult `docs/BUILD_FAILURES.MD` for known issues and solutions. 
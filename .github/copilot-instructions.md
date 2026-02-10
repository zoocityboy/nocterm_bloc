# Project Guidelines for AI agents

## Code style
- This is a pure Dart package (see `pubspec.yaml`, SDK >= 3.10). Follow Dart formatting and analysis:
  - `dart format .`
  - `dart analyze`
  - Lints are configured in `analysis_options.yaml` (includes `package:bloc_lint/recommended.yaml`).

## Architecture
- Purpose: terminal/TUI-friendly Bloc & Cubit helpers. Core API is exported from `lib/nocterm_bloc.dart`.
- Source layout: public surface in `lib/`, implementation in `lib/src/` (see files like `bloc_provider.dart`, `bloc_builder.dart`, `provider/` subfolder).
- Keep public API small and stable; prefer adding helpers in `lib/src/` and re-exporting through `nocterm_bloc.dart`.

## Build & test (commands agents will run)
- Install dependencies: `dart pub get`
- Static analysis: `dart analyze`
- Format check / apply: `dart format .` (or `dart format --output=none --set-exit-if-changed .` in CI to fail on unformatted files)
- Run tests: `dart test`

## Project conventions and examples
- Use `bloc` package patterns (already a dependency) and preserve the semantics of Bloc/Cubit. See `README.md` for motivation and examples.
- Exports: change public exports only when accompanied by a pubspec version bump and changelog entry.
- Tests live in `test/` and should exercise the public API. Use the `test` package (see `dev_dependencies` in `pubspec.yaml`).
- Keep dependencies minimal; prefer using existing helpers in `lib/src/provider/` for provider-like abstractions.

## Integration points
- External packages: `bloc`, `nocterm`, `collection`, `meta`. Review `pubspec.yaml` before changing dependencies.
- CI should run: `dart pub get && dart analyze && dart test` on Dart >=3.10.

## Security and secrets
- This repository does not contain secrets; do not add credentials or tokens to the code. Use environment variables for CI and publishing credentials.

## PR guidance for agents
- Run formatting and static analysis before opening a PR.
- Provide concise changelog entries for public API changes and version bumps in `pubspec.yaml`.
- Prefer small, well-tested commits. Add or update tests for behavioral changes.

---
If any section above is unclear or you want the agent to enforce additional checks (pre-commit hooks, CI workflow updates, or API stability rules), tell me what to add or change.

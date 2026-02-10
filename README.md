<p align="center">
<img src="https://raw.githubusercontent.com/zoocityboy/nocterm_bloc/refs/heads/main/assets/nocterm_bloc.png" height="100" alt="Bloc">
</p>


[![Pub](https://img.shields.io/pub/v/nocterm_bloc.svg)](https://pub.dev/packages/nocterm_bloc)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)


<h3 align="center">Terminal-friendly Bloc & Cubit helpers</h3>


This package adapts the ideas and APIs popularized by Felix Angelov's `bloc` project for terminal (TUI) environments used by <a href="https://nocterm.dev">nocterm.dev</a> and related CLI apps.

Key points:

- Built on the design and inspiration from Felix Angelov (felangel) — full credit to the upstream `bloc` project for architecture, patterns, and documentation.
- Focused on terminal UIs: no Flutter widgets, minimal runtime overhead, and helpers that integrate cleanly with terminal render loops.
- Preserves familiar `Bloc`/`Cubit` semantics so Flutter developers can carry patterns to CLI/TUI projects.


## Overview

`nocterm_bloc` provides lightweight integrations for using `Bloc` and `Cubit` state-management patterns in terminal applications. It aims to:

- Keep business logic decoupled from terminal presentation.
- Provide small adapters for render loops and event handling common in TUI programs.
- Offer familiar, testable APIs that are approachable for developers coming from Flutter.

## What’s different from felangel/bloc

- Target platform: this package is terminal-first; Flutter widgets and BuildContext-based widgets are intentionally omitted.
- API surface: core `Bloc`/`Cubit` semantics are preserved, but provider and builder helpers are adapted for synchronous or cooperative terminal rendering.
- Examples & docs: focused on CLI workflows, not mobile/desktop UI patterns.

## Quick example (counter cubit)

```dart
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

// In a TUI application, hook the cubit into your render loop and
// trigger redraws when state changes.
```

## Contributing & Credits

This project builds on Felix Angelov's seminal `bloc` work — please see the upstream repository for in-depth architecture notes, advanced examples, and historical context:

- https://github.com/felangel/bloc

If you contribute, please follow the repository's contributing guidelines and retain attribution to upstream authors where applicable. The project is MIT-licensed.

---

### Maintainers

- Rabbit Project contributors — adapted for nocterm.dev

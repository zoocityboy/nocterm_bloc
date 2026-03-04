import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:nocterm/nocterm.dart';

import 'provider/src/provider.dart';

/// Shared lifecycle helpers for [State] classes that manage a bloc reference.
///
/// Apply this mixin to any [State] that holds a reference to a
/// [StateStreamable] and needs to resolve it from [BlocProvider] when not
/// provided directly. Implementing classes must:
///
/// * Provide [widgetBloc] – returns the bloc passed directly to the component,
///   or `null` to fall back to the nearest [BlocProvider].
/// * Initialise [resolvedBloc] in [State.initState].
/// * Call [resolveBlocOnUpdate] from [State.didUpdateComponent].
/// * Call [resolveBlocOnDependencyChange] from [State.didChangeDependencies].
/// * Call [applyBlocSelectGuard] at the start of the build method.
///
/// Override [onBlocChanged] to perform additional work (e.g. updating derived
/// local state) whenever [resolvedBloc] is replaced.
mixin BlocStateMixin<B extends StateStreamable<S>, S> on State {
  /// The currently resolved bloc instance.
  ///
  /// Must be initialised in the mixing class's [State.initState] before any
  /// other lifecycle methods reference it.
  late B resolvedBloc;

  /// Returns the bloc supplied directly to the component, or `null` to
  /// fall back to the nearest [BlocProvider] in the widget tree.
  @protected
  B? get widgetBloc;

  /// Called after [resolvedBloc] is updated to a new bloc instance.
  ///
  /// Override to perform additional work such as updating derived state.
  @protected
  void onBlocChanged(B newBloc) {}

  /// Resolves and updates [resolvedBloc] when the component is rebuilt with
  /// a potentially different configuration.
  ///
  /// Pass [oldWidgetBloc] from the previous component. When the resolved
  /// bloc changes, [resolvedBloc] is updated and [onBlocChanged] is called.
  @protected
  void resolveBlocOnUpdate(B? oldWidgetBloc) {
    final oldBloc = oldWidgetBloc ?? context.read<B>();
    final currentBloc = widgetBloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      resolvedBloc = currentBloc;
      onBlocChanged(currentBloc);
    }
  }

  /// Resolves and updates [resolvedBloc] when an inherited dependency changes.
  ///
  /// When the resolved bloc changes, [resolvedBloc] is updated and
  /// [onBlocChanged] is called.
  @protected
  void resolveBlocOnDependencyChange() {
    final bloc = widgetBloc ?? context.read<B>();
    if (resolvedBloc != bloc) {
      resolvedBloc = bloc;
      onBlocChanged(bloc);
    }
  }

  /// Registers a [BuildContext.select] call so the widget rebuilds when the
  /// nearest [BlocProvider]'s bloc reference changes.
  ///
  /// Call this at the start of the `build` or `buildWithChild` method when
  /// [widgetBloc] may be `null` (i.e. the bloc is resolved from the context).
  /// See https://github.com/felangel/bloc/issues/2127.
  @protected
  void applyBlocSelectGuard(BuildContext context) {
    if (widgetBloc == null) {
      context.select<B, bool>((bloc) => identical(resolvedBloc, bloc));
    }
  }
}

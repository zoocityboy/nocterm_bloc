import 'dart:async';

import 'package:nocterm/nocterm.dart';
import 'package:nocterm_bloc/nocterm_bloc.dart';

import 'bloc_state_mixin.dart';
import 'provider/src/provider.dart';

/// Signature for the `listener` function which takes the `BuildContext` along
/// with the `state` and is responsible for executing in response to
/// `state` changes.
typedef BlocWidgetListener<S> = void Function(BuildContext context, S state);

/// Signature for the `listenWhen` function which takes the previous `state`
/// and the current `state` and is responsible for returning a [bool] which
/// determines whether or not to call [BlocWidgetListener] of [BlocListener]
/// with the current `state`.
typedef BlocListenerCondition<S> = bool Function(S previous, S current);

/// {@template bloc_listener}
/// Takes a [BlocWidgetListener] and an optional [bloc] and invokes
/// the [listener] in response to `state` changes in the [bloc].
/// It should be used for functionality that needs to occur only in response to
/// a `state` change such as navigation, showing a `SnackBar`, showing
/// a `Dialog`, etc...
/// The [listener] is guaranteed to only be called once for each `state` change
/// unlike the `builder` in `BlocBuilder`.
///
/// If the [bloc] parameter is omitted, [BlocListener] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   value: blocA,
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
///
/// {@template bloc_listener_listen_when}
/// An optional [listenWhen] can be implemented for more granular control
/// over when [listener] is called.
/// [listenWhen] will be invoked on each [bloc] `state` change.
/// [listenWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [listener] function
/// will be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc]
/// when the [BlocListener] is initialized.
/// [listenWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   child: Container(),
/// )
/// ```
/// {@endtemplate}
class BlocListener<B extends StateStreamable<S>, S>
    extends BlocListenerBase<B, S> {
  /// {@macro bloc_listener}
  /// {@macro bloc_listener_listen_when}
  const BlocListener({
    required BlocWidgetListener<S> listener,
    Key? key,
    B? bloc,
    BlocListenerCondition<S>? listenWhen,
    Component? child,
  }) : super(
         key: key,
         child: child,
         listener: listener,
         bloc: bloc,
         listenWhen: listenWhen,
       );
}

/// {@template bloc_listener_base}
/// Base class for widgets that listen to state changes in a specified [bloc].
///
/// A [BlocListenerBase] is stateful and maintains the state subscription.
/// The type of the state and what happens with each state change
/// is defined by sub-classes.
/// {@endtemplate}
abstract class BlocListenerBase<B extends StateStreamable<S>, S>
    extends SingleChildStatefulComponent {
  /// {@macro bloc_listener_base}
  const BlocListenerBase({
    required this.listener,
    Key? key,
    this.bloc,
    this.child,
    this.listenWhen,
  }) : super(key: key, child: child);

  /// The widget which will be rendered as a descendant of the
  /// [BlocListenerBase].
  final Component? child;

  /// The [bloc] whose `state` will be listened to.
  /// Whenever the [bloc]'s `state` changes, [listener] will be invoked.
  final B? bloc;

  /// The [BlocWidgetListener] which will be called on every `state` change.
  /// This [listener] should be used for any code which needs to execute
  /// in response to a `state` change.
  final BlocWidgetListener<S> listener;

  /// {@macro bloc_listener_listen_when}
  final BlocListenerCondition<S>? listenWhen;

  @override
  SingleChildState<BlocListenerBase<B, S>> createState() =>
      _BlocListenerBaseState<B, S>();
}

class _BlocListenerBaseState<B extends StateStreamable<S>, S>
    extends SingleChildState<BlocListenerBase<B, S>>
    with BlocStateMixin<B, S> {
  StreamSubscription<S>? _subscription;
  late S _previousState;

  @override
  B? get widgetBloc => component.bloc;

  @override
  void onBlocChanged(B newBloc) {
    if (_subscription != null) {
      _unsubscribe();
      _previousState = newBloc.state;
    }
    _subscribe();
  }

  @override
  void initState() {
    super.initState();
    resolvedBloc = component.bloc ?? context.read<B>();
    _previousState = resolvedBloc.state;
    _subscribe();
  }

  @override
  void didUpdateComponent(BlocListenerBase<B, S> oldComponent) {
    super.didUpdateComponent(oldComponent);
    resolveBlocOnUpdate(oldComponent.bloc);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resolveBlocOnDependencyChange();
  }

  @override
  Component buildWithChild(BuildContext context, Component? child) {
    applyBlocSelectGuard(context);
    return child ?? const SizedBox.shrink();
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = resolvedBloc.stream.listen((state) {
      if (!mounted) return;
      if (component.listenWhen?.call(_previousState, state) ?? true) {
        component.listener(context, state);
      }
      _previousState = state;
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
    _subscription = null;
  }
}

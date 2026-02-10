import 'package:nocterm/nocterm.dart';
import 'package:nocterm_bloc/nocterm_bloc.dart';

/// Signature for the `selector` function which
/// is responsible for returning a selected value, [T], based on [state].
typedef BlocWidgetSelector<S, T> = T Function(S state);

/// {@template bloc_selector}
/// [BlocSelector] is analogous to [BlocBuilder] but allows developers to
/// filter updates by selecting a new value based on the bloc state.
/// Unnecessary builds are prevented if the selected value does not change.
///
/// **Note**: the selected value must be immutable in order for [BlocSelector]
/// to accurately determine whether [builder] should be called again.
///
/// ```dart
/// BlocSelector<BlocA, BlocAState, SelectedState>(
///   selector: (state) {
///     // return selected state based on the provided state.
///   },
///   builder: (context, state) {
///     // return widget here based on the selected state.
///   },
/// )
/// ```
/// {@endtemplate}
class BlocSelector<B extends StateStreamable<S>, S, T>
    extends StatefulComponent {
  /// {@macro bloc_selector}
  const BlocSelector({
    required this.selector,
    required this.builder,
    Key? key,
    this.bloc,
  }) : super(key: key);

  /// The [bloc] that the [BlocSelector] will interact with.
  /// If omitted, [BlocSelector] will automatically perform a lookup using
  /// [BlocProvider] and the current [BuildContext].
  final B? bloc;

  /// The [builder] function which will be invoked
  /// when the selected state changes.
  /// The [builder] takes the [BuildContext] and selected `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [BlocBuilder].
  final BlocWidgetBuilder<T> builder;

  /// The [selector] function which will be invoked on each widget build
  /// and is responsible for returning a selected value of type [T] based on
  /// the current state.
  final BlocWidgetSelector<S, T> selector;

  @override
  State<BlocSelector<B, S, T>> createState() => _BlocSelectorState<B, S, T>();
}

class _BlocSelectorState<B extends StateStreamable<S>, S, T>
    extends State<BlocSelector<B, S, T>> {
  late B _bloc;
  late T _state;

  @override
  void initState() {
    super.initState();
    _bloc = component.bloc ?? context.read<B>();
    _state = component.selector(_bloc.state);
  }

  @override
  void didUpdateComponent(BlocSelector<B, S, T> oldWidget) {
    super.didUpdateComponent(oldWidget);
    final oldBloc = oldWidget.bloc ?? context.read<B>();
    final currentBloc = component.bloc ?? oldBloc;
    if (oldBloc != currentBloc) {
      _bloc = currentBloc;
      _state = component.selector(_bloc.state);
    } else if (oldWidget.selector != component.selector) {
      _state = component.selector(_bloc.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bloc = component.bloc ?? context.read<B>();
    if (_bloc != bloc) {
      _bloc = bloc;
      _state = component.selector(_bloc.state);
    }
  }

  @override
  Component build(BuildContext context) {
    if (component.bloc == null) {
      // Trigger a rebuild if the bloc reference has changed.
      // See https://github.com/felangel/bloc/issues/2127.
      context.select<B, bool>((bloc) => identical(_bloc, bloc));
    }
    return BlocListener<B, S>(
      bloc: _bloc,
      listener: (context, state) {
        final selectedState = component.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: component.builder(context, _state),
    );
  }
}

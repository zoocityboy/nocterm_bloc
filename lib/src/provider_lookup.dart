import 'package:nocterm/nocterm.dart';

import 'provider/src/provider.dart';

/// Looks up a value of type [T] from [context] using [Provider.of].
///
/// [callerName] is used in the error message to identify the calling method
/// (e.g. `'BlocProvider.of'`). [widgetName] identifies the owning widget class
/// (e.g. `'BlocProvider'`) for the "widget above the X" hint.
///
/// [typeDescription] is an optional prefix for the type in the first
/// sentence (e.g. `'repository of type'` to produce
/// "does not contain a repository of type T"). Defaults to a bare type name.
///
/// Throws a [FlutterError] with a helpful message when no ancestor
/// [Provider] of type [T] is found, forwarding any unrelated
/// [ProviderNotFoundException] unchanged.
T lookupProvider<T>(
  BuildContext context, {
  required bool listen,
  required String callerName,
  required String widgetName,
  String? typeDescription,
}) {
  try {
    return Provider.of<T>(context, listen: listen);
  } on ProviderNotFoundException catch (e) {
    if (e.valueType != T) rethrow;
    final description = typeDescription != null ? '$typeDescription $T' : '$T';
    throw FlutterError('''
        $callerName() called with a context that does not contain a $description.
        No ancestor could be found starting from the context that was passed to $callerName<$T>().

        This can happen if the context you used comes from a widget above the $widgetName.

        The context used was: $context
        ''');
  }
}

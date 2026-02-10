import 'package:nocterm/nocterm.dart';
import 'package:nocterm_bloc/nocterm_bloc.dart';

Future<void> main() async {
  runApp(
    NoctermApp(
      home: BlocProvider(
        create: (context) => _CounterCubit(),
        child: CounterDemo(),
      ),
    ),
  );
}

class CounterDemo extends StatelessComponent {
  static const maxCount = 20;
  Component build(BuildContext context) {
    return Focusable(
      onKeyEvent: (event) {
        final cubit = context.read<_CounterCubit>();
        if (event.logicalKey == LogicalKey.arrowRight) {
          cubit.increment();
          return true;
        }
        if (event.logicalKey == LogicalKey.arrowLeft) {
          cubit.decrement();
          return true;
        }
        if (event.logicalKey == LogicalKey.keyR) {
          cubit.reset();
          return true;
        }
        return false;
      },
      child: BlocListener<_CounterCubit, int>(
        listenWhen: (previous, current) => current != previous,
        listener: (context, count) {
          if (count == maxCount) {
            Navigator.of(context)
                .showDialog(
                  builder: (context) {
                    final theme = TuiTheme.of(context);
                    return Container(
                      width: 40,
                      height: 7,
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: theme.success,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Max count reached!',
                            style: TextStyle(
                              color: theme.onSuccess,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Press ESC to close.',
                            style: TextStyle(
                              color: theme.onSuccess,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                )
                .then((value) {});
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _TitleLabel(),
            const SizedBox(height: 1),
            const _CounterComponent(),
            const SizedBox(height: 1),
            const _ProgressRow(),
            const SizedBox(height: 1),
            const _HintsComponent(),
          ],
        ),
      ),
      focused: true,
    );
  }
}

/// A simple component that displays the title of the app.
class _TitleLabel extends StatelessComponent {
  const _TitleLabel();
  Component build(BuildContext context) {
    return Text(
      '⚡ Counter',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

/// A component that listens to the `_CounterCubit` and displays the current count.
class _CounterComponent extends StatelessComponent {
  const _CounterComponent();
  Component build(BuildContext context) {
    return BlocBuilder<_CounterCubit, int>(
      builder: (context, count) {
        return Text(
          '$count',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        );
      },
    );
  }
}

/// A component that listens to the `_CounterCubit` and displays a progress bar based on the current count.
class _ProgressRow extends StatelessComponent {
  const _ProgressRow();
  Component build(BuildContext context) {
    return BlocBuilder<_CounterCubit, int>(
      builder: (context, count) {
        final progress = (count % 20) / 20;
        final barWidth = 30;
        final filled = (progress * barWidth).round();
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('▕', style: TextStyle(color: Colors.gray)),
                Text('█' * filled, style: TextStyle(color: Colors.magenta)),
                Text(
                  '░' * (barWidth - filled),
                  style: TextStyle(color: Colors.gray),
                ),
                Text('▏', style: TextStyle(color: Colors.gray)),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// A component that displays hints for the user on how to interact with the app.
class _HintsComponent extends StatelessComponent {
  const _HintsComponent();
  Component build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Right arrow', style: TextStyle(color: Colors.yellow)),
        Text(' +1  ', style: TextStyle(color: Colors.gray)),
        Text('Left arrow', style: TextStyle(color: Colors.yellow)),
        Text(' -1  ', style: TextStyle(color: Colors.gray)),
        Text('R', style: TextStyle(color: Colors.yellow)),
        Text(' reset', style: TextStyle(color: Colors.gray)),
      ],
    );
  }
}

/// A simple Cubit that manages an integer state representing a counter.
// ignore: prefer_file_naming_conventions
class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

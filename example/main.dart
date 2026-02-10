import 'package:nocterm/nocterm.dart';
import 'package:nocterm_bloc/nocterm_bloc.dart';

Future<void> main() async {
  runApp(
    NoctermApp(
      home: BlocProvider(
        create: (context) => CounterCubit(),
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
        final cubit = context.read<CounterCubit>();
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
      child: BlocConsumer<CounterCubit, int>(
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
        builder: (context, count) {
          final progress = (count % 20) / 20;
          final barWidth = 30;
          final filled = (progress * barWidth).round();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '⚡ Counter',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
              const SizedBox(height: 1),
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
              const SizedBox(height: 1),
              Row(
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
              ),
            ],
          );
        },
      ),
      focused: true,
    );
  }
}

/// A simple Cubit that manages an integer state representing a counter.
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
  void reset() => emit(0);
}

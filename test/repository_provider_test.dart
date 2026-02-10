// ignore_for_file: prefer_file_naming_conventions
import 'package:nocterm/nocterm.dart';
import 'package:test/test.dart';

import 'package:nocterm_bloc/nocterm_bloc.dart';

class MockRepository {
  int value = 42;
  bool disposed = false;

  void dispose() {
    disposed = true;
  }
}

void main() {
  test('RepositoryProvider provides repository to descendants', () async {
    await testNocterm('repository provider', (tester) async {
      final repository = MockRepository();

      await tester.pumpComponent(
        RepositoryProvider.value(
          value: repository,
          child: Builder(
            builder: (context) {
              final repo = RepositoryProvider.of<MockRepository>(context);
              return Text('Value: ${repo.value}');
            },
          ),
        ),
      );

      expect(tester.terminalState, containsText('Value: 42'));
    });
  });

  test('RepositoryProvider with create function', () async {
    await testNocterm('repository create', (tester) async {
      await tester.pumpComponent(
        RepositoryProvider<MockRepository>(
          create: (context) => MockRepository(),
          child: Builder(
            builder: (context) {
              final repo = RepositoryProvider.of<MockRepository>(context);
              return Text('Value: ${repo.value}');
            },
          ),
        ),
      );

      expect(tester.terminalState, containsText('Value: 42'));
    });
  });

  test('RepositoryProvider with dispose', () async {
    await testNocterm('repository dispose', (tester) async {
      await tester.pumpComponent(
        RepositoryProvider<MockRepository>(
          create: (context) => MockRepository(),
          dispose: (repo) => repo.dispose(),
          child: Builder(
            builder: (context) {
              final repo = RepositoryProvider.of<MockRepository>(context);
              return Text('Value: ${repo.value}');
            },
          ),
        ),
      );

      expect(tester.terminalState, containsText('Value: 42'));
      // Dispose is called on component removal, but hard to test in this setup
    });
  });

  test('RepositoryProvider with lazy false', () async {
    await testNocterm('repository lazy false', (tester) async {
      bool created = false;

      await tester.pumpComponent(
        RepositoryProvider<MockRepository>(
          create: (context) {
            created = true;
            return MockRepository();
          },
          lazy: false,
          child: Builder(
            builder: (context) {
              final repo = RepositoryProvider.of<MockRepository>(context);
              return Text('Value: ${repo.value}');
            },
          ),
        ),
      );

      expect(created, isTrue); // Should be created immediately
      expect(tester.terminalState, containsText('Value: 42'));
    });
  });

  test('RepositoryProvider nested overrides', () async {
    await testNocterm('repository nested', (tester) async {
      await tester.pumpComponent(
        RepositoryProvider<MockRepository>(
          create: (context) => MockRepository()..value = 1,
          child: RepositoryProvider<MockRepository>(
            create: (context) => MockRepository()..value = 2,
            child: Builder(
              builder: (context) {
                final repo = RepositoryProvider.of<MockRepository>(context);
                return Text('Value: ${repo.value}');
              },
            ),
          ),
        ),
      );

      expect(tester.terminalState, containsText('Value: 2')); // Inner overrides
    });
  });
}

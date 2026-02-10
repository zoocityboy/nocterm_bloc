// ignore_for_file: prefer_file_naming_conventions
import 'package:nocterm/nocterm.dart';
import 'package:test/test.dart';

import 'package:nocterm_bloc/nocterm_bloc.dart';

class MockRepositoryA {
  String name = 'A';
}

class MockRepositoryB {
  String name = 'B';
}

void main() {
  test('MultiRepositoryProvider provides multiple repositories', () async {
    await testNocterm('multi repository', (tester) async {
      await tester.pumpComponent(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<MockRepositoryA>(
              create: (context) => MockRepositoryA(),
            ),
            RepositoryProvider<MockRepositoryB>(
              create: (context) => MockRepositoryB(),
            ),
          ],
          child: Builder(
            builder: (context) {
              final repoA = RepositoryProvider.of<MockRepositoryA>(context);
              final repoB = RepositoryProvider.of<MockRepositoryB>(context);
              return Text('Repos: ${repoA.name}${repoB.name}');
            },
          ),
        ),
      );

      expect(tester.terminalState, containsText('Repos: AB'));
    });
  });
}

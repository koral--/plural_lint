import 'dart:io';
import 'package:custom_lint/custom_lint.dart';
import 'package:test/scaffolding.dart';

import 'minion_stdout.dart';

void main() {
  test('sample test', () async {
    final minionStdout = MinionStdout();

    await IOOverrides.runZoned(
      () => customLint(
          watchMode: false,
          workingDirectory: Directory('${Directory.current.path}/example'),
        ),
      stdout: () => minionStdout,
    );
    print(await minionStdout.getCapturedOutput());
  });
}

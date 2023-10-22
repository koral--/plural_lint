import 'dart:io';
import 'dart:convert';
import 'package:custom_lint/custom_lint.dart';
import 'package:test/scaffolding.dart';

import 'minion_stdout.dart';

void main() {
  test('description', () async {
    final minionStdout = MinionStdout();

    final output = utf8.decodeStream(minionStdout.controller.stream);
    await IOOverrides.runZoned(
      () async {
        stdout.write('Hello world');
        await customLint(
          watchMode: false,
          workingDirectory: Directory(
              '/Users/koral/AndroidStudioProjects/plural_lint/example'),
        );
      },
      stdout: () => minionStdout,
    );
    await minionStdout.close();
    print(await output);
  });
}

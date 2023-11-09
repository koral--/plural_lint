import 'dart:io';

import 'package:custom_lint/custom_lint.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'capturing_stdout.dart';

void main() {
  test('performs lint checks', () async {
    final capturingStdout = CapturingStdout();
    await IOOverrides.runZoned(
      () => customLint(
        watchMode: false,
        workingDirectory: Directory('${Directory.current.path}/example'),
      ),
      stdout: () => capturingStdout,
    );

    final output = await capturingStdout.getCapturedOutput();

    expect(
        output,
        contains(
            'lib/l10n/intl_en.arb:3:15 • These quantities: [one] are missing for locale: en • missing_quantity • WARNING'));
    expect(
        output,
        contains(
            'lib/l10n/intl_fr.arb:3:15 • These quantities: [one, many] are missing for locale: fr • missing_quantity • WARNING'));
    expect(
        output,
        contains(
            'lib/l10n/intl_pl.arb:3:15 • These quantities: [one, few, many] are missing for locale: pl • missing_quantity • WARNING'));
    expect(
        output,
        contains(
            'lib/l10n/intl_en.arb:4:16 • These quantities: [few, many] are not used in locale: en • unused_quantity • INFO'));
    expect(
        output,
        contains(
            'lib/l10n/intl_fr.arb:4:16 • These quantities: [few] are not used in locale: fr • unused_quantity • INFO'));
    expect(
        output,
        contains(
            "/lib/l10n/intl_zz.arb'. No CLDR plural rules for locale: zz"));
  });
}

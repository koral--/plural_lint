import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:plural_lint/src/rules/plural_lint_rule.dart';
import 'package:plural_lint/src/utils/extensions.dart';

class ExtraQuantityLintRule extends PluralLintRule {
  ExtraQuantityLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'extra_quantity',
    problemMessage: 'These quantities: {0} are not meaningful for locale: {1}',
    errorSeverity: ErrorSeverity.INFO,
  );

  @override
  void runPluralLintCheck(
    ErrorReporter reporter,
    List<String> quantitiesForLocale,
    List<(List<String>, int)> plurals,
    String locale,
  ) {
    for (final (quantities, position) in plurals) {
      final unrecognizedQuantities = quantities.normalizePluralQuantities();
      unrecognizedQuantities.removeWhere(quantitiesForLocale.contains);
      if (unrecognizedQuantities.isNotEmpty) {
        reporter.reportErrorForOffset(
          code,
          position,
          0,
          [unrecognizedQuantities.toString(), locale],
        );
      }
    }
  }
}

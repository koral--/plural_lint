import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:plural_lint/src/rules/plural_lint_rule.dart';
import 'package:plural_lint/src/utils/extensions.dart';

class MissingQuantityLintRule extends PluralLintRule {
  MissingQuantityLintRule() : super(code: _code);

  static const _code = LintCode(
    name: 'missing_quantity',
    problemMessage: 'These quantities: {0} are missing for locale: {1}',
    errorSeverity: ErrorSeverity.WARNING,
  );

  @override
  void runPluralLintCheck(
    ErrorReporter reporter,
    List<String> quantitiesForLocale,
    List<(List<String>, int)> plurals,
    String locale,
  ) {
    for (final (quantities, position) in plurals) {
      final missingQuantities = List.from(quantitiesForLocale);
      missingQuantities
          .removeWhere(quantities.normalizePluralQuantities().contains);
      if (missingQuantities.isNotEmpty) {
        reporter.reportErrorForOffset(
          code,
          position,
          0,
          [missingQuantities.toString(), locale],
        );
      }
    }
  }
}

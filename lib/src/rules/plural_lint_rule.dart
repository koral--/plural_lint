import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:petitparser/petitparser.dart';
import 'package:plural_lint/src/arb/definition.dart';
import 'package:plural_lint/src/cldr/plural_rules.dart';

abstract class PluralLintRule extends LintRule {
  const PluralLintRule({required super.code});

  @override
  @nonVirtual
  List<String> get filesToAnalyze => const ['**.arb'];

  @override
  Future<void> startUp(
    CustomLintResolver resolver,
    CustomLintContext context,
  ) async {
    await CldrData().initialize();
    return super.startUp(resolver, context);
  }

  @override
  @nonVirtual
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final filePath = resolver.path;
    final plurals = <(List<String>, int)>[];
    final jsonParseResult = JsonDefinition(plurals.add)
        .build()
        .parse(resolver.source.contents.data);
    if (jsonParseResult is Failure) {
      print(
          'Ignoring ARB: $filePath. JSON parsing error: ${jsonParseResult.message}');
      return;
    }
    final json = jsonParseResult.value;
    final locale = json['@@locale'] ??
        json['_locale'] ??
        basenameWithoutExtension(filePath).split('_').skip(1).join('_');

    final quantitiesForLocale = CldrData().pluralRules()[locale];
    if (quantitiesForLocale == null) {
      print(
          'Ignoring ARB: $filePath. No CLDR plural rules for locale: $locale');
      return;
    }

    runPluralLintCheck(reporter, quantitiesForLocale, plurals, locale);
  }

  void runPluralLintCheck(
    ErrorReporter reporter,
    List<String> quantitiesForLocale,
    List<(List<String>, int)> plurals,
    String locale,
  );
}

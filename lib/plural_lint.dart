import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'src/rules/missing_quantity_lint_rule.dart';
import 'src/rules/extra_quantity_lint_rule.dart';

/// Entry point for `custom_lint`.
PluginBase createPlugin() => _PluralLint();

class _PluralLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        ExtraQuantityLintRule(),
        MissingQuantityLintRule(),
      ];
}

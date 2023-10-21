# plural_lint

[![Pub Version](https://img.shields.io/pub/v/plural_lint)](https://pub.dev/packages/plural_lint)

**plural_lint** is a developer tool to check plural translations in your project. 
It detects both missing and unused plural quantities in the ARB files.

## Installing plural_lint

plural_lint bases on [custom_lint]. To use it, you have 2 options.
Either add the dependencies to your `pubspec.yaml`:

```yaml
dev_dependencies:
  custom_lint:
  plural_lint:
```

Or install them from the command line:

```sh
flutter pub add --dev custom_lint plural_lint
```

Next, enable the `custom_lint` analyzer plugin in your `analysis_options.yaml`:

```yaml
analyzer:
  plugins:
    - custom_lint
```

## All the lints

### missing_quantity

This lint detects missing plural quantities in your translations. For example in English (`en`),
you need to provide translations for `one` and `other` quantities. In Polish (`pl`), 
you need `one`, `few`, `many` and `other`. 
If you don't provide all the required quantities the lint will report that as a warning.

For instance, the following entry in English ARB file:
```json
{ "things" : "{count, plural, other{things}}" }
```
Will trigger a warning:
```
warning: These quantities: [one] are missing for locale: en (missing_quantity at [app] lib/l10n/intl_en.arb:3)
```

### extra_quantity

This lint detects unused plural quantities in your translations. For example in English (`en`),
`few` and `many` quantities will never be used. Note that `zero`, `one` and `two` 
are supported by dart's [intl](https://pub.dev/packages/intl) package in all languages. Even if 
they are not listed in CLDR rules. 
For example you can provide `zero` quantity in English despite that English doesn't distinguish 
a special case for zero. See [intl implementation](https://github.com/dart-lang/i18n/blob/main/pkgs/intl/lib/intl.dart#L323)
for more details.

For instance, the following entry in English ARB file:
```json
{ "things2" : "{count, plural, one{thing} few{things} many{things} other{things}}" }
```
Will trigger a warning:
```
info: These quantities: [few, many] are not meaningful for locale: en (extra_quantity at [app] lib/l10n/intl_en.arb:4)
```

### Data source

This package has embedded CLDR rules for plural forms in [plurals.xml](lib/src/cldr/plurals.xml).
That file is taken from the official [Unicode CLDR repository](https://github.com/unicode-org/cldr/blob/main/common/supplemental/plurals.xml).

### Disabling specific rules

By default all the lints are be enabled. You can disable specific rules by modifying 
the `analysis_options.yaml` file like this:

```yaml
custom_lint:
  rules:
    - extra_quantity: false
```

## Running plural_lint from the terminal/CI

Custom lint rules may not show-up in `dart analyze`.
To fix this, invoke a `custom_lint` in the terminal:

```sh
dart run custom_lint
```

[custom_lint]: https://pub.dev/packages/custom_lint

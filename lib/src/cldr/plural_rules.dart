import 'dart:async';
import 'dart:convert';

import 'package:resource_portable/resource.dart' show Resource;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class CldrData {
  CldrData._() {
    _loadCldrPluralRules()
        .then((value) => _pluralRules = value)
        .then((_) => _completer.complete(null));
  }

  static final _instance = CldrData._();
  final Completer<void> _completer = Completer.sync();
  Map<String, List<String>>? _pluralRules;

  factory CldrData() => _instance;

  Future<void> initialize() => _completer.future;

  Map<String, List<String>> pluralRules() {
    if (_pluralRules == null) {
      throw StateError('CldrData is not initialized');
    }
    return _pluralRules!;
  }

  static Future<Map<String, List<String>>> _loadCldrPluralRules() async =>
      Map.fromEntries(XmlDocument.parse(
              await Resource('package:plural_lint/src/cldr/plurals.xml')
                  .readAsString(encoding: utf8))
          .xpath('/supplementalData/plurals/pluralRules')
          .map((item) => (
                item.xpath('@locales').first.value!.split(' '),
                item
                    .xpath('pluralRule/@count')
                    .map((e) => e.value!)
                    .toList(growable: false),
              ))
          .map((item) {
        final (locales, counts) = item;
        return locales
            .map((locale) => MapEntry(locale, counts))
            .toList(growable: false);
      }).fold(
        <MapEntry<String, List<String>>>[],
        (previousValue, element) => previousValue.toList()..addAll(element),
      ));
}

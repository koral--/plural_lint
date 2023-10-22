import 'dart:convert';

import 'package:resource_portable/resource.dart' show Resource;
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

class CldrData {
  CldrData._();

  static Future<Map<String, List<String>>> pluralRules() async =>
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

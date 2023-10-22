import 'package:petitparser/petitparser.dart';

import 'encoding.dart';
import 'types.dart';

/// JSON grammar definition.
class JsonDefinition extends GrammarDefinition<JSON> {
  final PluralFoundCallback onPluralFound;

  JsonDefinition(this.onPluralFound);

  @override
  Parser<JSON> start() => ref0(value).end();

  Parser<JSON> value() => [
        ref0(object),
        ref0(array),
        ref0(stringToken),
        ref0(numberToken),
        ref0(trueToken),
        ref0(falseToken),
        ref0(nullToken),
        failure('value expected'),
      ].toChoiceParser();

  Parser<Map<String, JSON>> object() => seq3(
        char('{').trim(),
        ref0(objectElements),
        char('}').trim(),
      ).map3((_, elements, __) => elements);

  Parser<Map<String, JSON>> objectElements() => ref0(objectElement)
      .starSeparated(char(',').trim())
      .map((list) => Map.fromEntries(list.elements));

  Parser<MapEntry<String, JSON>> objectElement() =>
      seq3(ref0(stringToken), char(':').trim(), ref0(value))
          .map3((key, String _, value) => MapEntry(key, value));

  Parser<List<JSON>> array() => seq3(
        char('[').trim(),
        ref0(arrayElements),
        char(']').trim(),
      ).map3((_, elements, __) => elements);

  Parser<List<JSON>> arrayElements() =>
      ref0(value).starSeparated(char(',').trim()).map((list) => list.elements);

  Parser<bool> trueToken() => string('true').trim().map((_) => true);

  Parser<bool> falseToken() => string('false').trim().map((_) => false);

  Parser<Object?> nullToken() => string('null').trim().map((_) => null);

  Parser<void> empty() => epsilon();

  Parser get quotedCurly => (string("'{'") | string("'}'")).map((x) => x[1]);

  Parser get twoSingleQuotes => string("''").map((x) => "'");

  Parser get icuEscapedText => quotedCurly | twoSingleQuotes;

  Parser get notAllowedInIcuText => (char('{') | char('}')) | char('<');

  Parser get icuText => notAllowedInIcuText.neg();

  Parser get messageText => (icuEscapedText | icuText).plus().flatten();

  Parser get contents =>
      intlPlural() | (char('{') & placeholder() & char('}')) | messageText;

  Parser interiorText() => undefined()..set(contents.plus() | empty());

  Parser<String> pluralValue() => seq3(
        char('{'),
        interiorText(),
        char('}').trim(),
      ).map3((_, value, __) => value.toString());

  Parser<String> pluralQuantity() => [
        letter().plus(),
        seq2(char('='), digit()),
      ].toChoiceParser().flatten().trim();

  Parser<List<String>> pluralClauses() => seq2(
        ref0(pluralQuantity),
        ref0(pluralValue),
      ).plus().map(
          (list) => list.map((item) => item.first).toList(growable: false));

  Parser<String> placeholder() => seq2(
        ref0(letter),
        [
          ref0(word),
          char('_'),
        ].toChoiceParser().star(),
      ).flatten().trim();

  Parser<List<String>> pluralBody() => seq5(
        ref0(placeholder),
        char(',').trim(),
        string('plural'),
        char(',').trim(),
        pluralClauses(),
      ).map5((_, __, ___, ____, values) => values);

  Parser<List<String>> intlPlural() => seq3(
        char('{').trim(),
        pluralBody(),
        char('}').trim(),
      ).map3((_, chars, __) => chars).callCC((continuation, context) {
        final result = continuation(context);
        if (result is Success) {
          onPluralFound((result.value, context.position));
        }
        return result;
      });

  Parser<String> stringToken() => seq3(
        char('"'),
        ref0(stringOrPlural),
        char('"'),
      ).trim().map3((_, chars, __) => chars.toString());

  Parser<Object> stringOrPlural() => [
        ref0(intlPlural),
        ref0(stringBody),
      ].toChoiceParser();

  Parser<String> stringBody() =>
      ref0(characterPrimitive).star().map((chars) => chars.join());

  Parser<String> characterPrimitive() => [
        ref0(characterNormal),
        ref0(characterEscape),
        ref0(characterUnicode),
      ].toChoiceParser();

  Parser<String> characterNormal() => pattern('^"\\');

  Parser<String> characterEscape() => seq2(
        char('\\'),
        anyOf(jsonEscapeChars.keys.join()),
      ).map2((_, char) => jsonEscapeChars[char]!);

  Parser<String> characterUnicode() => seq2(
        string('\\u'),
        pattern('0-9A-Fa-f').timesString(4, '4-digit hex number expected'),
      ).map2((_, value) => String.fromCharCode(int.parse(value, radix: 16)));

  Parser<num> numberToken() =>
      ref0(numberPrimitive).flatten('number expected').trim().map(num.parse);

  Parser<void> numberPrimitive() => <Parser<void>>[
        char('-').optional(),
        [char('0'), digit().plus()].toChoiceParser(),
        [char('.'), digit().plus()].toSequenceParser().optional(),
        [anyOf('eE'), anyOf('-+').optional(), digit().plus()]
            .toSequenceParser()
            .optional()
      ].toSequenceParser();
}

typedef PluralFoundCallback = void Function((List<String>, int));

class Plural {
  final String quantity;
  final String value;

  Plural(this.quantity, this.value);
}

/*
This file incorporates work covered by the following copyright and
permission notice from https://github.com/localizely/intl_utils/blob/master/lib/src/parser/icu_parser.dart:

Copyright 2020 The Localizely Authors. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Localizely Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

This file incorporates work covered by the following copyright and
permission notice from https://github.com/petitparser/dart-petitparser-examples/blob/main/lib/json.dart

The MIT License

Copyright (c) 2006-2023 Lukas Renggli.
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import 'package:petitparser/petitparser.dart';

import 'encoding.dart';

class JsonDefinition extends GrammarDefinition<Object?> {
  final void Function((List<String>, int)) onPluralFound;

  const JsonDefinition(this.onPluralFound);

  @override
  Parser<Object?> start() => ref0(value).end();

  Parser<Object?> value() => [
        ref0(object),
        ref0(array),
        ref0(stringToken),
        ref0(numberToken),
        ref0(trueToken),
        ref0(falseToken),
        ref0(nullToken),
        failure('value expected'),
      ].toChoiceParser();

  Parser<Map<String, Object?>> object() => seq3(
        char('{').trim(),
        ref0(objectElements),
        char('}').trim(),
      ).map3((_, elements, __) => elements);

  Parser<Map<String, Object?>> objectElements() => ref0(objectElement)
      .starSeparated(char(',').trim())
      .map((list) => Map.fromEntries(list.elements));

  Parser<MapEntry<String, Object?>> objectElement() =>
      seq3(ref0(stringToken), char(':').trim(), ref0(value))
          .map3((key, String _, value) => MapEntry(key, value));

  Parser<List<Object?>> array() => seq3(
        char('[').trim(),
        ref0(arrayElements),
        char(']').trim(),
      ).map3((_, elements, __) => elements);

  Parser<List<Object?>> arrayElements() =>
      ref0(value).starSeparated(char(',').trim()).map((list) => list.elements);

  Parser<bool> trueToken() => string('true').trim().map((_) => true);

  Parser<bool> falseToken() => string('false').trim().map((_) => false);

  Parser<Object?> nullToken() => string('null').trim().map((_) => null);

  Parser<void> empty() => epsilon();

  Parser<String> quotedCurly() => [
        string("'{'"),
        string("'}'"),
      ].toChoiceParser().map((x) => x[1]);

  Parser<String> icuEscapedText() => [
        ref0(quotedCurly),
        string("''").map((x) => "'"),
      ].toChoiceParser();

  Parser<String> notAllowedInIcuText() => [
        [
          char('{'),
          char('}'),
        ].toChoiceParser(),
        char('<'),
      ].toChoiceParser();

  Parser<String> icuText() => ref0(notAllowedInIcuText).neg();

  Parser<String> messageText() => [
        ref0(icuEscapedText),
        ref0(icuText),
      ].toChoiceParser().plus().flatten();

  Parser<Object> contents() => [
        ref0(intlPlural),
        seq3(
          char('{'),
          ref0(placeholder),
          char('}'),
        ),
        ref0(messageText),
      ].toChoiceParser();

  Parser interiorText() => undefined()
    ..set([
      ref0(contents).plus(),
      ref0(empty),
    ].toChoiceParser());

  Parser<String> pluralValue() => seq3(
        char('{'),
        ref0(interiorText),
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

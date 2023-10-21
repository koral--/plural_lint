extension ListExtension on List<String> {
  List<String> normalizePluralQuantities() => map((item) => switch (item) {
        '=0' => 'zero',
        '=1' => 'one',
        '=2' => 'two',
        _ => item,
      }).toList();
}

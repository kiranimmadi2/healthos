// Counts remaining hard-coded colour usage outside the theme layer.
//
// Run: dart run tool/theme_debt.dart
//
// Used as a ratchet during the dark-mode sweep: the numbers must only ever go
// down. Deprecation annotations were deliberately NOT used for this, because
// `flutter analyze` exits non-zero on info-level issues and ~150 deprecation
// notices would break the "analyze stays clean" invariant for the whole sweep.
//
// The two columns mean different things:
//
//  * `token` counts reads of the light-only AppColors members from outside the
//    theme layer. These are genuine dark-mode BUGS -- a light slate value
//    rendered on a dark surface. This column is at zero and must stay there.
//    (The members themselves stay: app_theme.dart uses them to build the light
//    ThemeData, which is exactly what they are for.)
//
//  * `hex` counts raw colour literals. Not all of these are bugs -- gradient
//    stops, brand accents and `isDark ? a : b` ternaries all render correctly
//    in both themes. They are style debt: values that bypass the token system
//    and so drift. Worth reducing, but not a correctness issue.
import 'dart:io';

/// Files allowed to contain raw colour literals: the palette itself.
const _themeDir = 'lib/src/app/theme/';

/// Light-only members of AppColors. Brand colours (primary, error, gradients)
/// are intentionally constant across themes and are not debt.
final _lightOnlyTokens = RegExp(
  r'AppColors\.(textPrimary|textMain|textSecondary|textMuted|surfaceMuted|surface|background|border)\b',
);

final _hexLiteral = RegExp(r'Color\(0x');

void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll(r'\', '/').contains(_themeDir))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var totalHex = 0;
  var totalTokens = 0;
  final rows = <({String path, int hex, int tokens})>[];

  for (final file in files) {
    final source = file.readAsStringSync();
    final hex = _hexLiteral.allMatches(source).length;
    final tokens = _lightOnlyTokens.allMatches(source).length;
    if (hex == 0 && tokens == 0) continue;
    totalHex += hex;
    totalTokens += tokens;
    rows.add((
      path: file.path.replaceAll(r'\', '/').replaceFirst('lib/', ''),
      hex: hex,
      tokens: tokens,
    ));
  }

  rows.sort((a, b) => (b.hex + b.tokens).compareTo(a.hex + a.tokens));

  stdout.writeln('Theme debt (outside $_themeDir)');
  stdout.writeln('${'file'.padRight(62)} ${'hex'.padLeft(5)} ${'token'.padLeft(6)}');
  stdout.writeln('-' * 76);
  for (final row in rows) {
    stdout.writeln(
      '${row.path.padRight(62)} '
      '${row.hex.toString().padLeft(5)} '
      '${row.tokens.toString().padLeft(6)}',
    );
  }
  stdout.writeln('-' * 76);
  stdout.writeln(
    '${'TOTAL'.padRight(62)} '
    '${totalHex.toString().padLeft(5)} '
    '${totalTokens.toString().padLeft(6)}',
  );

  if (totalHex == 0 && totalTokens == 0) {
    stdout.writeln('\nClean. Delete the light-only AppColors members and this script.');
  }
}

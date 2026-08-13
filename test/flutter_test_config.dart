import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

/// Applied automatically to every test in this directory tree.
///
/// `AppTheme` builds its text theme with `GoogleFonts.interTextTheme()`, which
/// fetches Inter over the network on first use. Tests have no network, so the
/// fetch throws and fails otherwise-unrelated assertions. Disabling runtime
/// fetching makes google_fonts fall back to the bundled default silently.
///
/// (In the app itself this fetch is real: Inter is downloaded at runtime rather
/// than bundled, so first launch depends on the network and shows a brief FOUT.)
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await testMain();
}

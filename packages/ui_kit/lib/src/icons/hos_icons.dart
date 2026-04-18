import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Curated icon facade for HealthOS.
///
/// Every icon rendered across the 4 apps MUST come from this class so that
/// the visual stroke weight and feel stay uniform. Under the hood we use
/// Lucide Icons (2px stroke, rounded line-caps). If an icon is missing here,
/// add it to this file rather than reaching into `LucideIcons` directly.
class HosIcons {
  HosIcons._();

  // ─── Navigation ────────────────────────────────────────────────────────
  static const IconData home = LucideIcons.house;
  static const IconData reports = LucideIcons.fileText;
  static const IconData symptoms = LucideIcons.stethoscope;
  static const IconData profile = LucideIcons.userRound;
  static const IconData family = LucideIcons.usersRound;
  static const IconData notifications = LucideIcons.bell;
  static const IconData notificationsActive = LucideIcons.bellRing;
  static const IconData settings = LucideIcons.settings;
  static const IconData dashboard = LucideIcons.layoutDashboard;
  static const IconData patients = LucideIcons.users;
  static const IconData doctors = LucideIcons.stethoscope;

  // ─── Medical ───────────────────────────────────────────────────────────
  static const IconData appointment = LucideIcons.calendarClock;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData vitals = LucideIcons.activity;
  static const IconData heartRate = LucideIcons.heartPulse;
  static const IconData temperature = LucideIcons.thermometer;
  static const IconData bloodDrop = LucideIcons.droplet;
  static const IconData prescription = LucideIcons.pill;
  static const IconData medication = LucideIcons.pill;
  static const IconData injection = LucideIcons.syringe;
  static const IconData labReport = LucideIcons.flaskConical;
  static const IconData biomarker = LucideIcons.microscope;
  static const IconData diagnosis = LucideIcons.clipboardList;
  static const IconData allergy = LucideIcons.triangleAlert;
  static const IconData note = LucideIcons.stickyNote;
  static const IconData hospital = LucideIcons.hospital;
  static const IconData building = LucideIcons.building2;

  // ─── Actions ───────────────────────────────────────────────────────────
  static const IconData add = LucideIcons.plus;
  static const IconData edit = LucideIcons.pencil;
  static const IconData editNote = LucideIcons.squarePen;
  static const IconData delete = LucideIcons.trash2;
  static const IconData search = LucideIcons.search;
  static const IconData filter = LucideIcons.funnel;
  static const IconData share = LucideIcons.share2;
  static const IconData copy = LucideIcons.copy;
  static const IconData close = LucideIcons.x;
  static const IconData back = LucideIcons.chevronLeft;
  static const IconData forward = LucideIcons.chevronRight;
  static const IconData more = LucideIcons.ellipsis;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData upload = LucideIcons.upload;
  static const IconData download = LucideIcons.download;
  static const IconData qr = LucideIcons.qrCode;
  static const IconData login = LucideIcons.logIn;
  static const IconData logout = LucideIcons.logOut;
  static const IconData send = LucideIcons.send;
  static const IconData chat = LucideIcons.messageSquare;

  // ─── Status ────────────────────────────────────────────────────────────
  static const IconData success = LucideIcons.circleCheck;
  static const IconData successFilled = LucideIcons.circleCheckBig;
  static const IconData warning = LucideIcons.triangleAlert;
  static const IconData error = LucideIcons.circleX;
  static const IconData info = LucideIcons.info;
  static const IconData verified = LucideIcons.shieldCheck;
  static const IconData pending = LucideIcons.clock;
  static const IconData locked = LucideIcons.lock;
  static const IconData unlocked = LucideIcons.lockOpen;
  static const IconData blocked = LucideIcons.ban;
  static const IconData visible = LucideIcons.eye;
  static const IconData hidden = LucideIcons.eyeOff;

  // ─── Personal ──────────────────────────────────────────────────────────
  static const IconData age = LucideIcons.cake;
  static const IconData genderFemale = LucideIcons.venus;
  static const IconData genderMale = LucideIcons.mars;
  static const IconData location = LucideIcons.mapPin;

  // ─── AI / Smart features ───────────────────────────────────────────────
  static const IconData ai = LucideIcons.sparkles;
  static const IconData aiBrain = LucideIcons.brain;
  static const IconData knowledge = LucideIcons.bookOpen;

  /// Design system default icon size for inline use (paired with labels).
  static const double sizeSm = 16;

  /// Default icon size used by [HosButton] and most list rows.
  static const double sizeMd = 20;

  /// Larger icon size used for feature headers and empty states.
  static const double sizeLg = 24;
}

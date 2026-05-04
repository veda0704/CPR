import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @loading_step.
  ///
  /// In en, this message translates to:
  /// **'Loading Step...'**
  String get loading_step;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'YES'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'NO'**
  String get no;

  /// No description provided for @module_complete.
  ///
  /// In en, this message translates to:
  /// **'Module Complete!'**
  String get module_complete;

  /// No description provided for @back_to_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get back_to_dashboard;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Connection error'**
  String get connection_error;

  /// No description provided for @practitioner.
  ///
  /// In en, this message translates to:
  /// **'PRACTITIONER'**
  String get practitioner;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get testing;

  /// No description provided for @certification.
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certification;

  /// No description provided for @explore_protocol.
  ///
  /// In en, this message translates to:
  /// **'Explore Protocol'**
  String get explore_protocol;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @module_prefix.
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get module_prefix;

  /// No description provided for @scene_safety_module.
  ///
  /// In en, this message translates to:
  /// **'Scene Safety & PPE'**
  String get scene_safety_module;

  /// No description provided for @abcde_module.
  ///
  /// In en, this message translates to:
  /// **'Systematic ABCDE'**
  String get abcde_module;

  /// No description provided for @bls_cpr_module.
  ///
  /// In en, this message translates to:
  /// **'BLS & CPR'**
  String get bls_cpr_module;

  /// No description provided for @airway_module.
  ///
  /// In en, this message translates to:
  /// **'Airway Anatomy'**
  String get airway_module;

  /// No description provided for @adv_airway_module.
  ///
  /// In en, this message translates to:
  /// **'Advanced Airway'**
  String get adv_airway_module;

  /// No description provided for @choking_module.
  ///
  /// In en, this message translates to:
  /// **'Choking Management'**
  String get choking_module;

  /// No description provided for @ecg_rhythms_module.
  ///
  /// In en, this message translates to:
  /// **'ECG & Rhythm Management'**
  String get ecg_rhythms_module;

  /// No description provided for @cardiac_alg_module.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Algorithms'**
  String get cardiac_alg_module;

  /// No description provided for @stroke_assessment.
  ///
  /// In en, this message translates to:
  /// **'Stroke Assessment'**
  String get stroke_assessment;

  /// No description provided for @delivery_module.
  ///
  /// In en, this message translates to:
  /// **'NLS & Delivery'**
  String get delivery_module;

  /// No description provided for @poisoning_module.
  ///
  /// In en, this message translates to:
  /// **'Poisoning Management'**
  String get poisoning_module;

  /// No description provided for @snake_bite_module.
  ///
  /// In en, this message translates to:
  /// **'Snake Bite Management'**
  String get snake_bite_module;

  /// No description provided for @trauma_module.
  ///
  /// In en, this message translates to:
  /// **'Trauma & Bleeding'**
  String get trauma_module;

  /// No description provided for @disaster_module.
  ///
  /// In en, this message translates to:
  /// **'Disaster Management'**
  String get disaster_module;

  /// No description provided for @h5t5_module.
  ///
  /// In en, this message translates to:
  /// **'Reversible Causes (H5T5)'**
  String get h5t5_module;

  /// No description provided for @start_acls.
  ///
  /// In en, this message translates to:
  /// **'Professional ACLS Simulator'**
  String get start_acls;

  /// No description provided for @abcde_desc.
  ///
  /// In en, this message translates to:
  /// **'Assess Airway, Breathing, Circulation, Disability, and Exposure.'**
  String get abcde_desc;

  /// No description provided for @bls_desc.
  ///
  /// In en, this message translates to:
  /// **'Basic Life Support and chest compressions.'**
  String get bls_desc;

  /// No description provided for @airway_desc.
  ///
  /// In en, this message translates to:
  /// **'Managing the upper airway and adjuncts.'**
  String get airway_desc;

  /// No description provided for @adv_airway_desc.
  ///
  /// In en, this message translates to:
  /// **'Intubation and supraglottic devices.'**
  String get adv_airway_desc;

  /// No description provided for @choking_desc.
  ///
  /// In en, this message translates to:
  /// **'Foreign Body Airway Obstruction maneuvers.'**
  String get choking_desc;

  /// No description provided for @ecg_rhythms_desc.
  ///
  /// In en, this message translates to:
  /// **'Master ECG rhythm interpretation and cardiac block management.'**
  String get ecg_rhythms_desc;

  /// No description provided for @cardiac_alg_desc.
  ///
  /// In en, this message translates to:
  /// **'V-fib, Pulseless V-tach, Asystole, PEA.'**
  String get cardiac_alg_desc;

  /// No description provided for @stroke_desc.
  ///
  /// In en, this message translates to:
  /// **'Rapid assessment and code stroke protocols.'**
  String get stroke_desc;

  /// No description provided for @delivery_desc.
  ///
  /// In en, this message translates to:
  /// **'Managing emergency child birth.'**
  String get delivery_desc;

  /// No description provided for @poisoning_desc.
  ///
  /// In en, this message translates to:
  /// **'Assessment, toxidrome recognition, antidotes, decontamination, and rapid transport.'**
  String get poisoning_desc;

  /// No description provided for @snake_bite_desc.
  ///
  /// In en, this message translates to:
  /// **'Assessment and prehospital management of venomous snakebite.'**
  String get snake_bite_desc;

  /// No description provided for @trauma_desc.
  ///
  /// In en, this message translates to:
  /// **'Initial assessment and management of major trauma and bleeding.'**
  String get trauma_desc;

  /// No description provided for @disaster_desc.
  ///
  /// In en, this message translates to:
  /// **'START triage and incident command.'**
  String get disaster_desc;

  /// No description provided for @h5t5_desc.
  ///
  /// In en, this message translates to:
  /// **'Reversible causes of cardiac arrest.'**
  String get h5t5_desc;

  /// No description provided for @acls_desc.
  ///
  /// In en, this message translates to:
  /// **'The complete mock-code experience.'**
  String get acls_desc;

  /// No description provided for @scene_safety_desc.
  ///
  /// In en, this message translates to:
  /// **'Assess danger zones and wear protective equipment before helping.'**
  String get scene_safety_desc;

  /// No description provided for @start_module.
  ///
  /// In en, this message translates to:
  /// **'START MODULE'**
  String get start_module;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @continue_label.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_label;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get in_progress;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @not_started.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get not_started;

  /// No description provided for @module_locked.
  ///
  /// In en, this message translates to:
  /// **'Complete previous modules to unlock this module.'**
  String get module_locked;

  /// No description provided for @complete_label.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get complete_label;

  /// No description provided for @last_accessed.
  ///
  /// In en, this message translates to:
  /// **'LAST ACCESSED'**
  String get last_accessed;

  /// No description provided for @total_content.
  ///
  /// In en, this message translates to:
  /// **'TOTAL CONTENT'**
  String get total_content;

  /// No description provided for @modules_count.
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get modules_count;

  /// No description provided for @start_here.
  ///
  /// In en, this message translates to:
  /// **'START HERE'**
  String get start_here;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

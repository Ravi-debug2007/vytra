import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
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
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('hi'),
    Locale('te')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'VYTRA'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'See Health. Detect Early.'**
  String get tagline;

  /// No description provided for @categoryLine.
  ///
  /// In en, this message translates to:
  /// **'AI HEALTH SCREENING'**
  String get categoryLine;

  /// No description provided for @languageFooter.
  ///
  /// In en, this message translates to:
  /// **'A screening aid. Not a diagnosis.'**
  String get languageFooter;

  /// No description provided for @languageTelugu.
  ///
  /// In en, this message translates to:
  /// **'తెలుగు'**
  String get languageTelugu;

  /// No description provided for @languageHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी'**
  String get languageHindi;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @homeNewScreening.
  ///
  /// In en, this message translates to:
  /// **'New screening'**
  String get homeNewScreening;

  /// No description provided for @homeOfflineReady.
  ///
  /// In en, this message translates to:
  /// **'Works without internet'**
  String get homeOfflineReady;

  /// No description provided for @homeMoreTools.
  ///
  /// In en, this message translates to:
  /// **'More tools'**
  String get homeMoreTools;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Consent'**
  String get consentTitle;

  /// LOCKED. In-app consent body. Must match 07_LOCALIZATION.md §3.
  ///
  /// In en, this message translates to:
  /// **'VYTRA is a screening aid for trained health workers. It is not a medical diagnosis and it does not measure hemoglobin or bilirubin.\n\nIf you agree, the app will use the camera to photograph the inner eyelid and the white of the eye. The photographs are analysed on this phone and then discarded. They are not saved.\n\nThe app stores only the risk class (low, moderate, high, or unable to assess), the time, the phone model, a skin-tone category, and the lighting. It does not store a name, a photograph, or a location.\n\nStored records become eligible for deletion 30 days after capture and are removed the next time the app cleans up. If this phone is used in the study, an anonymised copy may also be sent to the study server when the phone is online. The server copy follows its own deletion schedule.\n\nYou may refuse. If you refuse, nothing is stored and the screening will not start.'**
  String get consentBody;

  /// No description provided for @consentAgree.
  ///
  /// In en, this message translates to:
  /// **'I agree'**
  String get consentAgree;

  /// No description provided for @consentDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get consentDecline;

  /// No description provided for @discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard this screening?'**
  String get discardTitle;

  /// No description provided for @discardBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing will be saved.'**
  String get discardBody;

  /// No description provided for @discardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardConfirm;

  /// No description provided for @discardCancel.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get discardCancel;

  /// No description provided for @metaTitle.
  ///
  /// In en, this message translates to:
  /// **'About this visit'**
  String get metaTitle;

  /// No description provided for @metaSkinTone.
  ///
  /// In en, this message translates to:
  /// **'Skin tone'**
  String get metaSkinTone;

  /// No description provided for @metaFitzpatrick1.
  ///
  /// In en, this message translates to:
  /// **'I'**
  String get metaFitzpatrick1;

  /// No description provided for @metaFitzpatrick2.
  ///
  /// In en, this message translates to:
  /// **'II'**
  String get metaFitzpatrick2;

  /// No description provided for @metaFitzpatrick3.
  ///
  /// In en, this message translates to:
  /// **'III'**
  String get metaFitzpatrick3;

  /// No description provided for @metaFitzpatrick4.
  ///
  /// In en, this message translates to:
  /// **'IV'**
  String get metaFitzpatrick4;

  /// No description provided for @metaFitzpatrick5.
  ///
  /// In en, this message translates to:
  /// **'V'**
  String get metaFitzpatrick5;

  /// No description provided for @metaFitzpatrick6.
  ///
  /// In en, this message translates to:
  /// **'VI'**
  String get metaFitzpatrick6;

  /// No description provided for @metaWhoChose.
  ///
  /// In en, this message translates to:
  /// **'Who chose the tone?'**
  String get metaWhoChose;

  /// No description provided for @metaPersonSaid.
  ///
  /// In en, this message translates to:
  /// **'Person said'**
  String get metaPersonSaid;

  /// No description provided for @metaIAssessed.
  ///
  /// In en, this message translates to:
  /// **'I assessed'**
  String get metaIAssessed;

  /// No description provided for @metaLightNow.
  ///
  /// In en, this message translates to:
  /// **'Light right now'**
  String get metaLightNow;

  /// No description provided for @metaIndoorNatural.
  ///
  /// In en, this message translates to:
  /// **'Indoor window'**
  String get metaIndoorNatural;

  /// No description provided for @metaIndoorArtificial.
  ///
  /// In en, this message translates to:
  /// **'Indoor bulb'**
  String get metaIndoorArtificial;

  /// No description provided for @metaOutdoorShade.
  ///
  /// In en, this message translates to:
  /// **'Outdoor shade'**
  String get metaOutdoorShade;

  /// No description provided for @metaOutdoorDirect.
  ///
  /// In en, this message translates to:
  /// **'Outdoor sun'**
  String get metaOutdoorDirect;

  /// No description provided for @metaContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get metaContinue;

  /// No description provided for @whiteRefTitle.
  ///
  /// In en, this message translates to:
  /// **'Set the light'**
  String get whiteRefTitle;

  /// No description provided for @whiteRefCoach.
  ///
  /// In en, this message translates to:
  /// **'Hold the phone 15–20 cm above a plain white paper. Fill the box.'**
  String get whiteRefCoach;

  /// No description provided for @whiteRefFailDark.
  ///
  /// In en, this message translates to:
  /// **'Too dark. Move to a window or turn on a light.'**
  String get whiteRefFailDark;

  /// No description provided for @whiteRefFailCast.
  ///
  /// In en, this message translates to:
  /// **'The paper looks tinted. Use a plain white sheet, not a wall or a desk.'**
  String get whiteRefFailCast;

  /// No description provided for @whiteRefFailClip.
  ///
  /// In en, this message translates to:
  /// **'Too bright. Turn the phone or the paper out of direct glare.'**
  String get whiteRefFailClip;

  /// No description provided for @whiteRefTorch.
  ///
  /// In en, this message translates to:
  /// **'Torch'**
  String get whiteRefTorch;

  /// No description provided for @captureAnemiaTitle.
  ///
  /// In en, this message translates to:
  /// **'Inner eyelid'**
  String get captureAnemiaTitle;

  /// No description provided for @captureJaundiceTitle.
  ///
  /// In en, this message translates to:
  /// **'White of the eye'**
  String get captureJaundiceTitle;

  /// No description provided for @captureAnemiaCoach.
  ///
  /// In en, this message translates to:
  /// **'Ask the person to look up. Gently pull the lower lid down. Fill the ring with the inner pink.'**
  String get captureAnemiaCoach;

  /// No description provided for @captureScleraCoach.
  ///
  /// In en, this message translates to:
  /// **'Ask the person to look toward their nose. Do not pull the lid. Fill the ring with the outer white.'**
  String get captureScleraCoach;

  /// No description provided for @captureHoldStill.
  ///
  /// In en, this message translates to:
  /// **'Hold still. The photo is blurry.'**
  String get captureHoldStill;

  /// No description provided for @captureBrighter.
  ///
  /// In en, this message translates to:
  /// **'Need more light. Face a window.'**
  String get captureBrighter;

  /// No description provided for @captureLessSun.
  ///
  /// In en, this message translates to:
  /// **'Too bright. Step into shade.'**
  String get captureLessSun;

  /// No description provided for @captureEyeClosed.
  ///
  /// In en, this message translates to:
  /// **'The eye is closed. Ask them to look toward their nose.'**
  String get captureEyeClosed;

  /// No description provided for @captureUseThese.
  ///
  /// In en, this message translates to:
  /// **'Use these'**
  String get captureUseThese;

  /// No description provided for @captureTakeOneMore.
  ///
  /// In en, this message translates to:
  /// **'Take one more'**
  String get captureTakeOneMore;

  /// No description provided for @captureAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Reading the photo…'**
  String get captureAnalysing;

  /// No description provided for @captureCounter.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max}'**
  String captureCounter(int current, int max);

  /// No description provided for @captureFallbackEllipse.
  ///
  /// In en, this message translates to:
  /// **'Aim with the ring. Face outline is not needed.'**
  String get captureFallbackEllipse;

  /// No description provided for @lampBlur.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get lampBlur;

  /// No description provided for @lampLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lampLight;

  /// No description provided for @lampEye.
  ///
  /// In en, this message translates to:
  /// **'Eye open'**
  String get lampEye;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Screening result'**
  String get resultsTitle;

  /// No description provided for @resultsAnemia.
  ///
  /// In en, this message translates to:
  /// **'Anemia'**
  String get resultsAnemia;

  /// No description provided for @resultsJaundice.
  ///
  /// In en, this message translates to:
  /// **'Jaundice'**
  String get resultsJaundice;

  /// No description provided for @riskHigh.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get riskHigh;

  /// No description provided for @riskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate risk'**
  String get riskModerate;

  /// No description provided for @riskLow.
  ///
  /// In en, this message translates to:
  /// **'Low risk'**
  String get riskLow;

  /// No description provided for @riskUnable.
  ///
  /// In en, this message translates to:
  /// **'Could not read'**
  String get riskUnable;

  /// No description provided for @actionAnemiaHigh.
  ///
  /// In en, this message translates to:
  /// **'Refer to the PHC for a blood test today.'**
  String get actionAnemiaHigh;

  /// No description provided for @actionAnemiaModerate.
  ///
  /// In en, this message translates to:
  /// **'Watch closely. Refer to the PHC within 3 days, or sooner if the person feels worse.'**
  String get actionAnemiaModerate;

  /// No description provided for @actionAnemiaLow.
  ///
  /// In en, this message translates to:
  /// **'Continue routine care.'**
  String get actionAnemiaLow;

  /// No description provided for @actionJaundiceHigh.
  ///
  /// In en, this message translates to:
  /// **'Refer to the PHC for a clinical check today.'**
  String get actionJaundiceHigh;

  /// No description provided for @actionJaundiceModerate.
  ///
  /// In en, this message translates to:
  /// **'Watch closely. Refer to the PHC within 24 hours, or sooner if the yellow colour increases.'**
  String get actionJaundiceModerate;

  /// No description provided for @actionJaundiceLow.
  ///
  /// In en, this message translates to:
  /// **'Continue routine care.'**
  String get actionJaundiceLow;

  /// No description provided for @actionUnable.
  ///
  /// In en, this message translates to:
  /// **'This part could not be read. Refer if you are unsure.'**
  String get actionUnable;

  /// No description provided for @bannerReferToday.
  ///
  /// In en, this message translates to:
  /// **'Immediate referral recommended. Accompany the person to the PHC today.'**
  String get bannerReferToday;

  /// LOCKED. Must appear on S08 and the PDF. Do not shorten.
  ///
  /// In en, this message translates to:
  /// **'This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.'**
  String get disclaimerFull;

  /// No description provided for @resultsGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get resultsGeneratePdf;

  /// No description provided for @resultsDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get resultsDone;

  /// No description provided for @resultsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save. Try again.'**
  String get resultsSaveFailed;

  /// No description provided for @pdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Referral note'**
  String get pdfTitle;

  /// No description provided for @pdfNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name or household number'**
  String get pdfNameLabel;

  /// No description provided for @pdfNameHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get pdfNameHint;

  /// No description provided for @pdfNameNote.
  ///
  /// In en, this message translates to:
  /// **'This name is written on the PDF only. It is not saved in the app.'**
  String get pdfNameNote;

  /// No description provided for @pdfCreate.
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get pdfCreate;

  /// No description provided for @pdfFooter.
  ///
  /// In en, this message translates to:
  /// **'Generated by VYTRA {version}. This is not a medical document. For use by trained ASHA workers only.'**
  String pdfFooter(String version);

  /// No description provided for @pdfPatientNotProvided.
  ///
  /// In en, this message translates to:
  /// **'Patient: [Not provided]'**
  String get pdfPatientNotProvided;

  /// No description provided for @pdfPatientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient: {name}'**
  String pdfPatientLabel(String name);

  /// No description provided for @syncTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved screenings'**
  String get syncTitle;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get syncPending;

  /// No description provided for @syncSynced.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get syncSynced;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get syncFailed;

  /// No description provided for @syncEmpty.
  ///
  /// In en, this message translates to:
  /// **'No screenings on this phone.'**
  String get syncEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLicences.
  ///
  /// In en, this message translates to:
  /// **'Open-source licences'**
  String get settingsLicences;

  /// No description provided for @settingsVersions.
  ///
  /// In en, this message translates to:
  /// **'App {app}  ·  {algorithm}  ·  {threshold}'**
  String settingsVersions(String app, String algorithm, String threshold);

  /// No description provided for @researchTitle.
  ///
  /// In en, this message translates to:
  /// **'Research view'**
  String get researchTitle;

  /// No description provided for @researchPinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get researchPinLabel;

  /// No description provided for @researchUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get researchUnlock;

  /// No description provided for @researchWrongPin.
  ///
  /// In en, this message translates to:
  /// **'That PIN is wrong.'**
  String get researchWrongPin;

  /// No description provided for @researchWarning.
  ///
  /// In en, this message translates to:
  /// **'Research view — do not show the patient.'**
  String get researchWarning;

  /// No description provided for @researchNoScreening.
  ///
  /// In en, this message translates to:
  /// **'No screening on this phone yet.'**
  String get researchNoScreening;

  /// No description provided for @permCameraRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to screen.'**
  String get permCameraRequired;

  /// No description provided for @permCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera is blocked. Enable it in system settings to continue.'**
  String get permCameraDenied;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @secondaryTitle.
  ///
  /// In en, this message translates to:
  /// **'More tools'**
  String get secondaryTitle;

  /// No description provided for @secondaryNeedInternet.
  ///
  /// In en, this message translates to:
  /// **'These tools need internet. The main screening still works offline.'**
  String get secondaryNeedInternet;

  /// No description provided for @secondaryInternetWarning.
  ///
  /// In en, this message translates to:
  /// **'These tools need internet. Photos are sent to an outside service. Not a diagnosis.'**
  String get secondaryInternetWarning;

  /// No description provided for @secondarySkin.
  ///
  /// In en, this message translates to:
  /// **'Skin check'**
  String get secondarySkin;

  /// No description provided for @secondaryTeeth.
  ///
  /// In en, this message translates to:
  /// **'Teeth check'**
  String get secondaryTeeth;

  /// No description provided for @secondarySkinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental · needs net'**
  String get secondarySkinSubtitle;

  /// No description provided for @secondaryTeethSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental · needs net'**
  String get secondaryTeethSubtitle;

  /// No description provided for @secondaryNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Not configured'**
  String get secondaryNotConfigured;

  /// No description provided for @secondaryThirdPartyNote.
  ///
  /// In en, this message translates to:
  /// **'This photo was sent to an outside service and was not stored in VYTRA.'**
  String get secondaryThirdPartyNote;

  /// No description provided for @secondaryModelBusy.
  ///
  /// In en, this message translates to:
  /// **'The model is busy. Try again in a moment.'**
  String get secondaryModelBusy;

  /// No description provided for @secondaryConfigError.
  ///
  /// In en, this message translates to:
  /// **'This tool is not set up on this build.'**
  String get secondaryConfigError;

  /// No description provided for @secondarySkinConsent.
  ///
  /// In en, this message translates to:
  /// **'If you agree, a photo of the skin will be sent to Hugging Face for an experimental label. It is not a diagnosis. It is not stored in the VYTRA health database. You may refuse.'**
  String get secondarySkinConsent;

  /// No description provided for @secondaryTeethConsent.
  ///
  /// In en, this message translates to:
  /// **'If you agree, a photo of the teeth will be sent to Roboflow for an experimental score. It is not a diagnosis. It is not stored in the VYTRA health database. You may refuse.'**
  String get secondaryTeethConsent;

  /// No description provided for @secondarySuggestedCheck.
  ///
  /// In en, this message translates to:
  /// **'Suggested check'**
  String get secondarySuggestedCheck;

  /// No description provided for @secondaryModelScore.
  ///
  /// In en, this message translates to:
  /// **'Model score: {pct}%'**
  String secondaryModelScore(int pct);

  /// No description provided for @secondaryAlsoConsidered.
  ///
  /// In en, this message translates to:
  /// **'Also considered'**
  String get secondaryAlsoConsidered;

  /// No description provided for @secondaryAbcde.
  ///
  /// In en, this message translates to:
  /// **'ABCDE guide'**
  String get secondaryAbcde;

  /// No description provided for @secondaryAbcdeA.
  ///
  /// In en, this message translates to:
  /// **'Asymmetry'**
  String get secondaryAbcdeA;

  /// No description provided for @secondaryAbcdeB.
  ///
  /// In en, this message translates to:
  /// **'Border irregularity'**
  String get secondaryAbcdeB;

  /// No description provided for @secondaryAbcdeC.
  ///
  /// In en, this message translates to:
  /// **'Colour variation'**
  String get secondaryAbcdeC;

  /// No description provided for @secondaryAbcdeD.
  ///
  /// In en, this message translates to:
  /// **'Diameter larger than about 6 mm'**
  String get secondaryAbcdeD;

  /// No description provided for @secondaryAbcdeE.
  ///
  /// In en, this message translates to:
  /// **'Evolving (changing)'**
  String get secondaryAbcdeE;

  /// No description provided for @secondaryAbcdeFooter.
  ///
  /// In en, this message translates to:
  /// **'This guide is for awareness. Only a clinician can assess a mole.'**
  String get secondaryAbcdeFooter;

  /// No description provided for @secondaryAlignmentScore.
  ///
  /// In en, this message translates to:
  /// **'Alignment score (estimate)'**
  String get secondaryAlignmentScore;

  /// No description provided for @secondaryGradeA.
  ///
  /// In en, this message translates to:
  /// **'Looks evenly spaced'**
  String get secondaryGradeA;

  /// No description provided for @secondaryGradeB.
  ///
  /// In en, this message translates to:
  /// **'Mostly even'**
  String get secondaryGradeB;

  /// No description provided for @secondaryGradeC.
  ///
  /// In en, this message translates to:
  /// **'Some crowding or gaps'**
  String get secondaryGradeC;

  /// No description provided for @secondaryGradeD.
  ///
  /// In en, this message translates to:
  /// **'Clear crowding or gaps'**
  String get secondaryGradeD;

  /// No description provided for @secondaryGradeF.
  ///
  /// In en, this message translates to:
  /// **'Very uneven — clinical check'**
  String get secondaryGradeF;

  /// No description provided for @secondaryTeethAdvice.
  ///
  /// In en, this message translates to:
  /// **'An orthodontist or dentist can say if treatment is needed.'**
  String get secondaryTeethAdvice;

  /// No description provided for @secondaryNotADiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Experimental label. Not a diagnosis.'**
  String get secondaryNotADiagnosis;
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
      <String>['en', 'hi', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

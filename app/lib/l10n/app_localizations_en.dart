// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'VYTRA';

  @override
  String get tagline => 'See Health. Detect Early.';

  @override
  String get categoryLine => 'AI HEALTH SCREENING';

  @override
  String get languageFooter => 'A screening aid. Not a diagnosis.';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeNewScreening => 'New screening';

  @override
  String get homeOfflineReady => 'Works without internet';

  @override
  String get homeMoreTools => 'More tools';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get consentTitle => 'Consent';

  @override
  String get consentBody =>
      'VYTRA is a screening aid for trained health workers. It is not a medical diagnosis and it does not measure hemoglobin or bilirubin.\n\nIf you agree, the app will use the camera to photograph the inner eyelid and the white of the eye. The photographs are analysed on this phone and then discarded. They are not saved.\n\nThe app stores only the risk class (low, moderate, high, or unable to assess), the time, the phone model, a skin-tone category, and the lighting. It does not store a name, a photograph, or a location.\n\nStored records become eligible for deletion 30 days after capture and are removed the next time the app cleans up. If this phone is used in the study, an anonymised copy may also be sent to the study server when the phone is online. The server copy follows its own deletion schedule.\n\nYou may refuse. If you refuse, nothing is stored and the screening will not start.';

  @override
  String get consentAgree => 'I agree';

  @override
  String get consentDecline => 'Decline';

  @override
  String get discardTitle => 'Discard this screening?';

  @override
  String get discardBody => 'Nothing will be saved.';

  @override
  String get discardConfirm => 'Discard';

  @override
  String get discardCancel => 'Keep going';

  @override
  String get metaTitle => 'About this visit';

  @override
  String get metaSkinTone => 'Skin tone';

  @override
  String get metaFitzpatrick1 => 'I';

  @override
  String get metaFitzpatrick2 => 'II';

  @override
  String get metaFitzpatrick3 => 'III';

  @override
  String get metaFitzpatrick4 => 'IV';

  @override
  String get metaFitzpatrick5 => 'V';

  @override
  String get metaFitzpatrick6 => 'VI';

  @override
  String get metaWhoChose => 'Who chose the tone?';

  @override
  String get metaPersonSaid => 'Person said';

  @override
  String get metaIAssessed => 'I assessed';

  @override
  String get metaLightNow => 'Light right now';

  @override
  String get metaIndoorNatural => 'Indoor window';

  @override
  String get metaIndoorArtificial => 'Indoor bulb';

  @override
  String get metaOutdoorShade => 'Outdoor shade';

  @override
  String get metaOutdoorDirect => 'Outdoor sun';

  @override
  String get metaContinue => 'Continue';

  @override
  String get whiteRefTitle => 'Set the light';

  @override
  String get whiteRefCoach =>
      'Hold the phone 15–20 cm above a plain white paper. Fill the box.';

  @override
  String get whiteRefFailDark =>
      'Too dark. Move to a window or turn on a light.';

  @override
  String get whiteRefFailCast =>
      'The paper looks tinted. Use a plain white sheet, not a wall or a desk.';

  @override
  String get whiteRefFailClip =>
      'Too bright. Turn the phone or the paper out of direct glare.';

  @override
  String get whiteRefTorch => 'Torch';

  @override
  String get captureAnemiaTitle => 'Inner eyelid';

  @override
  String get captureJaundiceTitle => 'White of the eye';

  @override
  String get captureAnemiaCoach =>
      'Ask the person to look up. Gently pull the lower lid down. Fill the ring with the inner pink.';

  @override
  String get captureScleraCoach =>
      'Ask the person to look toward their nose. Do not pull the lid. Fill the ring with the outer white.';

  @override
  String get captureHoldStill => 'Hold still. The photo is blurry.';

  @override
  String get captureBrighter => 'Need more light. Face a window.';

  @override
  String get captureLessSun => 'Too bright. Step into shade.';

  @override
  String get captureEyeClosed =>
      'The eye is closed. Ask them to look toward their nose.';

  @override
  String get captureUseThese => 'Use these';

  @override
  String get captureTakeOneMore => 'Take one more';

  @override
  String get captureAnalysing => 'Reading the photo…';

  @override
  String captureCounter(int current, int max) {
    return '$current / $max';
  }

  @override
  String get captureFallbackEllipse =>
      'Aim with the ring. Face outline is not needed.';

  @override
  String get lampBlur => 'Sharp';

  @override
  String get lampLight => 'Light';

  @override
  String get lampEye => 'Eye open';

  @override
  String get resultsTitle => 'Screening result';

  @override
  String get resultsAnemia => 'Anemia';

  @override
  String get resultsJaundice => 'Jaundice';

  @override
  String get riskHigh => 'High risk';

  @override
  String get riskModerate => 'Moderate risk';

  @override
  String get riskLow => 'Low risk';

  @override
  String get riskUnable => 'Could not read';

  @override
  String get actionAnemiaHigh => 'Refer to the PHC for a blood test today.';

  @override
  String get actionAnemiaModerate =>
      'Watch closely. Refer to the PHC within 3 days, or sooner if the person feels worse.';

  @override
  String get actionAnemiaLow => 'Continue routine care.';

  @override
  String get actionJaundiceHigh =>
      'Refer to the PHC for a clinical check today.';

  @override
  String get actionJaundiceModerate =>
      'Watch closely. Refer to the PHC within 24 hours, or sooner if the yellow colour increases.';

  @override
  String get actionJaundiceLow => 'Continue routine care.';

  @override
  String get actionUnable =>
      'This part could not be read. Refer if you are unsure.';

  @override
  String get bannerReferToday =>
      'Immediate referral recommended. Accompany the person to the PHC today.';

  @override
  String get disclaimerFull =>
      'This screening result is not a medical diagnosis. It is a triage aid for trained health workers only. All results require confirmation by a qualified medical professional. Do not make treatment decisions based on this result alone.';

  @override
  String get resultsGeneratePdf => 'Generate PDF';

  @override
  String get resultsDone => 'Done';

  @override
  String get resultsSaveFailed => 'Could not save. Try again.';

  @override
  String get pdfTitle => 'Referral note';

  @override
  String get pdfNameLabel => 'Name or household number';

  @override
  String get pdfNameHint => 'Optional';

  @override
  String get pdfNameNote =>
      'This name is written on the PDF only. It is not saved in the app.';

  @override
  String get pdfCreate => 'Create PDF';

  @override
  String pdfFooter(String version) {
    return 'Generated by VYTRA $version. This is not a medical document. For use by trained ASHA workers only.';
  }

  @override
  String get pdfPatientNotProvided => 'Patient: [Not provided]';

  @override
  String pdfPatientLabel(String name) {
    return 'Patient: $name';
  }

  @override
  String get syncTitle => 'Saved screenings';

  @override
  String get syncPending => 'Waiting';

  @override
  String get syncSynced => 'Sent';

  @override
  String get syncFailed => 'Not sent';

  @override
  String get syncEmpty => 'No screenings on this phone.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLicences => 'Open-source licences';

  @override
  String settingsVersions(String app, String algorithm, String threshold) {
    return 'App $app  ·  $algorithm  ·  $threshold';
  }

  @override
  String get researchTitle => 'Research view';

  @override
  String get researchPinLabel => 'PIN';

  @override
  String get researchUnlock => 'Unlock';

  @override
  String get researchWrongPin => 'That PIN is wrong.';

  @override
  String get researchWarning => 'Research view — do not show the patient.';

  @override
  String get researchNoScreening => 'No screening on this phone yet.';

  @override
  String get permCameraRequired => 'Camera permission is required to screen.';

  @override
  String get permCameraDenied =>
      'Camera is blocked. Enable it in system settings to continue.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get secondaryTitle => 'More tools';

  @override
  String get secondaryNeedInternet =>
      'These tools need internet. The main screening still works offline.';

  @override
  String get secondaryInternetWarning =>
      'These tools need internet. Photos are sent to an outside service. Not a diagnosis.';

  @override
  String get secondarySkin => 'Skin check';

  @override
  String get secondaryTeeth => 'Teeth check';

  @override
  String get secondarySkinSubtitle => 'Experimental · needs net';

  @override
  String get secondaryTeethSubtitle => 'Experimental · needs net';

  @override
  String get secondaryNotConfigured => 'Not configured';

  @override
  String get secondaryThirdPartyNote =>
      'This photo was sent to an outside service and was not stored in VYTRA.';

  @override
  String get secondaryModelBusy => 'The model is busy. Try again in a moment.';

  @override
  String get secondaryConfigError => 'This tool is not set up on this build.';

  @override
  String get secondarySkinConsent =>
      'If you agree, a photo of the skin will be sent to Hugging Face for an experimental label. It is not a diagnosis. It is not stored in the VYTRA health database. You may refuse.';

  @override
  String get secondaryTeethConsent =>
      'If you agree, a photo of the teeth will be sent to Roboflow for an experimental score. It is not a diagnosis. It is not stored in the VYTRA health database. You may refuse.';

  @override
  String get secondarySuggestedCheck => 'Suggested check';

  @override
  String secondaryModelScore(int pct) {
    return 'Model score: $pct%';
  }

  @override
  String get secondaryAlsoConsidered => 'Also considered';

  @override
  String get secondaryAbcde => 'ABCDE guide';

  @override
  String get secondaryAbcdeA => 'Asymmetry';

  @override
  String get secondaryAbcdeB => 'Border irregularity';

  @override
  String get secondaryAbcdeC => 'Colour variation';

  @override
  String get secondaryAbcdeD => 'Diameter larger than about 6 mm';

  @override
  String get secondaryAbcdeE => 'Evolving (changing)';

  @override
  String get secondaryAbcdeFooter =>
      'This guide is for awareness. Only a clinician can assess a mole.';

  @override
  String get secondaryAlignmentScore => 'Alignment score (estimate)';

  @override
  String get secondaryGradeA => 'Looks evenly spaced';

  @override
  String get secondaryGradeB => 'Mostly even';

  @override
  String get secondaryGradeC => 'Some crowding or gaps';

  @override
  String get secondaryGradeD => 'Clear crowding or gaps';

  @override
  String get secondaryGradeF => 'Very uneven — clinical check';

  @override
  String get secondaryTeethAdvice =>
      'An orthodontist or dentist can say if treatment is needed.';

  @override
  String get secondaryNotADiagnosis => 'Experimental label. Not a diagnosis.';
}

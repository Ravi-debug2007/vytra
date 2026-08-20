// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'VYTRA';

  @override
  String get tagline => 'See Health. Detect Early.';

  @override
  String get categoryLine => 'AI HEALTH SCREENING';

  @override
  String get languageFooter => 'यह स्क्रीनिंग सहायता है। निदान नहीं है।';

  @override
  String get languageTelugu => 'తెలుగు';

  @override
  String get languageHindi => 'हिन्दी';

  @override
  String get languageEnglish => 'English';

  @override
  String get homeNewScreening => 'नई स्क्रीनिंग';

  @override
  String get homeOfflineReady => 'इंटरनेट के बिना चलती है';

  @override
  String get homeMoreTools => 'और उपकरण';

  @override
  String get homeSettingsTooltip => 'सेटिंग्स';

  @override
  String get consentTitle => 'सहमति';

  @override
  String get consentBody =>
      'VYTRA प्रशिक्षित स्वास्थ्य कर्मियों के लिए एक स्क्रीनिंग सहायता है। यह चिकित्सीय निदान नहीं है और यह हीमोग्लोबिन या बिलीरुबिन नहीं मापता।\n\nयदि आप सहमत हैं, तो ऐप कैमरे से निचली पलक के अंदर और आँख की सफेदी की तस्वीर लेगा। तस्वीरों का विश्लेषण इसी फ़ोन पर होगा, फिर उन्हें हटा दिया जाएगा। वे सहेजी नहीं जातीं।\n\nऐप केवल जोखिम वर्ग (कम, मध्यम, अधिक, या आँक नहीं सके), समय, फ़ोन मॉडल, त्वचा-रंग वर्ग और रोशनी रखता है। नाम, तस्वीर या स्थान नहीं रखता।\n\nसहेजे गए रिकॉर्ड तस्वीर के 30 दिन बाद हटाने के योग्य होते हैं और ऐप की अगली सफ़ाई पर हटा दिए जाते हैं। यदि यह फ़ोन अध्ययन में है, तो ऑनलाइन होने पर एक अनाम प्रति अध्ययन सर्वर पर जा सकती है। सर्वर प्रति अपनी हटाने की समय-सारणी मानती है।\n\nआप मना कर सकते हैं। मना करने पर कुछ नहीं सहेजा जाता और स्क्रीनिंग शुरू नहीं होती।';

  @override
  String get consentAgree => 'मैं सहमत हूँ';

  @override
  String get consentDecline => 'मना करें';

  @override
  String get discardTitle => 'यह स्क्रीनिंग छोड़ें?';

  @override
  String get discardBody => 'कुछ नहीं सहेजा जाएगा।';

  @override
  String get discardConfirm => 'छोड़ें';

  @override
  String get discardCancel => 'जारी रखें';

  @override
  String get metaTitle => 'इस दौरे के बारे में';

  @override
  String get metaSkinTone => 'त्वचा का रंग';

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
  String get metaWhoChose => 'रंग किसने चुना?';

  @override
  String get metaPersonSaid => 'व्यक्ति ने कहा';

  @override
  String get metaIAssessed => 'मैंने आँका';

  @override
  String get metaLightNow => 'अभी की रोशनी';

  @override
  String get metaIndoorNatural => 'कमरे में खिड़की';

  @override
  String get metaIndoorArtificial => 'कमरे में बल्ब';

  @override
  String get metaOutdoorShade => 'बाहर छाया';

  @override
  String get metaOutdoorDirect => 'बाहर धूप';

  @override
  String get metaContinue => 'आगे बढ़ें';

  @override
  String get whiteRefTitle => 'रोशनी ठीक करें';

  @override
  String get whiteRefCoach =>
      'फ़ोन को सादे सफ़ेद कागज़ से 15–20 से.मी. ऊपर रखें। बक्सा भरें।';

  @override
  String get whiteRefFailDark =>
      'बहुत अँधेरा है। खिड़की के पास जाएँ या बत्ती जलाएँ।';

  @override
  String get whiteRefFailCast =>
      'कागज़ रंगा लगता है। दीवार या मेज़ नहीं — सादा सफ़ेद पन्ना इस्तेमाल करें।';

  @override
  String get whiteRefFailClip => 'बहुत तेज रोशनी। सीधी चमक से घुमाएँ।';

  @override
  String get whiteRefTorch => 'टॉर्च';

  @override
  String get captureAnemiaTitle => 'भीतरी पलक';

  @override
  String get captureJaundiceTitle => 'आँख की सफेदी';

  @override
  String get captureAnemiaCoach =>
      'व्यक्ति से ऊपर देखने को कहें। निचली पलक धीरे खींचें। घेरा भीतरी गुलाबी से भरें।';

  @override
  String get captureScleraCoach =>
      'व्यक्ति से नाक की ओर देखने को कहें। पलक न खींचें। घेरा बाहरी सफेदी से भरें।';

  @override
  String get captureHoldStill => 'रुकें। तस्वीर धुँधली है।';

  @override
  String get captureBrighter => 'और रोशनी चाहिए। खिड़की की ओर करें।';

  @override
  String get captureLessSun => 'बहुत तेज रोशनी। छाया में आएँ।';

  @override
  String get captureEyeClosed => 'आँख बंद है। नाक की ओर देखने को कहें।';

  @override
  String get captureUseThese => 'इन्हें इस्तेमाल करें';

  @override
  String get captureTakeOneMore => 'एक और लें';

  @override
  String get captureAnalysing => 'तस्वीर पढ़ी जा रही है…';

  @override
  String captureCounter(int current, int max) {
    return '$current / $max';
  }

  @override
  String get captureFallbackEllipse =>
      'घेरे से निशाना लगाएँ। चेहरे की रेखा ज़रूरी नहीं।';

  @override
  String get lampBlur => 'साफ़';

  @override
  String get lampLight => 'रोशनी';

  @override
  String get lampEye => 'आँख खुली';

  @override
  String get resultsTitle => 'स्क्रीनिंग परिणाम';

  @override
  String get resultsAnemia => 'रक्तअल्पता';

  @override
  String get resultsJaundice => 'पीलिया';

  @override
  String get riskHigh => 'अधिक जोखिम';

  @override
  String get riskModerate => 'मध्यम जोखिम';

  @override
  String get riskLow => 'कम जोखिम';

  @override
  String get riskUnable => 'पढ़ नहीं सके';

  @override
  String get actionAnemiaHigh =>
      'आज ही प्राथमिक स्वास्थ्य केंद्र में रक्त जाँच के लिए भेजें।';

  @override
  String get actionAnemiaModerate =>
      'नज़दीक से देखें। 3 दिन में, या व्यक्ति की हालत बिगड़े तो उससे पहले, प्राथमिक स्वास्थ्य केंद्र भेजें।';

  @override
  String get actionAnemiaLow => 'नियमित देखभाल जारी रखें।';

  @override
  String get actionJaundiceHigh =>
      'आज ही प्राथमिक स्वास्थ्य केंद्र में चिकित्सकीय जाँच के लिए भेजें।';

  @override
  String get actionJaundiceModerate =>
      'नज़दीक से देखें। 24 घंटे में, या पीलापन बढ़े तो उससे पहले, प्राथमिक स्वास्थ्य केंद्र भेजें।';

  @override
  String get actionJaundiceLow => 'नियमित देखभाल जारी रखें।';

  @override
  String get actionUnable => 'यह भाग पढ़ नहीं सके। संदेह हो तो रेफर करें।';

  @override
  String get bannerReferToday =>
      'तुरंत रेफर करें। आज ही व्यक्ति को प्राथमिक स्वास्थ्य केंद्र ले जाएँ।';

  @override
  String get disclaimerFull =>
      'यह स्क्रीनिंग परिणाम चिकित्सीय निदान नहीं है। यह केवल प्रशिक्षित स्वास्थ्य कर्मियों के लिए एक प्राथमिक जाँच सहायता है। सभी परिणामों की पुष्टि योग्य चिकित्सक से करानी आवश्यक है। केवल इसी परिणाम के आधार पर उपचार के निर्णय न लें।';

  @override
  String get resultsGeneratePdf => 'PDF बनाएँ';

  @override
  String get resultsDone => 'हो गया';

  @override
  String get resultsSaveFailed => 'सेव नहीं हुआ। फिर कोशिश करें।';

  @override
  String get pdfTitle => 'रेफरल पर्ची';

  @override
  String get pdfNameLabel => 'नाम या घर संख्या';

  @override
  String get pdfNameHint => 'वैकल्पिक';

  @override
  String get pdfNameNote =>
      'यह नाम केवल PDF पर लिखा जाता है। ऐप में सेव नहीं होता।';

  @override
  String get pdfCreate => 'PDF बनाएँ';

  @override
  String pdfFooter(String version) {
    return 'VYTRA $version द्वारा बनाया गया। यह चिकित्सकीय दस्तावेज़ नहीं है। केवल प्रशिक्षित आशा कार्यकर्ताओं के लिए।';
  }

  @override
  String get pdfPatientNotProvided => 'व्यक्ति: [नहीं दिया]';

  @override
  String pdfPatientLabel(String name) {
    return 'व्यक्ति: $name';
  }

  @override
  String get syncTitle => 'सेव की गई स्क्रीनिंग';

  @override
  String get syncPending => 'प्रतीक्षा';

  @override
  String get syncSynced => 'भेजा गया';

  @override
  String get syncFailed => 'नहीं भेजा';

  @override
  String get syncEmpty => 'इस फ़ोन पर स्क्रीनिंग नहीं है।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLicences => 'ओपन-सोर्स लाइसेंस';

  @override
  String settingsVersions(String app, String algorithm, String threshold) {
    return 'ऐप $app  ·  $algorithm  ·  $threshold';
  }

  @override
  String get researchTitle => 'शोध दृश्य';

  @override
  String get researchPinLabel => 'पिन';

  @override
  String get researchUnlock => 'खोलें';

  @override
  String get researchWrongPin => 'पिन गलत है।';

  @override
  String get researchWarning => 'शोध दृश्य — व्यक्ति को न दिखाएँ।';

  @override
  String get researchNoScreening => 'इस फ़ोन पर अभी कोई स्क्रीनिंग नहीं।';

  @override
  String get permCameraRequired => 'स्क्रीन करने के लिए कैमरा अनुमति चाहिए।';

  @override
  String get permCameraDenied =>
      'कैमरा बंद है। जारी रखने के लिए सिस्टम सेटिंग में चालू करें।';

  @override
  String get errorGeneric => 'कुछ गड़बड़ हुई। फिर कोशिश करें।';

  @override
  String get secondaryTitle => 'और उपकरण';

  @override
  String get secondaryNeedInternet =>
      'इन उपकरणों को इंटरनेट चाहिए। मुख्य स्क्रीनिंग ऑफ़लाइन चलती है।';

  @override
  String get secondaryInternetWarning =>
      'इन उपकरणों को इंटरनेट चाहिए। तस्वीरें बाहरी सेवा पर जाती हैं। निदान नहीं है।';

  @override
  String get secondarySkin => 'त्वचा जाँच';

  @override
  String get secondaryTeeth => 'दाँत जाँच';

  @override
  String get secondarySkinSubtitle => 'प्रयोगात्मक · नेट चाहिए';

  @override
  String get secondaryTeethSubtitle => 'प्रयोगात्मक · नेट चाहिए';

  @override
  String get secondaryNotConfigured => 'तैयार नहीं';

  @override
  String get secondaryThirdPartyNote =>
      'यह तस्वीर बाहरी सेवा पर गई। VYTRA स्वास्थ्य डेटाबेस में नहीं रखी गई।';

  @override
  String get secondaryModelBusy => 'मॉडल व्यस्त है। थोड़ी देर बाद कोशिश करें।';

  @override
  String get secondaryConfigError => 'इस बिल्ड पर यह उपकरण तैयार नहीं है।';

  @override
  String get secondarySkinConsent =>
      'सहमत होने पर त्वचा की तस्वीर प्रयोगात्मक लेबल के लिए Hugging Face पर जाएगी। यह निदान नहीं है। VYTRA स्वास्थ्य डेटाबेस में नहीं रहती। आप मना कर सकते हैं।';

  @override
  String get secondaryTeethConsent =>
      'सहमत होने पर दाँतों की तस्वीर प्रयोगात्मक स्कोर के लिए Roboflow पर जाएगी। यह निदान नहीं है। VYTRA स्वास्थ्य डेटाबेस में नहीं रहती। आप मना कर सकते हैं।';

  @override
  String get secondarySuggestedCheck => 'सुझाई गई जाँच';

  @override
  String secondaryModelScore(int pct) {
    return 'मॉडल स्कोर: $pct%';
  }

  @override
  String get secondaryAlsoConsidered => 'और माना गया';

  @override
  String get secondaryAbcde => 'ABCDE मार्गदर्शक';

  @override
  String get secondaryAbcdeA => 'असमानता';

  @override
  String get secondaryAbcdeB => 'किनारे अनियमित';

  @override
  String get secondaryAbcdeC => 'रंग में फ़र्क';

  @override
  String get secondaryAbcdeD => 'व्यास लगभग 6 मि.मी. से अधिक';

  @override
  String get secondaryAbcdeE => 'बदलता हुआ';

  @override
  String get secondaryAbcdeFooter =>
      'यह मार्गदर्शक जानकारी के लिए है। तिल का आकलन केवल चिकित्सक कर सकते हैं।';

  @override
  String get secondaryAlignmentScore => 'संरेखण स्कोर (अनुमान)';

  @override
  String get secondaryGradeA => 'बराबर दिखते हैं';

  @override
  String get secondaryGradeB => 'ज्यादातर बराबर';

  @override
  String get secondaryGradeC => 'कुछ भीड़ या अंतराल';

  @override
  String get secondaryGradeD => 'साफ़ भीड़ या अंतराल';

  @override
  String get secondaryGradeF => 'बहुत असमान — चिकित्सकीय जाँच';

  @override
  String get secondaryTeethAdvice =>
      'इलाज चाहिए या नहीं, दंत चिकित्सक बता सकते हैं।';

  @override
  String get secondaryNotADiagnosis => 'प्रयोगात्मक लेबल। निदान नहीं है।';
}

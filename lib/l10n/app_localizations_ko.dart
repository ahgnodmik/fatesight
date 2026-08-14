// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '페이트사이트';

  @override
  String get fortuneStory => '운명의 이야기';

  @override
  String get serviceDescription => '생년월일시를 바탕으로 한 사주를 통해 개인화된 운명의 이야기를 들려드립니다';

  @override
  String get listenToStories => '이야기 들으러 가기';

  @override
  String get recentStory => '최근 이야기';

  @override
  String get viewAgain => '다시 보기';

  @override
  String get analyzingDestiny => '운명 분석 중';

  @override
  String get pleaseWait => '운명을 분석하는 동안 잠시만 기다려주세요...';

  @override
  String get enterName => '이름 입력';

  @override
  String get birthDate => '생년월일';

  @override
  String get birthTime => '생년월일시';

  @override
  String get question => '궁금한 것';

  @override
  String get nameHint => '이름을 입력하세요';

  @override
  String get questionHint => '궁금한 것을 자유롭게 입력해주세요';

  @override
  String get getFortuneStory => '운명의 이야기 듣기';

  @override
  String get tarotTitle => '타로카드';

  @override
  String get dragToSelectCard => '카드를 드래그하여 선택하세요';

  @override
  String get checkFortune => '운세 확인';

  @override
  String get selectCard => '카드 선택';

  @override
  String get drawAgain => '다시 뽑기';

  @override
  String get home => '홈';

  @override
  String get selectionComplete => '선택 완료';

  @override
  String get selectedCard => '선택된 카드';

  @override
  String get checkFortuneText => '운세를 확인하세요';

  @override
  String get tapToConfirm => '확인하려면 탭하세요';

  @override
  String cardSelection(int current, int total) {
    return '카드 $current/$total';
  }
}

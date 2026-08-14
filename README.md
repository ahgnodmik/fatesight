# Fatesight - 사주 스토리텔러

Fatesight는 이름과 생년월일시를 입력하면 GPT를 통해 사주 기반의 아름다운 운명 이야기를 들려주는 앱입니다.

## 주요 기능

- 🌟 **사주 기반 스토리 생성**: GPT API를 사용한 개인화된 운명 이야기
- 🌍 **다국어 지원**: 한국어/영어 지원
- 📱 **모던한 UI**: shadcn/ui 스타일의 깔끔한 디자인
- 📊 **광고 통합**: AdMob 배너 및 전면 광고
- 🔄 **실시간 생성**: OpenAI GPT API 연동

## 설정 방법

### 1. OpenAI API 키 설정

프로젝트 루트에 `.env` 파일을 생성하고 다음 내용을 추가하세요:

```env
# OpenAI API Key
OPENAI_API_KEY=your_openai_api_key_here

# OpenAI Model (optional, defaults to gpt-4o-mini)
OPENAI_MODEL=gpt-4o-mini

# AdMob Unit IDs (Test IDs)
ADMOB_BANNER_ID=ca-app-pub-3940256099942544/6300978111
ADMOB_INTERSTITIAL_ID=ca-app-pub-3940256099942544/1033173712
ADMOB_APP_ID=ca-app-pub-3940256099942544~3347511713
```

### 2. OpenAI API 키 발급

1. [OpenAI Platform](https://platform.openai.com/api-keys)에 접속
2. 계정 생성 또는 로그인
3. API 키 생성
4. 생성된 키를 `.env` 파일에 추가

### 3. 앱 실행

```bash
flutter pub get
flutter run
```

## 사용법

1. **이름 입력**: 사용자의 이름을 입력
2. **생년월일 선택**: 생년월일을 선택
3. **생년월일시 선택**: 태어난 시간을 선택
4. **궁금한 것 입력**: 궁금한 점을 자유롭게 입력 (예: 연애운, 직장운, 건강운 등)
5. **운명의 이야기 듣기**: 버튼을 눌러 GPT가 생성한 사주 기반 스토리 확인

## 기술 스택

- **Flutter**: 크로스 플랫폼 앱 개발
- **OpenAI GPT API**: AI 기반 스토리 생성
- **Google Fonts**: 한글 폰트 지원
- **AdMob**: 광고 수익화
- **Provider**: 상태 관리
- **SharedPreferences**: 언어 설정 저장

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

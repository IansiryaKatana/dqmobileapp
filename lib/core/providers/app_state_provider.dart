import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUser {
  const AppUser({required this.name, required this.email, this.id});

  final String name;
  final String email;
  final String? id;
}

class AppState {
  const AppState({
    this.isDark = false,
    this.language = 'English',
    this.user,
    this.onboardingComplete = false,
    this.permissionsPromptComplete = false,
  });

  final bool isDark;
  final String language;
  final AppUser? user;
  final bool onboardingComplete;
  final bool permissionsPromptComplete;

  AppState copyWith({
    bool? isDark,
    String? language,
    AppUser? user,
    bool clearUser = false,
    bool? onboardingComplete,
    bool? permissionsPromptComplete,
  }) {
    return AppState(
      isDark: isDark ?? this.isDark,
      language: language ?? this.language,
      user: clearUser ? null : (user ?? this.user),
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      permissionsPromptComplete: permissionsPromptComplete ?? this.permissionsPromptComplete,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState()) {
    _load();
  }

  static const _onboardingKey = 'onboarding_complete';
  static const _permissionsKey = 'permissions_prompt_complete';
  static const _darkKey = 'dark_mode';
  static const _languageKey = 'language';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      onboardingComplete: prefs.getBool(_onboardingKey) ?? false,
      permissionsPromptComplete: prefs.getBool(_permissionsKey) ?? false,
      isDark: prefs.getBool(_darkKey) ?? false,
      language: prefs.getString(_languageKey) ?? 'English',
    );
  }

  Future<void> toggleDark() async {
    await setDark(!state.isDark);
  }

  Future<void> setDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, isDark);
    state = state.copyWith(isDark: isDark);
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
    state = state.copyWith(language: language);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> completePermissionsPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsKey, true);
    state = state.copyWith(permissionsPromptComplete: true);
  }

  void login(AppUser user) => state = state.copyWith(user: user);
  void logout() => state = state.copyWith(clearUser: true);

  AppUser? get currentUser => state.user;
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>(
  (ref) => AppStateNotifier(),
);

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for persisting game state locally.
/// All keys are prefixed with "eg_" to avoid collisions.
class StorageService {
  static const _keyMoney          = 'eg_money';
  static const _keyPurchased      = 'eg_purchased';
  static const _keyCompleted      = 'eg_completed';
  static const _keyQuizAnswered   = 'eg_quiz_answered';
  static const _keyFirstName      = 'eg_first_name';
  static const _keyLastName       = 'eg_last_name';
  static const _keyGender         = 'eg_gender';
  static const _keyReadPlans      = 'eg_read_plans';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Money ──────────────────────────────────────────────────────────────────

  int getMoney() => _prefs.getInt(_keyMoney) ?? 10000; // start with 10 000 UZS

  Future<void> saveMoney(int amount) => _prefs.setInt(_keyMoney, amount);

  // ── Purchased item IDs ─────────────────────────────────────────────────────

  List<String> getPurchasedItems() =>
      _prefs.getStringList(_keyPurchased) ?? [];

  Future<void> savePurchasedItems(List<String> ids) =>
      _prefs.setStringList(_keyPurchased, ids);

  // ── Completed lesson IDs ───────────────────────────────────────────────────

  List<String> getCompletedLessons() =>
      _prefs.getStringList(_keyCompleted) ?? [];

  Future<void> saveCompletedLessons(List<String> ids) =>
      _prefs.setStringList(_keyCompleted, ids);

  // ── Answered quiz question IDs ─────────────────────────────────────────────

  List<String> getAnsweredQuestions() =>
      _prefs.getStringList(_keyQuizAnswered) ?? [];

  Future<void> saveAnsweredQuestions(List<String> ids) =>
      _prefs.setStringList(_keyQuizAnswered, ids);

  // ── Read lesson plan IDs ──────────────────────────────────────────────────

  List<String> getReadPlans() => _prefs.getStringList(_keyReadPlans) ?? [];

  Future<void> saveReadPlans(List<String> ids) =>
      _prefs.setStringList(_keyReadPlans, ids);

  // ── Student profile ───────────────────────────────────────────────────────

  String getFirstName() => _prefs.getString(_keyFirstName) ?? '';
  String getLastName()  => _prefs.getString(_keyLastName) ?? '';
  String? getGender()   => _prefs.getString(_keyGender);

  Future<void> saveProfile(String firstName, String lastName, String gender) async {
    await _prefs.setString(_keyFirstName, firstName);
    await _prefs.setString(_keyLastName, lastName);
    await _prefs.setString(_keyGender, gender);
  }

  // ── Full reset (for testing / restart) ────────────────────────────────────

  Future<void> resetAll() async {
    await _prefs.remove(_keyMoney);
    await _prefs.remove(_keyPurchased);
    await _prefs.remove(_keyCompleted);
    await _prefs.remove(_keyQuizAnswered);
    await _prefs.remove(_keyReadPlans);
    // The child's name and avatar deliberately survive a progress reset.
  }
}

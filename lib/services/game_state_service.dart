import 'package:flutter/foundation.dart';
import '../models/lesson.dart';
import '../models/quiz_question.dart';
import '../models/shop_item.dart';
import '../data/lessons_data.dart';
import '../data/quiz_data.dart';
import '../data/shop_data.dart';
import 'storage_service.dart';

/// Central game state — single source of truth, exposed via ChangeNotifier.
class GameStateService extends ChangeNotifier {
  final StorageService _storage = StorageService();

  int _money = 10000;
  List<Lesson> _lessons = [];
  List<QuizQuestion> _questions = [];
  List<ShopItem> _shopItems = [];
  Set<String> _purchasedIds = {};
  Set<String> _completedLessonIds = {};
  Set<String> _answeredQuestionIds = {};

  // ── Getters ──────────────────────────────────────────────────────────────────
  int get money => _money;
  List<Lesson> get lessons => List.unmodifiable(_lessons);
  List<QuizQuestion> get questions => List.unmodifiable(_questions);
  List<ShopItem> get shopItems => List.unmodifiable(_shopItems);
  Set<String> get purchasedIds => Set.unmodifiable(_purchasedIds);
  Set<String> get completedLessonIds => Set.unmodifiable(_completedLessonIds);
  Set<String> get answeredQuestionIds => Set.unmodifiable(_answeredQuestionIds);

  // ── Shop unlock logic ────────────────────────────────────────────────────────
  int get ehtiyojPurchased => _shopItems
      .where((i) => i.section == ShopSection.ehtiyoj && _purchasedIds.contains(i.id))
      .length;

  int get hohishPurchased => _shopItems
      .where((i) => i.section == ShopSection.hohish && _purchasedIds.contains(i.id))
      .length;

  int get orzuPurchased => _shopItems
      .where((i) => i.section == ShopSection.orzu && _purchasedIds.contains(i.id))
      .length;

  bool get isHohishUnlocked => ehtiyojPurchased >= ShopRules.ehtiyojToUnlockHohish;
  bool get isOrzuUnlocked => hohishPurchased >= ShopRules.hohishToUnlockOrzu;
  bool get canBuyOrzu => orzuPurchased < ShopRules.orzuMaxPurchases;

  // ── Init ─────────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await _storage.init();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    _money = _storage.getMoney();
    _purchasedIds = _storage.getPurchasedItems().toSet();
    _completedLessonIds = _storage.getCompletedLessons().toSet();
    _answeredQuestionIds = _storage.getAnsweredQuestions().toSet();

    _lessons = buildLessons().map((l) {
      return l.copyWith(isCompleted: _completedLessonIds.contains(l.id));
    }).toList();

    _questions = buildQuizQuestions();

    _shopItems = buildShopItems().map((item) {
      return item.copyWith(isPurchased: _purchasedIds.contains(item.id));
    }).toList();
  }

  // ── Money ────────────────────────────────────────────────────────────────────
  Future<void> addMoney(int amount) async {
    _money += amount;
    await _storage.saveMoney(_money);
    notifyListeners();
  }

  Future<bool> spendMoney(int amount) async {
    if (_money < amount) return false;
    _money -= amount;
    await _storage.saveMoney(_money);
    notifyListeners();
    return true;
  }

  // ── Lessons ──────────────────────────────────────────────────────────────────
  Future<void> completeLesson(String lessonId) async {
    if (_completedLessonIds.contains(lessonId)) return;
    _completedLessonIds.add(lessonId);
    final idx = _lessons.indexWhere((l) => l.id == lessonId);
    if (idx != -1) _lessons[idx] = _lessons[idx].copyWith(isCompleted: true);
    await _storage.saveCompletedLessons(_completedLessonIds.toList());
    notifyListeners();
  }

  // ── Quiz ─────────────────────────────────────────────────────────────────────
  Future<void> markQuestionAnswered(String questionId) async {
    _answeredQuestionIds.add(questionId);
    await _storage.saveAnsweredQuestions(_answeredQuestionIds.toList());
    notifyListeners();
  }

  // ── Shop ─────────────────────────────────────────────────────────────────────
  Future<bool> purchaseItem(String itemId) async {
    final idx = _shopItems.indexWhere((i) => i.id == itemId);
    if (idx == -1) return false;
    final item = _shopItems[idx];
    if (item.isPurchased) return false;
    if (item.section == ShopSection.orzu && !canBuyOrzu) return false;
    final success = await spendMoney(item.price);
    if (!success) return false;
    _purchasedIds.add(itemId);
    _shopItems[idx] = item.copyWith(isPurchased: true);
    await _storage.savePurchasedItems(_purchasedIds.toList());
    notifyListeners();
    return true;
  }

  // ── Reset ─────────────────────────────────────────────────────────────────────
  /// Clears all saved progress and resets in-memory state immediately.
  Future<void> resetGame() async {
    await _storage.resetAll();
    // Reset in-memory state directly (don't re-read from storage to avoid
    // timing issues with SharedPreferences singleton cache)
    _money = 10000;
    _purchasedIds = {};
    _completedLessonIds = {};
    _answeredQuestionIds = {};
    _lessons = buildLessons();
    _questions = buildQuizQuestions();
    _shopItems = buildShopItems();
    notifyListeners();
  }
}

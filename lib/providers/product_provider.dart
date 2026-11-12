import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product.dart';
import '../services/api_service.dart';

enum LoadStatus { idle, loading, ready, error }

/// Single source of truth for catalogue data.
///
/// Holds the fetched products, the current search text, the active category
/// filter and the persisted favourites list. Every screen listens to this.
class ProductProvider extends ChangeNotifier {
  ProductProvider({ApiService? api}) : _api = api ?? ApiService();

  static const String _kFavourites = 'products.favourites';
  static const String _kCache = 'products.cache';

  final ApiService _api;

  LoadStatus _status = LoadStatus.idle;
  String? _error;
  bool _fromCache = false;
  List<Product> _products = const <Product>[];
  String _query = '';
  String? _category;
  Set<int> _favourites = <int>{};

  LoadStatus get status => _status;
  String? get error => _error;
  /// True when the list came from the on-device cache instead of the network.
  bool get isShowingCachedData => _fromCache;
  String get query => _query;
  String? get category => _category;
  int get favouriteCount => _favourites.length;
  int get productCount => _products.length;

  List<String> get categories {
    final Set<String> unique =
        _products.map((Product p) => p.category).toSet();
    final List<String> sorted = unique.toList()..sort();
    return sorted;
  }

  /// Search + category filter applied together.
  List<Product> get visibleProducts {
    return _products.where((Product p) {
      final bool matchesQuery = p.matches(_query);
      final bool matchesCategory = _category == null || p.category == _category;
      return matchesQuery && matchesCategory;
    }).toList(growable: false);
  }

  List<Product> get favouriteProducts => _products
      .where((Product p) => _favourites.contains(p.id))
      .toList(growable: false);

  /// First five items, used by the home dashboard.
  List<Product> get highlights => _products.take(5).toList(growable: false);

  bool isFavourite(int id) => _favourites.contains(id);

  Future<void> load({bool force = false}) async {
    if (_status == LoadStatus.loading) return;
    if (_status == LoadStatus.ready && !force) return;

    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _products = await _api.fetchProducts();
      _fromCache = false;
      await _saveCache();
      await _restoreFavourites();
      _status = LoadStatus.ready;
    } on ApiException catch (e) {
      // Offline fallback: a cached list beats an error screen.
      final List<Product> cached = await _readCache();
      if (cached.isEmpty) {
        _error = e.message;
        _status = LoadStatus.error;
      } else {
        _products = cached;
        _fromCache = true;
        await _restoreFavourites();
        _status = LoadStatus.ready;
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> retry() => load(force: true);

  void search(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void selectCategory(String? value) {
    if (_category == value) return;
    _category = value;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _category = null;
    notifyListeners();
  }

  Future<void> toggleFavourite(int id) async {
    if (_favourites.contains(id)) {
      _favourites.remove(id);
    } else {
      _favourites.add(id);
    }
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kFavourites,
      _favourites.map((int value) => value.toString()).toList(),
    );
  }

  Future<void> _restoreFavourites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_kFavourites);
    _favourites = saved == null
        ? <int>{}
        : saved.map(int.tryParse).whereType<int>().toSet();
  }

  Future<void> _saveCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String payload = jsonEncode(
      _products.map((Product p) => p.toJson()).toList(growable: false),
    );
    await prefs.setString(_kCache, payload);
  }

  Future<List<Product>> _readCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? payload = prefs.getString(_kCache);
    if (payload == null || payload.isEmpty) return const <Product>[];

    try {
      final Object? decoded = jsonDecode(payload);
      if (decoded is! List) return const <Product>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const <Product>[];
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }
}

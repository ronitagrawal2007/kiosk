import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Thrown for every failure the UI should show to the user.
/// Keeping one exception type means screens never deal with raw errors.
class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Talks to the public FakeStore API.
///
/// Task 4 of the assignment needs: real data, loading, error and empty states.
/// Each of those is handled here or in [ProductProvider].
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://fakestoreapi.com';

  Future<List<Product>> fetchProducts() async {
    try {
      final http.Response response = await _client
          .get(Uri.parse('$_baseUrl/products'))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ApiException(
          'The store is unavailable right now (HTTP ${response.statusCode}).',
        );
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw ApiException('Unexpected response from the store.');
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Could not reach the store.\nCheck your internet connection and retry.',
      );
    }
  }

  void dispose() => _client.close();
}

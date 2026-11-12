import 'package:flutter_test/flutter_test.dart';
import 'package:kiosk/models/product.dart';
import 'package:kiosk/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects an empty value', () {
      expect(Validators.email(''), isNotNull);
    });

    test('rejects a malformed address', () {
      expect(Validators.email('ronit@'), isNotNull);
      expect(Validators.email('ronit.example.com'), isNotNull);
    });

    test('accepts a normal address', () {
      expect(Validators.email('ronitagrawal27@gmail.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires at least six characters', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('must match the original password', () {
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
      expect(Validators.confirmPassword('abc124', 'abc123'), isNotNull);
    });
  });

  group('Product.fromJson', () {
    final Map<String, dynamic> json = <String, dynamic>{
      'id': 3,
      'title': 'Mens Cotton Jacket',
      'price': 55.99,
      'description': 'great outerwear',
      'category': "men's clothing",
      'image': 'https://example.com/jacket.png',
      'rating': <String, dynamic>{'rate': 4.7, 'count': 500},
    };

    test('maps every field', () {
      final Product product = Product.fromJson(json);

      expect(product.id, 3);
      expect(product.title, 'Mens Cotton Jacket');
      expect(product.price, 55.99);
      expect(product.category, "men's clothing");
      expect(product.rating, 4.7);
      expect(product.ratingCount, 500);
    });

    test('survives missing rating data', () {
      final Product product = Product.fromJson(<String, dynamic>{
        'id': 1,
        'title': 'Fallback',
        'price': 10,
      });

      expect(product.rating, 0);
      expect(product.ratingCount, 0);
      expect(product.category, 'misc');
    });

    test('search matches title, category and description', () {
      final Product product = Product.fromJson(json);

      expect(product.matches('jacket'), isTrue);
      expect(product.matches('clothing'), isTrue);
      expect(product.matches('outerwear'), isTrue);
      expect(product.matches('shoes'), isFalse);
    });
  });
}

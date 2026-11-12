import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kiosk/providers/product_provider.dart';
import 'package:kiosk/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _json = '['
    '{"id":1,"title":"Cotton Jacket","price":55.99,"description":"warm layer",'
    '"category":"men\'s clothing","image":"https://example.com/1.png",'
    '"rating":{"rate":4.5,"count":10}},'
    '{"id":2,"title":"Gold Ring","price":695.0,"description":"daily wear",'
    '"category":"jewellery","image":"https://example.com/2.png",'
    '"rating":{"rate":4.1,"count":22}}'
    ']';

ApiService _okService() => ApiService(
      client: MockClient((_) async => http.Response(_json, 200)),
    );

void main() {
  test('cold start restores persisted favourites', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'products.favourites': <String>['1', '2'],
    });
    final ProductProvider provider = ProductProvider(api: _okService());

    await provider.load();

    print('after load -> count=${provider.favouriteCount} '
        'list=${provider.favouriteProducts.map((p) => p.title).toList()}');
    expect(provider.favouriteCount, 2);
    expect(provider.favouriteProducts.length, 2);
  });

  test('toggling on top of restored favourites keeps count and list in sync',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'products.favourites': <String>['2'],
    });
    final ProductProvider provider = ProductProvider(api: _okService());
    await provider.load();

    await provider.toggleFavourite(1);

    print('after toggle -> count=${provider.favouriteCount} '
        'list=${provider.favouriteProducts.map((p) => p.title).toList()} '
        'isFav1=${provider.isFavourite(1)} isFav2=${provider.isFavourite(2)}');
    expect(provider.favouriteCount, 2);
    expect(provider.favouriteProducts.length, 2);
    expect(provider.isFavourite(1), isTrue);
    expect(provider.isFavourite(2), isTrue);
  });

  test('a second provider instance sees the same favourites after a save',
      () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ProductProvider first = ProductProvider(api: _okService());
    await first.load();
    await first.toggleFavourite(1);

    final ProductProvider second = ProductProvider(api: _okService());
    await second.load();

    print('second instance -> count=${second.favouriteCount} '
        'list=${second.favouriteProducts.map((p) => p.title).toList()}');
    expect(second.favouriteCount, 1);
    expect(second.favouriteProducts.length, 1);
  });
}

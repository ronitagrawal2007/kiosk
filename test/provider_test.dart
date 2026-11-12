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

ApiService _failingService() => ApiService(
      client: MockClient((_) async => http.Response('server down', 500)),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('loads products from the API', () async {
    final ProductProvider provider = ProductProvider(api: _okService());

    await provider.load();

    expect(provider.status, LoadStatus.ready);
    expect(provider.productCount, 2);
    expect(provider.isShowingCachedData, isFalse);
    expect(provider.categories, <String>['jewellery', "men's clothing"]);
  });

  test('falls back to the cache when the network fails', () async {
    final ProductProvider online = ProductProvider(api: _okService());
    await online.load();

    final ProductProvider offline = ProductProvider(api: _failingService());
    await offline.load();

    expect(offline.status, LoadStatus.ready);
    expect(offline.isShowingCachedData, isTrue);
    expect(offline.productCount, 2);
  });

  test('reports an error when there is no cache to fall back to', () async {
    final ProductProvider provider = ProductProvider(api: _failingService());

    await provider.load();

    expect(provider.status, LoadStatus.error);
    expect(provider.error, isNotNull);
  });

  test('search and category filters work together', () async {
    final ProductProvider provider = ProductProvider(api: _okService());
    await provider.load();

    provider.search('jacket');
    expect(provider.visibleProducts.length, 1);

    provider.selectCategory('jewellery');
    expect(provider.visibleProducts, isEmpty);

    provider.clearFilters();
    expect(provider.visibleProducts.length, 2);
  });

  test('favourites survive a reload', () async {
    final ProductProvider provider = ProductProvider(api: _okService());
    await provider.load();
    await provider.toggleFavourite(2);

    expect(provider.favouriteCount, 1);
    expect(provider.isFavourite(2), isTrue);
  });
}

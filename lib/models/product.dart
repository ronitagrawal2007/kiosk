/// A single item in the catalogue.
///
/// The shape mirrors the JSON returned by https://fakestoreapi.com/products
/// so that [Product.fromJson] stays a one-to-one mapping.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
    required this.ratingCount,
  });

  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double rating;
  final int ratingCount;

  factory Product.fromJson(Map<String, dynamic> json) {
    final Object? ratingJson = json['rating'];
    final Map<String, dynamic> ratingMap =
        ratingJson is Map<String, dynamic> ? ratingJson : const <String, dynamic>{};

    return Product(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? 'Untitled',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: (json['description'] as String?)?.trim() ?? '',
      category: (json['category'] as String?)?.trim() ?? 'misc',
      image: (json['image'] as String?) ?? '',
      rating: (ratingMap['rate'] as num?)?.toDouble() ?? 0,
      ratingCount: (ratingMap['count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Round-trips back to JSON so the list can be cached for offline use.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'price': price,
        'description': description,
        'category': category,
        'image': image,
        'rating': <String, dynamic>{'rate': rating, 'count': ratingCount},
      };

  /// Used by the search field.
  bool matches(String query) {
    if (query.isEmpty) return true;
    final String q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q);
  }

  String get priceLabel => '₹${price.toStringAsFixed(2)}';

  String get ratingLabel => rating.toStringAsFixed(1);
}

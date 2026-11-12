import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'details_screen.dart';

/// Shows the products the user saved. Favourites survive app restarts
/// because they are written to SharedPreferences.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ProductProvider catalogue = context.watch<ProductProvider>();
    final List<Product> saved = catalogue.favouriteProducts;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: switch (catalogue.status) {
        LoadStatus.loading || LoadStatus.idle =>
          const LoadingView(label: 'Fetching products…'),
        LoadStatus.error => ErrorView(
            message: catalogue.error ?? 'Something went wrong.',
            onRetry: catalogue.retry,
          ),
        LoadStatus.ready => saved.isEmpty
            ? const EmptyView(
                icon: Icons.favorite_border_rounded,
                title: 'Nothing saved yet',
                subtitle:
                    'Tap the heart on any product to keep it here, even after '
                    'you close the app.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: saved.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final Product product = saved[index];
                  return ProductTile(
                    product: product,
                    isFavourite: true,
                    onFavourite: () => catalogue.toggleFavourite(product.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DetailsScreen(product: product),
                      ),
                    ),
                  );
                },
              ),
      },
    );
  }
}

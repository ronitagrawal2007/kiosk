import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';

/// Full detail for one product.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ProductProvider catalogue = context.watch<ProductProvider>();
    final bool isFavourite = catalogue.isFavourite(product.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.category,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await catalogue.toggleFavourite(product.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      catalogue.isFavourite(product.id)
                          ? 'Saved to favourites'
                          : 'Removed from favourites',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
            icon: Icon(
              isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavourite ? theme.colorScheme.error : null,
            ),
            tooltip: isFavourite ? 'Remove from favourites' : 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: <Widget>[
          Container(
            height: 260,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Hero(
              tag: 'product-image-${product.id}',
              child: Image.network(
                product.image,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            product.title,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Text(
                product.priceLabel,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6DC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.star_rounded,
                        size: 16, color: Color(0xFFE0A800)),
                    const SizedBox(width: 4),
                    Text(
                      '${product.ratingLabel} (${product.ratingCount})',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'About this item',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            product.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () async {
              await catalogue.toggleFavourite(product.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      catalogue.isFavourite(product.id)
                          ? 'Saved to favourites'
                          : 'Removed from favourites',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
            icon: Icon(
              isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
            ),
            label: Text(isFavourite ? 'Saved' : 'Save for later'),
          ),
        ],
      ),
    );
  }
}

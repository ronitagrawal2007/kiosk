import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'details_screen.dart';

/// Searchable, filterable catalogue list (Task 2 + Task 3).
class ListingTab extends StatefulWidget {
  const ListingTab({super.key});

  @override
  State<ListingTab> createState() => _ListingTabState();
}

class _ListingTabState extends State<ListingTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProductProvider catalogue = context.watch<ProductProvider>();
    final List<Product> products = catalogue.visibleProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: <Widget>[
          if (catalogue.query.isNotEmpty || catalogue.category != null)
            IconButton(
              onPressed: () {
                _searchController.clear();
                catalogue.clearFilters();
              },
              icon: const Icon(Icons.filter_alt_off_rounded),
              tooltip: 'Clear filters',
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: catalogue.search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: catalogue.query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          catalogue.search('');
                        },
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear search',
                      ),
              ),
            ),
          ),
          if (catalogue.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('All'),
                      selected: catalogue.category == null,
                      onSelected: (_) => catalogue.selectCategory(null),
                    ),
                  ),
                  ...catalogue.categories.map((String category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: catalogue.category == category,
                        onSelected: (bool selected) =>
                            catalogue.selectCategory(selected ? category : null),
                      ),
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (catalogue.isShowingCachedData)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: OfflineBanner(),
            ),
          Expanded(
            child: switch (catalogue.status) {
              LoadStatus.loading || LoadStatus.idle =>
                const LoadingView(label: 'Fetching products…'),
              LoadStatus.error => ErrorView(
                  message: catalogue.error ?? 'Something went wrong.',
                  onRetry: catalogue.retry,
                ),
              LoadStatus.ready => products.isEmpty
                  ? EmptyView(
                      title: 'Nothing matched',
                      subtitle:
                          'No product matches your search or filter. Try '
                          'different keywords.',
                      action: FilledButton.tonalIcon(
                        onPressed: () {
                          _searchController.clear();
                          catalogue.clearFilters();
                        },
                        icon: const Icon(Icons.restart_alt_rounded),
                        label: const Text('Reset filters'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => catalogue.load(force: true),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: products.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final Product product = products[index];
                          return ProductTile(
                            product: product,
                            isFavourite: catalogue.isFavourite(product.id),
                            onFavourite: () =>
                                catalogue.toggleFavourite(product.id),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DetailsScreen(product: product),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'details_screen.dart';

/// Dashboard: greeting, quick stats, categories and a short "recent" strip.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AuthProvider auth = context.watch<AuthProvider>();
    final ProductProvider catalogue = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiosk'),
        actions: <Widget>[
          IconButton(
            onPressed: () => catalogue.load(force: true),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh catalogue',
          ),
        ],
      ),
      body: switch (catalogue.status) {
        LoadStatus.loading || LoadStatus.idle =>
          const LoadingView(label: 'Fetching products…'),
        LoadStatus.error => ErrorView(
            message: catalogue.error ?? 'Something went wrong.',
            onRetry: catalogue.retry,
          ),
        LoadStatus.ready => RefreshIndicator(
            onRefresh: () => catalogue.load(force: true),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: <Widget>[
                if (catalogue.isShowingCachedData) ...<Widget>[
                  const OfflineBanner(),
                  const SizedBox(height: 12),
                ],
                _GreetingCard(name: auth.name),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    _StatCard(
                      label: 'Products',
                      value: '${catalogue.productCount}',
                      icon: Icons.inventory_2_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Categories',
                      value: '${catalogue.categories.length}',
                      icon: Icons.category_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'Saved',
                      value: '${catalogue.favouriteCount}',
                      icon: Icons.favorite_border_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Shop by category',
                  actionLabel: 'See all',
                  onAction: onBrowse,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: catalogue.categories.map((String category) {
                    return ActionChip(
                      label: Text(_titleCase(category)),
                      onPressed: () {
                        catalogue.selectCategory(category);
                        catalogue.search('');
                        onBrowse();
                      },
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Recently added',
                  actionLabel: 'Browse',
                  onAction: onBrowse,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 176,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: catalogue.highlights.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (BuildContext context, int index) {
                      final product = catalogue.highlights[index];
                      return ProductMiniCard(
                        product: product,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => DetailsScreen(product: product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Built for Sankar Group',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'The same listing + details architecture maps straight '
                          'onto Aasthi — swap the product model for a property '
                          'model and the search layer stays identical.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      },
    );
  }

  String _titleCase(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Hello, $name',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: scheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Everything in one small catalogue.',
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.storefront_rounded,
            size: 44,
            color: scheme.onPrimary.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

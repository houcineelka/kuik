import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../data/listings_repository.dart';
import '../models/categories.dart';
import '../providers/listings_search_controller.dart';
import '../widgets/listing_card.dart';

class ListingsListScreen extends ConsumerStatefulWidget {
  const ListingsListScreen({super.key});

  @override
  ConsumerState<ListingsListScreen> createState() => _ListingsListScreenState();
}

class _ListingsListScreenState extends ConsumerState<ListingsListScreen> {
  final _scrollController = ScrollController();
  final _cityController = TextEditingController();
  final _keywordController = TextEditingController();
  String? _type;
  String? _category;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels > _scrollController.position.maxScrollExtent - 200) {
      ref.read(listingsSearchControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _cityController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(listingsSearchControllerProvider.notifier).applyFilters(
          ListingSearchFilters(
            type: _type,
            category: _category,
            city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
            keyword: _keywordController.text.trim().isEmpty ? null : _keywordController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final state = ref.watch(listingsSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.listingsSearchAppBarTitle)),
      body: Column(
        children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(LedgerSpacing.lg, LedgerSpacing.md, LedgerSpacing.lg, 0),
          child: TextField(
            controller: _keywordController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _applyFilters(),
            decoration: InputDecoration(
              hintText: l10n.listingsSearchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(icon: const Icon(Icons.tune), onPressed: _applyFilters),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(LedgerSpacing.lg, LedgerSpacing.sm, LedgerSpacing.lg, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(l10n.listingsFilterAll),
                  selected: _type == null,
                  onSelected: (_) => setState(() {
                    _type = null;
                    _applyFilters();
                  }),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                ChoiceChip(
                  label: Text(l10n.statusLost),
                  selected: _type == 'lost',
                  onSelected: (_) => setState(() {
                    _type = 'lost';
                    _applyFilters();
                  }),
                ),
                const SizedBox(width: LedgerSpacing.sm),
                ChoiceChip(
                  label: Text(l10n.statusFound),
                  selected: _type == 'found',
                  onSelected: (_) => setState(() {
                    _type = 'found';
                    _applyFilters();
                  }),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(LedgerSpacing.lg, LedgerSpacing.md, LedgerSpacing.lg, 0),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  initialValue: _category,
                  isDense: true,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.fieldCategoryLabel),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.listingsFilterCategoryAll)),
                    for (final category in listingCategories)
                      DropdownMenuItem(value: category, child: Text(categoryLabel(l10n, category), overflow: TextOverflow.ellipsis)),
                  ],
                  onChanged: (value) => setState(() {
                    _category = value;
                    _applyFilters();
                  }),
                ),
              ),
              const SizedBox(width: LedgerSpacing.md),
              Expanded(
                child: TextField(
                  controller: _cityController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _applyFilters(),
                  decoration: InputDecoration(labelText: l10n.fieldCityLabel),
                ),
              ),
            ],
          ),
        ),
        if (state.isOffline)
          Container(
            width: double.infinity,
            color: scheme.errorContainer,
            padding: const EdgeInsets.symmetric(horizontal: LedgerSpacing.lg, vertical: LedgerSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.cloud_off, size: 16, color: scheme.onErrorContainer),
                const SizedBox(width: LedgerSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.listingsOfflineBanner,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(listingsSearchControllerProvider.notifier).refresh(),
            child: state.isLoading && state.listings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.listings.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 120),
                          Center(child: Text(l10n.listingsEmptyState)),
                        ],
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(LedgerSpacing.lg),
                        itemCount: state.listings.length + (state.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) => const SizedBox(height: LedgerSpacing.md),
                        itemBuilder: (context, index) {
                          if (index >= state.listings.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: LedgerSpacing.lg),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final listing = state.listings[index];
                          return ListingCard(
                            listing: listing,
                            onTap: () => context.push('/listings/${listing.id}'),
                          );
                        },
                      ),
          ),
        ),
        ],
      ),
    );
  }
}

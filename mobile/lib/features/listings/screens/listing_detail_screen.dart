import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/shared/spark_accent.dart';
import '../../auth/providers/auth_providers.dart';
import '../models/categories.dart';
import '../models/category_icons.dart';
import '../models/listing.dart';
import '../providers/bookmarks_provider.dart';
import '../providers/listings_providers.dart';
import '../providers/my_listings_provider.dart';
import '../providers/nearby_listings_provider.dart';
import '../providers/saved_listings_provider.dart';
import '../widgets/photo_viewer_screen.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});

  final int listingId;

  @override
  ConsumerState<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  Listing? _listing;
  bool _loading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final listing = await ref.read(listingsRepositoryProvider).show(widget.listingId);
      if (!mounted) return;
      setState(() => _listing = listing);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _loadError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openClaimSheet(Listing listing) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _FoundClaimSheet(listing: listing),
    );
  }

  Future<void> _delete(Listing listing) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.deleteCancelButton)),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.deleteConfirmButton, style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(listingsRepositoryProvider).delete(listing.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;
    ref.invalidate(myListingsProvider);
    ref.invalidate(nearbyListingsProvider);
    ref.invalidate(savedListingsProvider);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.deleteSuccessSnackbar)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_loadError != null || _listing == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(LedgerSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError ?? l10n.listingDetailNotFound),
                const SizedBox(height: LedgerSpacing.md),
                OutlinedButton(onPressed: _load, child: Text(l10n.commonRetry)),
              ],
            ),
          ),
        ),
      );
    }

    final listing = _listing!;
    final currentUser = ref.watch(authControllerProvider).valueOrNull;
    final isOwner = currentUser != null && currentUser.id == listing.userId;
    final isBookmarked = ref.watch(bookmarksControllerProvider).valueOrNull?.contains(listing.id) ?? false;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(LedgerSpacing.xl, LedgerSpacing.md, LedgerSpacing.xl, LedgerSpacing.xxxl),
          children: [
            _DetailHeader(
              onBack: () => Navigator.of(context).pop(),
              onShare: () => _share(listing),
              isBookmarked: isBookmarked,
              onToggleBookmark: () => ref.read(bookmarksControllerProvider.notifier).toggle(listing.id),
              isOwner: isOwner,
              onDelete: () => _delete(listing),
            ),
            const SizedBox(height: LedgerSpacing.xl),
            _PhotoCarousel(listing: listing),
            const SizedBox(height: LedgerSpacing.lg),
            _InfoCard(listing: listing),
            const SizedBox(height: LedgerSpacing.lg),
            _LocationMap(
              latitude: listing.latitude,
              longitude: listing.longitude,
              address: _location(listing),
            ),
            const SizedBox(height: LedgerSpacing.xl),
            if (!isOwner && listing.isActive) ...[
              ElevatedButton(
                onPressed: () => _openClaimSheet(listing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(listing.isLost ? l10n.listingDetailClaimFoundButton : l10n.listingDetailClaimOwnerButton),
                    const SizedBox(width: LedgerSpacing.md),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: scheme.onPrimary,
                      child: Icon(Icons.arrow_forward, color: scheme.primary, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LedgerSpacing.lg),
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                    children: [
                      TextSpan(text: l10n.listingDetailNotYoursPrompt),
                      TextSpan(
                        text: l10n.listingDetailSeeOtherListingsLink,
                        style: TextStyle(color: scheme.secondary, fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()..onTap = () => context.push('/search'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _location(Listing listing) {
    if (listing.neighborhood != null && listing.neighborhood!.isNotEmpty) {
      return '${listing.neighborhood}, ${listing.city}';
    }
    return listing.city;
  }

  void _share(Listing listing) {
    final l10n = context.l10n;
    final status = listing.isLost ? l10n.statusLostLong : l10n.statusFoundLong;
    SharePlus.instance.share(
      ShareParams(
        text: l10n.listingDetailShareMessage(
          status,
          categoryLabel(l10n, listing.category),
          listing.description,
          _location(listing),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.onBack,
    required this.onShare,
    required this.isBookmarked,
    required this.onToggleBookmark,
    required this.isOwner,
    required this.onDelete,
  });

  final VoidCallback onBack;
  final VoidCallback onShare;
  final bool isBookmarked;
  final VoidCallback onToggleBookmark;
  final bool isOwner;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        _HeaderIconButton(icon: Icons.arrow_back, onTap: onBack, color: scheme.primary),
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Kuik',
                  style: textTheme.headlineMedium?.copyWith(color: scheme.primary, fontSize: 28),
                ),
                const SizedBox(width: 2),
                SparkAccent(size: 16, color: scheme.primary),
              ],
            ),
          ),
        ),
        if (isOwner) ...[
          _HeaderIconButton(icon: Icons.delete_outline, onTap: onDelete, color: scheme.error),
          const SizedBox(width: LedgerSpacing.sm),
        ],
        _HeaderIconButton(icon: Icons.ios_share, onTap: onShare, color: scheme.primary),
        const SizedBox(width: LedgerSpacing.sm),
        _HeaderIconButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          onTap: onToggleBookmark,
          color: scheme.primary,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap, required this.color});

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(icon, color: color),
        ),
      ),
    );
  }
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.listing});

  final Listing listing;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final photos = widget.listing.photos;
    final photoCount = photos.isEmpty ? 1 : photos.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 240,
        child: Stack(
          fit: StackFit.expand,
          children: [
            photos.isEmpty
                ? Container(
                    color: scheme.primaryContainer,
                    alignment: Alignment.center,
                    child: Icon(iconForCategory(widget.listing.category), size: 56, color: scheme.onPrimaryContainer),
                  )
                : PageView(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _index = value),
                    children: [
                      for (var i = 0; i < photos.length; i++)
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PhotoViewerScreen(
                                photoUrls: [for (final photo in photos) photo.photoUrl],
                                initialIndex: i,
                              ),
                            ),
                          ),
                          child: Image.network(
                            photos[i].photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              color: scheme.surfaceContainerHigh,
                              alignment: Alignment.center,
                              child: Icon(Icons.image_outlined, color: scheme.onSurface.withValues(alpha: 0.35)),
                            ),
                          ),
                        ),
                    ],
                  ),
            if (photos.isNotEmpty)
              Positioned(
                left: LedgerSpacing.md,
                top: LedgerSpacing.md,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.zoom_out_map, size: 16, color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              right: LedgerSpacing.md,
              bottom: LedgerSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image_outlined, size: 16, color: Colors.white),
                    const SizedBox(width: LedgerSpacing.xs),
                    Text(
                      widget.listing.isLost ? l10n.statusLostLong : l10n.statusFoundLong,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    const SizedBox(width: LedgerSpacing.sm),
                    Container(width: 1, height: 14, color: Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: LedgerSpacing.sm),
                    Text(
                      '${_index + 1}/$photoCount',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final pillColor = listing.isLost ? scheme.primaryContainer : scheme.tertiaryContainer;
    final onPillColor = listing.isLost ? scheme.onPrimaryContainer : scheme.onTertiaryContainer;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(LedgerSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: pillColor, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    listing.isLost ? l10n.statusLost : l10n.statusFound,
                    style: textTheme.labelLarge?.copyWith(color: onPillColor),
                  ),
                ),
                if (!listing.isActive) ...[
                  const SizedBox(width: LedgerSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      listing.status == 'resolved' ? l10n.listingDetailStatusResolved : l10n.listingDetailStatusExpired,
                      style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: LedgerSpacing.md),
            Text(categoryLabel(l10n, listing.category), style: textTheme.headlineMedium),
            const SizedBox(height: LedgerSpacing.xs),
            Text(
              listing.description,
              style: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            Divider(color: scheme.outlineVariant, height: 1),
            const SizedBox(height: LedgerSpacing.lg),
            Text(l10n.listingDetailInfoSectionTitle, style: textTheme.labelLarge?.copyWith(color: scheme.onSurfaceVariant)),
            const SizedBox(height: LedgerSpacing.md),
            _InfoRow(icon: Icons.place_outlined, label: _location(listing)),
            const SizedBox(height: LedgerSpacing.md),
            _InfoRow(icon: Icons.event_outlined, label: _formatDate(listing.eventDate)),
          ],
        ),
      ),
    );
  }

  String _location(Listing listing) {
    if (listing.neighborhood != null && listing.neighborhood!.isNotEmpty) {
      return '${listing.neighborhood}, ${listing.city}';
    }
    return listing.city;
  }

  String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: scheme.primaryContainer, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: LedgerSpacing.md),
        Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _LocationMap extends StatelessWidget {
  const _LocationMap({required this.latitude, required this.longitude, required this.address});

  final double latitude;
  final double longitude;
  final String address;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final point = LatLng(latitude, longitude);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 220,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.kuik.mobile',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 36,
                      height: 36,
                      child: Icon(Icons.location_on, color: scheme.primary, size: 32),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: LedgerSpacing.sm,
              top: LedgerSpacing.sm,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on, size: 14, color: scheme.secondary),
                      const SizedBox(width: 4),
                      Text(
                        address,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: scheme.secondary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Claim submission: the claimant photographs proof (camera only — a live
/// photo is the point, not a gallery pick) and adds a short description.
/// Used for both "I found this" (on a lost listing) and "this is mine" (on
/// a found listing) — the owner reviews it on the Claims screen before any
/// conversation opens.
class _FoundClaimSheet extends ConsumerStatefulWidget {
  const _FoundClaimSheet({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_FoundClaimSheet> createState() => _FoundClaimSheetState();
}

class _FoundClaimSheetState extends ConsumerState<_FoundClaimSheet> {
  final _descriptionController = TextEditingController();
  File? _photo;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1600);
    if (picked == null) return;
    setState(() => _photo = File(picked.path));
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final photo = _photo;
    if (photo == null) {
      setState(() => _error = l10n.claimPhotoMissingError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await ref.read(listingsRepositoryProvider).claimFound(
            widget.listing.id,
            photo,
            _descriptionController.text.trim(),
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.claimSubmitSuccessSnackbar)));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.firstErrorFor('description') ?? e.firstErrorFor('photo') ?? e.firstErrorFor('listing') ?? e.message;
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: LedgerSpacing.xl,
        right: LedgerSpacing.xl,
        top: LedgerSpacing.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + LedgerSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.listing.isLost ? l10n.claimSubmitTitle : l10n.claimSubmitTitleOwner, style: textTheme.titleLarge),
          const SizedBox(height: LedgerSpacing.sm),
          Text(
            widget.listing.isLost ? l10n.claimSubmitInstructions : l10n.claimSubmitInstructionsOwner,
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: LedgerSpacing.lg),
          Text(l10n.claimPhotoRequiredLabel, style: textTheme.titleSmall),
          const SizedBox(height: LedgerSpacing.sm),
          GestureDetector(
            onTap: _takePhoto,
            child: _photo == null
                ? Container(
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined, color: scheme.primary, size: 32),
                        const SizedBox(height: LedgerSpacing.sm),
                        Text(l10n.claimTakePhotoButton, style: textTheme.bodyMedium?.copyWith(color: scheme.primary)),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Image.file(_photo!, height: 160, width: double.infinity, fit: BoxFit.cover),
                        Positioned(
                          right: LedgerSpacing.sm,
                          bottom: LedgerSpacing.sm,
                          child: Material(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.refresh, size: 16, color: scheme.primary),
                                  const SizedBox(width: 4),
                                  Text(l10n.claimRetakePhotoButton, style: textTheme.labelSmall?.copyWith(color: scheme.primary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: LedgerSpacing.lg),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: l10n.claimDescriptionLabel,
              hintText: widget.listing.isLost ? l10n.claimDescriptionHint : l10n.claimDescriptionHintOwner,
              alignLabelWithHint: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: LedgerSpacing.md),
            Text(_error!, style: textTheme.bodySmall?.copyWith(color: scheme.error)),
          ],
          const SizedBox(height: LedgerSpacing.xl),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: scheme.onPrimary))
                : Text(l10n.claimSubmitButton),
          ),
        ],
      ),
    );
  }
}

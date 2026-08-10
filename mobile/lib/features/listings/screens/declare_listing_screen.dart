import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/location/location_service.dart';
import '../../../l10n/app_localizations_x.dart';
import '../../../theme/spacing.dart';
import '../models/categories.dart';
import '../providers/listings_providers.dart';
import '../providers/listings_search_controller.dart';
import '../widgets/photo_picker_row.dart';
import '../widgets/position_picker_map.dart';

class DeclareListingScreen extends ConsumerStatefulWidget {
  const DeclareListingScreen({super.key});

  @override
  ConsumerState<DeclareListingScreen> createState() => _DeclareListingScreenState();
}

class _DeclareListingScreenState extends ConsumerState<DeclareListingScreen> {
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _neighborhoodController = TextEditingController();

  String _type = 'lost';
  String _category = listingCategories.first;
  DateTime _eventDate = DateTime.now();
  final List<File> _photos = [];

  LatLng? _position;
  bool _positionIsPrecise = true;
  bool _resolvingPosition = true;

  bool _submitting = false;
  Map<String, List<String>> _fieldErrors = const {};

  @override
  void initState() {
    super.initState();
    _resolvePosition();
  }

  Future<void> _resolvePosition() async {
    final result = await ref.read(locationServiceProvider).resolveCurrentPosition();
    if (!mounted) return;
    setState(() {
      _position = result.position;
      _positionIsPrecise = result.isPrecise;
      _resolvingPosition = false;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _submit() async {
    final position = _position;
    if (position == null) return;

    setState(() {
      _submitting = true;
      _fieldErrors = const {};
    });

    try {
      final repo = ref.read(listingsRepositoryProvider);
      var listing = await repo.create(
        type: _type,
        category: _category,
        description: _descriptionController.text.trim(),
        city: _cityController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        eventDate: _eventDate,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (_photos.isNotEmpty) {
        listing = await repo.uploadPhotos(listing.id, _photos);
      }

      await ref.read(listingsSearchControllerProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.declareSuccessSnackbar)));
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _fieldErrors = e.errors);
      if (e.errors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.declareAppBarTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(LedgerSpacing.xl),
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'lost', label: Text(l10n.statusLost), icon: const Icon(Icons.search)),
                ButtonSegment(value: 'found', label: Text(l10n.statusFound), icon: const Icon(Icons.check_circle_outline)),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.first),
            ),
            const SizedBox(height: LedgerSpacing.xl),
            Text(l10n.fieldCategoryLabel, style: textTheme.titleMedium),
            const SizedBox(height: LedgerSpacing.sm),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(errorText: _fieldErrors['category']?.first),
              items: [
                for (final category in listingCategories)
                  DropdownMenuItem(value: category, child: Text(categoryLabel(l10n, category))),
              ],
              onChanged: (value) => setState(() => _category = value ?? _category),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.declareDescriptionLabel,
                alignLabelWithHint: true,
                errorText: _fieldErrors['description']?.first,
              ),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            Text(l10n.declarePhotosLabel, style: textTheme.titleMedium),
            const SizedBox(height: LedgerSpacing.sm),
            PhotoPickerRow(
              photos: _photos,
              onChanged: (photos) => setState(() {
                _photos
                  ..clear()
                  ..addAll(photos);
              }),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            TextField(
              controller: _cityController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.fieldCityLabel, errorText: _fieldErrors['city']?.first),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            TextField(
              controller: _neighborhoodController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.declareNeighborhoodLabel,
                errorText: _fieldErrors['neighborhood']?.first,
              ),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(labelText: l10n.declareDateLabel),
                child: Text(
                  '${_eventDate.day.toString().padLeft(2, '0')}/${_eventDate.month.toString().padLeft(2, '0')}/${_eventDate.year}',
                ),
              ),
            ),
            const SizedBox(height: LedgerSpacing.lg),
            Text(l10n.declarePositionLabel, style: textTheme.titleMedium),
            const SizedBox(height: LedgerSpacing.sm),
            if (_resolvingPosition)
              const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()))
            else ...[
              PositionPickerMap(
                initialPosition: _position!,
                onPositionChanged: (position) => _position = position,
              ),
              if (!_positionIsPrecise) ...[
                const SizedBox(height: LedgerSpacing.sm),
                Text(
                  l10n.declarePositionImpreciseWarning,
                  style: textTheme.bodySmall?.copyWith(color: scheme.error),
                ),
              ],
            ],
            const SizedBox(height: LedgerSpacing.xxl),
            ElevatedButton(
              onPressed: (_submitting || _resolvingPosition) ? null : _submit,
              child: _submitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: scheme.onPrimary),
                    )
                  : Text(l10n.declareSubmitButton),
            ),
            const SizedBox(height: LedgerSpacing.xl),
          ],
        ),
      ),
    );
  }
}

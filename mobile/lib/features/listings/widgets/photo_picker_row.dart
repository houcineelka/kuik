import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../l10n/app_localizations_x.dart';

/// 1-to-3 photo picker: thumbnails with a remove badge, plus an add tile
/// that offers camera or gallery.
class PhotoPickerRow extends StatelessWidget {
  const PhotoPickerRow({super.key, required this.photos, required this.onChanged, this.maxPhotos = 3});

  final List<File> photos;
  final ValueChanged<List<File>> onChanged;
  final int maxPhotos;

  Future<void> _pick(BuildContext context) async {
    final l10n = context.l10n;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoPickerTakePhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoPickerChooseFromGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1600);
    if (picked == null) return;

    onChanged([...photos, File(picked.path)]);
  }

  void _remove(int index) {
    final updated = [...photos]..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < photos.length; i++)
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.file(photos[i], width: 80, height: 80, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  // 44x44 tap target (WCAG/Material minimum) around a small visual badge.
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => _remove(i),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: scheme.error,
                            child: Icon(Icons.close, size: 14, color: scheme.onError),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (photos.length < maxPhotos)
          GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.add_a_photo_outlined, color: scheme.primary),
            ),
          ),
      ],
    );
  }
}

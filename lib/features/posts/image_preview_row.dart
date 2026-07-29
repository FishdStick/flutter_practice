import 'package:flutter/material.dart';
import 'package:flutter_practice/core/utils/image_preview_utils.dart';

class ImagePreviewRow extends StatelessWidget {
  final List<String> imageUrls;
  final void Function(int index) onDelete;

  const ImagePreviewRow(
      {super.key, required this.imageUrls, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            imageUrls.length,
            (index) {
              final url = imageUrls[index];
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImagePreviewUtils.showImagePreview(url)),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onDelete(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

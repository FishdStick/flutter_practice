import 'package:flutter/material.dart';

class ImagePreviewRow extends StatelessWidget {
  final List<String> imageUrls;
  final void Function(int index) onDelete;

  const ImagePreviewRow({
    super.key,
    required this.imageUrls,
    required this.onDelete
  });

  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://') ||
        path.startsWith('blob:');
  }

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
          children: List.generate(imageUrls.length, (index) {
              final url = imageUrls[index];
              return Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) =>
                            Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(
                                  Icons.image, color: Colors.grey),
                            ),
                      ),
                    ),
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
                        )
                    )
                  ],
                ),
              );
            })
        ),
      ),
    );
  }
}
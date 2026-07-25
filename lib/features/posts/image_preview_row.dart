import 'package:flutter/material.dart';

class ImagePreviewRow extends StatelessWidget{
  final List<String> imageUrls;
  final void Function(int index) onDelete;

  const ImagePreviewRow({
    super.key,
    required this.imageUrls,
    required this.onDelete
  });

  @override
  Widget build(BuildContext context){
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            final url = imageUrls[index];

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: Stack(
                children: [
                  // Means Clip Rounded Rectangle
                  ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
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
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }
}
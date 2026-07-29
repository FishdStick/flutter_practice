import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ImagePreviewUtils {
  /// Used in Post Comments with images.
  /// Expands a single attached image to its full resolution
  static void expandSinglePreviewImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: const Icon(Icons.broken_image, size: 60),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Used in Post images
  /// Expands an image or a set of images in a post and makes it navigable as an
  /// image carousel
  static void expandPreviewImageGallery(BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (ctx) {
        final PageController modalPageController =
            PageController(initialPage: initialIndex);
        int activeModalIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.black87,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                      controller: modalPageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (idx) {
                        setModalState(() {
                          activeModalIndex = idx;
                        });
                      },
                      itemBuilder: (context, idx) {
                        return InteractiveViewer(
                          child: Center(
                            child: Image.network(
                              imageUrls[idx],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                      padding: const EdgeInsets.all(16.0),
                                      color: Colors.white,
                                      child: const Icon(Icons.broken_image,
                                          size: 60)),
                            ),
                          ),
                        );
                      }),

                  // Left Navigation Arrow
                  if (activeModalIndex > 0)
                    Positioned(
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white),
                          onPressed: () {
                            modalPageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                        ),
                      ),
                    ),

                  // Right Navigation Arrow
                  if (activeModalIndex < imageUrls.length - 1)
                    Positioned(
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right,
                              color: Colors.white),
                          onPressed: () {
                            modalPageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                        ),
                      ),
                    ),

                  // Close Button
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.white)),
                    ),
                  ),

                  // Image counter
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${activeModalIndex + 1} / ${imageUrls.length}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Used when uploading images
  /// Displays the thumbnails of the tentative images to be uploaded when
  /// creating a post or a comment
  static Widget showImagePreview(String path){
    Widget buildErrorPlaceHolder(){
      return Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey,)
      );
    }

    final isNetworkUrl = path.startsWith('http://') || path.startsWith('https://');
    final isBlobUrl = kIsWeb && path.startsWith('blob:');

    if (isNetworkUrl || isBlobUrl){
      return Image.network(
        path,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, stackTrace) => buildErrorPlaceHolder(),
      );
    } else {
      return Image.file(
        File(path),
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (ctx, error, stackTrace) => buildErrorPlaceHolder(),
      );
    }
  }
}

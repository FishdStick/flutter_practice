import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerUtils{
  static final ImagePicker _imagePicker = ImagePicker();

  /// Prompts user to pick images for upload
  /// Used in both posts and comments
  static Future<List<XFile>> pickImages() async {
    try {
      return await _imagePicker.pickMultiImage();
    } catch (_) {
      debugPrint('Error uploading files.');
      return [];
    }
  }

  /// Appends picked images from pickImages() to a List
  /// return true if images are added to imageList successfully.
  static Future<bool> attachImagesTo(List<XFile> imageList) async {
    final pickedImages = await pickImages();

    if (pickedImages.isNotEmpty){
      imageList.addAll(pickedImages);
      return true;
    }
    return false;
  }
}
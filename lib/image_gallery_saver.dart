import 'dart:async';
import 'package:flutter/services.dart';

class ImageGallerySaver {
  static const MethodChannel _channel = const MethodChannel('image_gallery_saver');

  /// save image to Gallery
  /// imageBytes can't null
  /// return Map type
  /// for example:{"isSuccess":true, "filePath":String?}
  static FutureOr<dynamic> saveImage(Uint8List imageBytes, {
    int quality = 80,
    String? name,
    bool isReturnImagePathOfIOS = false,
    double? latitude,
    double? longitude,
    int? createDate
  }) async {
    final result = await _channel.invokeMethod('saveImageToGallery', <String, dynamic>{
      'imageBytes': imageBytes,
      'quality': quality,
      'name': name,
      'isReturnImagePathOfIOS': isReturnImagePathOfIOS,
      'latitude': latitude,
      'longitude': longitude,
      'createDate': createDate,
    });
    return result;
  }

  /// Save the PNG，JPG，JPEG image or video located at [file] to the local device media gallery.
  static Future saveFile(String file, {
    String? name,
    bool isReturnPathOfIOS = false,
    double? latitude,
    double? longitude,
    int? createDate
  }) async {
    final result = await _channel.invokeMethod('saveFileToGallery', <String, dynamic>{
      'file': file,
      'name': name,
      'isReturnPathOfIOS': isReturnPathOfIOS,
      'latitude': latitude,
      'longitude': longitude,
      'createDate': createDate,
    });
    return result;
  }
}

import Flutter
import UIKit
import Photos

public class SwiftImageGallerySaverPlugin: NSObject, FlutterPlugin {
    var result: FlutterResult?;

    public static func register(with registrar: FlutterPluginRegistrar) {
      let channel = FlutterMethodChannel(name: "image_gallery_saver", binaryMessenger: registrar.messenger())
      let instance = SwiftImageGallerySaverPlugin()
      registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      self.result = result
      if call.method == "saveImageToGallery" {
        let arguments = call.arguments as? [String: Any] ?? [String: Any]()
        guard let imageData = (arguments["imageBytes"] as? FlutterStandardTypedData)?.data,
            let image = UIImage(data: imageData),
            let quality = arguments["quality"] as? Int,
            let _ = arguments["name"],
            let isReturnImagePath = arguments["isReturnImagePathOfIOS"] as? Bool else { return }
          let latitude = arguments["latitude"] as? Double
          let longitude = arguments["longitude"] as? Double
          let createDate = arguments["createDate"] as? Int
          let newImage = image.jpegData(compressionQuality: CGFloat(quality / 100))!
          saveImage(UIImage(data: newImage) ?? image, isReturnImagePath: isReturnImagePath, latitude: latitude, longitude: longitude, createDate: createDate)
      } else if (call.method == "saveFileToGallery") {
        guard let arguments = call.arguments as? [String: Any],
              let path = arguments["file"] as? String,
              let _ = arguments["name"],
              let isReturnFilePath = arguments["isReturnPathOfIOS"] as? Bool else { return }
          let latitude = arguments["latitude"] as? Double
          let longitude = arguments["longitude"] as? Double
          let createDate = arguments["createDate"] as? Int
        if isImageFile(filename: path) {
            saveImageAtFileUrl(path, isReturnImagePath: isReturnFilePath, latitude: latitude, longitude: longitude, createDate: createDate)
        } else {
            saveVideo(path, isReturnImagePath: isReturnFilePath, latitude: latitude, longitude: longitude, createDate: createDate)
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
    
    func saveVideo(_ path: String, isReturnImagePath: Bool, latitude: Double? = nil, longitude: Double? = nil, createDate: Int? = nil) {
        var videoIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL.init(fileURLWithPath: path))
            if let latitude = latitude, let longitude = longitude {
                req?.location = CLLocation(latitude: latitude, longitude: longitude)
            }
            if let timeInterval = createDate {
                req?.creationDate = Date(timeIntervalSince1970: Double(timeInterval))
            }
            if let videoId = req?.placeholderForCreatedAsset?.localIdentifier {
                videoIds.append(videoId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success && videoIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: videoIds, options: nil)
                    if assetResult.count > 0 {
                        if isReturnImagePath {
                            let videoAsset = assetResult[0]
                            PHImageManager().requestAVAsset(forVideo: videoAsset, options: nil) { (avurlAsset, audioMix, info) in
                                if let urlStr = (avurlAsset as? AVURLAsset)?.url.absoluteString {
                                    self.saveResult(isSuccess: true, filePath: urlStr)
                                }
                            }
                        } else {
                            self.saveResult(isSuccess: true, filePath: nil)
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: error)
                }
            }
        })
    }
    
    func saveImage(_ image: UIImage, isReturnImagePath: Bool, latitude: Double? = nil, longitude: Double? = nil, createDate: Int? = nil) {
        var imageIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let latitude = latitude, let longitude = longitude {
                req.location = CLLocation(latitude: latitude, longitude: longitude)
            }
            if let timeInterval = createDate {
                req.creationDate = Date(timeIntervalSince1970: Double(timeInterval))
            }
            if let imageId = req.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success && imageIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        if isReturnImagePath {
                            let imageAsset = assetResult[0]
                            let options = PHContentEditingInputRequestOptions()
                            options.canHandleAdjustmentData = { (adjustmeta)
                                -> Bool in true }
                            imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, info) in
                                if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                    self.saveResult(isSuccess: true, filePath: urlStr)
                                }
                            }
                        } else {
                            self.saveResult(isSuccess: true, filePath: nil)
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: error)
                }
            }
        })
    }
    
    func saveImageAtFileUrl(_ url: String, isReturnImagePath: Bool, latitude: Double? = nil, longitude: Double? = nil, createDate: Int? = nil) {
        var imageIds: [String] = []
        
        PHPhotoLibrary.shared().performChanges( {
            let req = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: URL(string: url)!)
            if let latitude = latitude, let longitude = longitude {
                req?.location = CLLocation(latitude: latitude, longitude: longitude)
            }
            if let timeInterval = createDate {
                req?.creationDate = Date(timeIntervalSince1970: Double(timeInterval))
            }
            if let imageId = req?.placeholderForCreatedAsset?.localIdentifier {
                imageIds.append(imageId)
            }
        }, completionHandler: { [unowned self] (success, error) in
            DispatchQueue.main.async {
                if success && imageIds.count > 0 {
                    let assetResult = PHAsset.fetchAssets(withLocalIdentifiers: imageIds, options: nil)
                    if assetResult.count > 0 {
                        if isReturnImagePath {
                            let imageAsset = assetResult[0]
                            let options = PHContentEditingInputRequestOptions()
                            options.canHandleAdjustmentData = { (adjustmeta)
                                -> Bool in true }
                            imageAsset.requestContentEditingInput(with: options) { [unowned self] (contentEditingInput, info) in
                                if let urlStr = contentEditingInput?.fullSizeImageURL?.absoluteString {
                                    self.saveResult(isSuccess: true, filePath: urlStr)
                                }
                            }
                        } else {
                            self.saveResult(isSuccess: true, filePath: nil)
                        }
                    }
                } else {
                    self.saveResult(isSuccess: false, error: error)
                }
            }
        })
    }
        
    func saveResult(isSuccess: Bool, error: Error? = nil, filePath: String? = nil) {
        var saveResult = SaveResultModel()
        saveResult.isSuccess = error == nil
        saveResult.errorMessage = error?.localizedDescription
        saveResult.filePath = filePath
        result?(saveResult.toDic())
    }

    func isImageFile(filename: String) -> Bool {
        return filename.hasSuffix(".jpg")
            || filename.hasSuffix(".png")
            || filename.hasSuffix(".jpeg")
            || filename.hasSuffix(".JPEG")
            || filename.hasSuffix(".JPG")
            || filename.hasSuffix(".PNG")
            || filename.hasSuffix(".gif")
            || filename.hasSuffix(".GIF")
            || filename.hasSuffix(".heic")
            || filename.hasSuffix(".HEIC")
    }
}

public struct SaveResultModel: Encodable {
    var isSuccess: Bool!
    var filePath: String?
    var errorMessage: String?
    
    func toDic() -> [String:Any]? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else { return nil }
        if (!JSONSerialization.isValidJSONObject(data)) {
            return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
        }
        return nil
    }
}

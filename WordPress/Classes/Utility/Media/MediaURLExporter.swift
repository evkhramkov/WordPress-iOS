import Foundation
import MobileCoreServices

/// MediaLibrary export handling of URLs.
///
class MediaURLExporter: MediaExporter {

    var resizesIfNeeded = true
    var stripsGeoLocationIfNeeded = true

    public enum ExportError: MediaExporterError {
        case invalidFileURL
        case unknownFileUTI
        case failedToInitializeVideoExportSession
        case videoExportSessionFailedWithAnUnknownError

        var description: String {
            switch self {
            case .invalidFileURL,
                 .unknownFileUTI:
                return NSLocalizedString("The media could not be added to the Media Library.", comment: "Message shown when an image or video failed to load while trying to add it to the Media library.")
            case .failedToInitializeVideoExportSession,
                 .videoExportSessionFailedWithAnUnknownError:
                return NSLocalizedString("The video could not be added to the Media Library.", comment: "Message shown when a video failed to load while trying to add it to the Media library.")
            }
        }
        func toNSError() -> NSError {
            return NSError(domain: _domain, code: _code, userInfo: [NSLocalizedDescriptionKey: String(describing: self)])
        }
    }

    /// Exports a file of an unknown type, to a new Media URL.
    ///
    /// Expects files conforming to a video, image or GIF uniform type.
    ///
    func exportURL(fileURL: URL, onCompletion: @escaping (URL) -> (), onError: @escaping (MediaExporterError) -> ()) {
        do {
            guard fileURL.isFileURL else {
                throw ExportError.invalidFileURL
            }
            let typeIdentifier = try typeIdentifierAtURL(fileURL) as CFString
            if UTTypeEqual(typeIdentifier, kUTTypeGIF) {
                exportGIF(atURL: fileURL, onCompletion: onCompletion, onError: onError)
            } else if UTTypeConformsTo(typeIdentifier, kUTTypeVideo) {
                exportVideo(atURL: fileURL, typeIdentifier: typeIdentifier as String, onCompletion: onCompletion, onError: onError)
            } else if UTTypeConformsTo(typeIdentifier, kUTTypeImage) {
                exportImage(atURL: fileURL, onCompletion: onCompletion, onError: onError)
            }
        } catch {
            onError(exporterErrorWith(error: error))
        }
    }

    /// Exports the known image file at the URL to a new Media URL.
    ///
    fileprivate func exportImage(atURL url: URL, onCompletion: @escaping (URL) -> (), onError: @escaping (MediaExporterError) -> ()) {
        // Pass the export off to the image exporter
        let exporter = MediaImageExporter()
        exporter.exportImage(atURL: url, onCompletion: onCompletion, onError: onError)
    }

    /// Exports the known video file at the URL to a new Media URL.
    ///
    fileprivate func exportVideo(atURL url: URL, typeIdentifier: String, onCompletion: @escaping (URL) -> (), onError: @escaping (MediaExporterError) -> ()) {
        do {
            let asset = AVURLAsset(url: url)
            guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else {
                throw ExportError.failedToInitializeVideoExportSession
            }

            let mediaURL = try MediaLibrary.makeLocalMediaURL(withFilename: url.lastPathComponent,
                                                              fileExtension: fileExtensionForUTType(typeIdentifier))
            session.outputURL = mediaURL
            session.outputFileType = typeIdentifier
            session.shouldOptimizeForNetworkUse = true
            session.exportAsynchronously {
                guard session.status == .completed else {
                    if let error = session.error {
                        onError(self.exporterErrorWith(error: error))
                    } else {
                        onError(ExportError.videoExportSessionFailedWithAnUnknownError)
                    }
                    return
                }
                onCompletion(mediaURL)
            }
        } catch {
            onError(exporterErrorWith(error: error))
        }
    }

    /// Exports the GIF file at the URL to a new Media URL, by simply copying the file.
    ///
    fileprivate func exportGIF(atURL url: URL, onCompletion: @escaping (URL) -> (), onError: @escaping (MediaExporterError) -> ()) {
        do {
            let fileManager = FileManager.default
            let mediaURL = try MediaLibrary.makeLocalMediaURL(withFilename: url.lastPathComponent, fileExtension: "gif")
            try fileManager.copyItem(at: url, to: mediaURL)
            onCompletion(mediaURL)
        } catch {
            onError(exporterErrorWith(error: error))
        }
    }

    /// Resolves the uniform type identifier for the file at the URL, or throws an error if unknown.
    ///
    fileprivate func typeIdentifierAtURL(_ url: URL) throws -> String {
        let resourceValues = try url.resourceValues(forKeys: [.typeIdentifierKey])
        guard let typeIdentifier = resourceValues.typeIdentifier else {
            throw ExportError.unknownFileUTI
        }
        return typeIdentifier
    }
}
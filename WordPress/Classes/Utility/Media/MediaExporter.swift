import Foundation
import MobileCoreServices

/// General MediaExport protocol, requiring a URL
///
protocol MediaExport {
    /// The resulting file URL of an export.
    ///
    var url: URL { get }
    var fileSize: Int64? { get }
}

/// Struct of an image export.
///
struct MediaImageExport: MediaExport {
    let url: URL
    let width: CGFloat?
    let height: CGFloat?
    let fileSize: Int64?
}

/// Struct of a video export.
///
struct MediaVideoExport: MediaExport {
    let url: URL
    let duration: TimeInterval?
    let fileSize: Int64?
}

/// Struct of a GIF export.
///
struct MediaGIFExport: MediaExport {
    let url: URL
    let fileSize: Int64?
}

/// Generic Error protocol for detecting and type classifying known errors that occur while exporting.
///
protocol MediaExportError: Error, CustomStringConvertible {
    /// Convert an Error to an NSError with a localizedDescription available.
    ///
    func toNSError() -> NSError
}

/// Generic MediaExportError tied to a system generated Error.
///
enum MediaExportSystemError: MediaExportError {
    case failedWith(systemError: Error)
    public var description: String {
        switch self {
        case .failedWith(let systemError):
            return String(describing: systemError)
        }
    }
    func toNSError() -> NSError {
        switch self {
        case .failedWith(let systemError):
            return systemError as NSError
        }
    }
}

protocol MediaExporter {
    /// Resize the image if needed, according to the user's MediaSettings.
    ///
    var resizesIfNeeded: Bool { get set }

    /// Strip the geoLocation from assets if needed, according to the user's MediaSettings.
    ///
    var stripsGeoLocationIfNeeded: Bool { get set }
}

extension MediaExporter {

    /// Handles wrapping into MediaExportError type values when the encountered Error type value is unknown.
    ///
    /// - param error: Error with an unknown type value, or nil for easy conversion.
    /// - returns: The ExporterError type value itself, or an ExportError.failedWith
    ///
    func exporterErrorWith(error: Error) -> MediaExportError {
        switch error {
        case let error as MediaExportError:
            return error
        default:
            return MediaExportSystemError.failedWith(systemError: error)
        }
    }

    func fileSizeAtURL(_ url: URL) -> Int64? {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? Int64
    }

    func fileExtensionForUTType(_ type: String) -> String? {
        let fileExtension = UTTypeCopyPreferredTagWithClass(type as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue()
        return fileExtension as String?
    }
}

cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.phonegap.plugins.PushPlugin/www/PushNotification.js",
        "id": "com.phonegap.plugins.PushPlugin.PushNotification",
        "pluginId": "com.phonegap.plugins.PushPlugin",
        "clobbers": [
            "PushNotification"
        ]
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.plugin.oauth.js",
        "id": "com.salesforce.plugin.oauth",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.plugin.sdkinfo.js",
        "id": "com.salesforce.plugin.sdkinfo",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.plugin.smartstore.js",
        "id": "com.salesforce.plugin.smartstore",
        "pluginId": "com.salesforce",
        "clobbers": [
            "navigator.smartstore"
        ]
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.plugin.sfaccountmanager.js",
        "id": "com.salesforce.plugin.sfaccountmanager",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.plugin.smartsync.js",
        "id": "com.salesforce.plugin.smartsync",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.util.bootstrap.js",
        "id": "com.salesforce.util.bootstrap",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.util.event.js",
        "id": "com.salesforce.util.event",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.util.exec.js",
        "id": "com.salesforce.util.exec",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.util.logger.js",
        "id": "com.salesforce.util.logger",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/com.salesforce/www/com.salesforce.util.push.js",
        "id": "com.salesforce.util.push",
        "pluginId": "com.salesforce"
    },
    {
        "file": "plugins/org.apache.cordova.file-transfer/www/FileTransferError.js",
        "id": "org.apache.cordova.file-transfer.FileTransferError",
        "pluginId": "org.apache.cordova.file-transfer",
        "clobbers": [
            "window.FileTransferError"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file-transfer/www/FileTransfer.js",
        "id": "org.apache.cordova.file-transfer.FileTransfer",
        "pluginId": "org.apache.cordova.file-transfer",
        "clobbers": [
            "window.FileTransfer"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.network-information/www/network.js",
        "id": "org.apache.cordova.network-information.network",
        "pluginId": "org.apache.cordova.network-information",
        "clobbers": [
            "navigator.connection",
            "navigator.network.connection"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.network-information/www/Connection.js",
        "id": "org.apache.cordova.network-information.Connection",
        "pluginId": "org.apache.cordova.network-information",
        "clobbers": [
            "Connection"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.presentation-transfer/www/PresentationTransfer.js",
        "id": "com.qapint.cordova.presentation-transfer.PresentationTransfer",
        "pluginId": "com.qapint.cordova.presentation-transfer",
        "clobbers": [
            "window.PresentationTransfer"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.pdf-viewer/www/pdf-viewer.js",
        "id": "com.qapint.cordova.pdf-viewer.PdfViewer",
        "pluginId": "com.qapint.cordova.pdf-viewer",
        "clobbers": [
            "window.PdfViewer"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.zip/www/zip.js",
        "id": "com.qapint.cordova.zip.Zip",
        "pluginId": "com.qapint.cordova.zip",
        "clobbers": [
            "window.Zip"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.locale/www/locale.js",
        "id": "com.qapint.cordova.locale.Locale",
        "pluginId": "com.qapint.cordova.locale",
        "clobbers": [
            "window.LocaleSwitcher"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.image-resize/www/image-resize.js",
        "id": "com.qapint.cordova.image-resize.ImageResize",
        "pluginId": "com.qapint.cordova.image-resize",
        "clobbers": [
            "window.ImageResize"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.email-composer/www/email-composer.js",
        "id": "com.qapint.cordova.email-composer.EmailComposer",
        "pluginId": "com.qapint.cordova.email-composer",
        "clobbers": [
            "window.EmailComposer"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.phone-dialer/www/android/phone-dialer.js",
        "id": "com.qapint.cordova.phone-dialer.PhoneDialer",
        "pluginId": "com.qapint.cordova.phone-dialer",
        "clobbers": [
            "window.PhoneDialer"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.camera/www/CameraConstants.js",
        "id": "org.apache.cordova.camera.Camera",
        "pluginId": "org.apache.cordova.camera",
        "clobbers": [
            "Camera"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.camera/www/CameraPopoverOptions.js",
        "id": "org.apache.cordova.camera.CameraPopoverOptions",
        "pluginId": "org.apache.cordova.camera",
        "clobbers": [
            "CameraPopoverOptions"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.camera/www/Camera.js",
        "id": "org.apache.cordova.camera.camera",
        "pluginId": "org.apache.cordova.camera",
        "clobbers": [
            "navigator.camera"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.camera/www/CameraPopoverHandle.js",
        "id": "org.apache.cordova.camera.CameraPopoverHandle",
        "pluginId": "org.apache.cordova.camera",
        "clobbers": [
            "CameraPopoverHandle"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.attachments-viewer/www/attachments-viewer.js",
        "id": "com.qapint.cordova.attachments-viewer.AttachmentsViewer",
        "pluginId": "com.qapint.cordova.attachments-viewer",
        "clobbers": [
            "window.AttachmentsViewer"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.soft-keyboard/www/soft-keyboard.js",
        "id": "com.qapint.cordova.soft-keyboard.SoftKeyboard",
        "pluginId": "com.qapint.cordova.soft-keyboard",
        "clobbers": [
            "window.SoftKeyboard"
        ]
    },
    {
        "file": "plugins/com.qapint.cordova.presentation-viewer/www/presentation-viewer.js",
        "id": "com.qapint.cordova.presentation-viewer.PresentationViewer",
        "pluginId": "com.qapint.cordova.presentation-viewer",
        "clobbers": [
            "window.PresentationViewer"
        ]
    },
    {
        "file": "plugins/cordova-plugin-globalization/www/GlobalizationError.js",
        "id": "cordova-plugin-globalization.GlobalizationError",
        "pluginId": "cordova-plugin-globalization",
        "clobbers": [
            "window.GlobalizationError"
        ]
    },
    {
        "file": "plugins/cordova-plugin-globalization/www/globalization.js",
        "id": "cordova-plugin-globalization.globalization",
        "pluginId": "cordova-plugin-globalization",
        "clobbers": [
            "navigator.globalization"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.device/www/device.js",
        "id": "org.apache.cordova.device.device",
        "pluginId": "org.apache.cordova.device",
        "clobbers": [
            "device"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/DirectoryEntry.js",
        "id": "org.apache.cordova.file.DirectoryEntry",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.DirectoryEntry"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/DirectoryReader.js",
        "id": "org.apache.cordova.file.DirectoryReader",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.DirectoryReader"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/Entry.js",
        "id": "org.apache.cordova.file.Entry",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.Entry"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/File.js",
        "id": "org.apache.cordova.file.File",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.File"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileEntry.js",
        "id": "org.apache.cordova.file.FileEntry",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileEntry"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileError.js",
        "id": "org.apache.cordova.file.FileError",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileError"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileReader.js",
        "id": "org.apache.cordova.file.FileReader",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileReader"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileSystem.js",
        "id": "org.apache.cordova.file.FileSystem",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileSystem"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileUploadOptions.js",
        "id": "org.apache.cordova.file.FileUploadOptions",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileUploadOptions"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileUploadResult.js",
        "id": "org.apache.cordova.file.FileUploadResult",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileUploadResult"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/FileWriter.js",
        "id": "org.apache.cordova.file.FileWriter",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.FileWriter"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/Flags.js",
        "id": "org.apache.cordova.file.Flags",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.Flags"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/LocalFileSystem.js",
        "id": "org.apache.cordova.file.LocalFileSystem",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.LocalFileSystem"
        ],
        "merges": [
            "window"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/Metadata.js",
        "id": "org.apache.cordova.file.Metadata",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.Metadata"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/ProgressEvent.js",
        "id": "org.apache.cordova.file.ProgressEvent",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.ProgressEvent"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/fileSystems.js",
        "id": "org.apache.cordova.file.fileSystems",
        "pluginId": "org.apache.cordova.file"
    },
    {
        "file": "plugins/org.apache.cordova.file/www/requestFileSystem.js",
        "id": "org.apache.cordova.file.requestFileSystem",
        "pluginId": "org.apache.cordova.file",
        "clobbers": [
            "window.requestFileSystem"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/resolveLocalFileSystemURI.js",
        "id": "org.apache.cordova.file.resolveLocalFileSystemURI",
        "pluginId": "org.apache.cordova.file",
        "merges": [
            "window"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/android/FileSystem.js",
        "id": "org.apache.cordova.file.androidFileSystem",
        "pluginId": "org.apache.cordova.file",
        "merges": [
            "FileSystem"
        ]
    },
    {
        "file": "plugins/org.apache.cordova.file/www/fileSystems-roots.js",
        "id": "org.apache.cordova.file.fileSystems-roots",
        "pluginId": "org.apache.cordova.file",
        "runs": true
    },
    {
        "file": "plugins/org.apache.cordova.file/www/fileSystemPaths.js",
        "id": "org.apache.cordova.file.fileSystemPaths",
        "pluginId": "org.apache.cordova.file",
        "merges": [
            "cordova"
        ],
        "runs": true
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.phonegap.plugins.PushPlugin": "2.2.1",
    "com.salesforce": "3.3.2",
    "org.apache.cordova.file-transfer": "0.5.0",
    "org.apache.cordova.network-information": "0.2.15",
    "com.qapint.cordova.presentation-transfer": "1.0.0",
    "com.qapint.cordova.pdf-viewer": "1.0.0",
    "com.qapint.cordova.zip": "1.0.1",
    "com.qapint.cordova.locale": "1.0.0",
    "com.qapint.cordova.image-resize": "1.0.0",
    "com.qapint.cordova.email-composer": "1.0.0",
    "com.qapint.cordova.phone-dialer": "1.0.0",
    "org.apache.cordova.camera": "0.3.6",
    "com.qapint.cordova.attachments-viewer": "1.0.0",
    "com.qapint.cordova.soft-keyboard": "1.0.0",
    "com.qapint.cordova.presentation-viewer": "1.0.1",
    "cordova-plugin-globalization": "1.0.2",
    "org.apache.cordova.device": "0.3.0",
    "org.apache.cordova.file": "1.3.3"
}
// BOTTOM OF METADATA
});
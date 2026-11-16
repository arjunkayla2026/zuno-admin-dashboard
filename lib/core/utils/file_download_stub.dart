import 'dart:typed_data';

/// Saves [bytes] as a file named [fileName]. Only supported on the web.
void downloadFile(Uint8List bytes, String fileName, String mimeType) =>
    throw UnsupportedError('File downloads are only supported on the web');

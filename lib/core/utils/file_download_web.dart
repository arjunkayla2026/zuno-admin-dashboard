import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

const Duration _revokeDelay = Duration(seconds: 30);

/// Starts a browser download of [bytes] named [fileName].
void downloadFile(Uint8List bytes, String fileName, String mimeType) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  // Revoking right away can cancel the download in some browsers.
  Timer(_revokeDelay, () => web.URL.revokeObjectURL(url));
}

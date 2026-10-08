import 'dart:js_interop';
import 'dart:js_interop_unsafe';

Future<String?> runWebJsOcr(String base64Data) async {
  try {
    if (globalContext.has('runTesseractOcr')) {
      final jsFunc = globalContext['runTesseractOcr'] as JSFunction?;
      if (jsFunc != null) {
        final jsPromise = jsFunc.callAsFunction(globalContext, base64Data.toJS) as JSPromise<JSString>?;
        if (jsPromise != null) {
          final jsResult = await jsPromise.toDart;
          if (jsResult.toDart.trim().isNotEmpty) {
            return jsResult.toDart;
          }
        }
      }
    }
  } catch (e) {
    // JS OCR fallback
  }
  return null;
}

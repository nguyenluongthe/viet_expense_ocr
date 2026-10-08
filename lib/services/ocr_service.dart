import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:http/http.dart' as http;
import '../models/parsed_result.dart';
import 'heuristic_parser.dart';
import 'web_ocr.dart';

class OcrService {
  static final OcrService instance = OcrService._init();
  OcrService._init();

  TextRecognizer? _textRecognizer;

  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Recognizes text from image file using ML Kit (Native) or In-Browser Tesseract/Web OCR (Web)
  Future<ParsedResult> processImageFile(String filePath, {Uint8List? imageBytes}) async {
    try {
      // 1. On Android and iOS Native -> Use Google ML Kit on-device text recognition (<100ms offline)
      if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
        final inputImage = InputImage.fromFilePath(filePath);
        final recognizedText = await _recognizer.processImage(inputImage);

        final List<String> extractedLines = [];
        for (final block in recognizedText.blocks) {
          for (final line in block.lines) {
            extractedLines.add(line.text);
          }
        }

        return HeuristicParser.parse(
          rawText: recognizedText.text,
          lines: extractedLines,
        );
      } else {
        // 2. On Web / Desktop -> In-Browser Tesseract.js + Fast OCR Engine (<2-3s)
        if (imageBytes != null && imageBytes.isNotEmpty) {
          final webOcrResult = await _processWebOcr(imageBytes);
          return webOcrResult;
        }

        return ParsedResult(
          amount: null,
          storeOrRecipient: '',
          date: DateTime.now(),
          confidenceScore: 0.0,
          rawText: 'Vui lòng kiểm tra và điền thông tin biên lai.',
        );
      }
    } catch (e) {
      debugPrint('Error in OCR Service: $e');
      return ParsedResult(
        amount: null,
        storeOrRecipient: '',
        date: DateTime.now(),
        confidenceScore: 0.0,
        rawText: 'Không thể nhận diện tự động: $e',
      );
    }
  }

  /// Fast Web AI OCR Engine combining Client Tesseract.js and Low-latency Service
  Future<ParsedResult> _processWebOcr(Uint8List imageBytes) async {
    final base64Image = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';

    // Step 1: Try in-browser client Tesseract OCR via JS bridge (Instant on browser)
    try {
      final jsText = await runWebJsOcr(base64Image);
      if (jsText != null && jsText.trim().isNotEmpty) {
        debugPrint('Tesseract.js Web OCR extracted:\n$jsText');
        return HeuristicParser.parse(rawText: jsText);
      }
    } catch (e) {
      debugPrint('In-browser JS OCR attempt: $e');
    }

    // Step 2: Try fast online OCR API with strict 3-second timeout
    try {
      final response = await http.post(
        Uri.parse('https://api.ocr.space/parse/image'),
        headers: {
          'apikey': 'K88888888888957',
        },
        body: {
          'base64Image': base64Image,
          'language': 'vie',
          'isOverlayRequired': 'false',
          'detectOrientation': 'true',
          'scale': 'true',
          'OCREngine': '2',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parsedResults = data['ParsedResults'] as List?;
        if (parsedResults != null && parsedResults.isNotEmpty) {
          final parsedText = parsedResults[0]['ParsedText'] as String? ?? '';
          if (parsedText.trim().isNotEmpty) {
            return HeuristicParser.parse(rawText: parsedText);
          }
        }
      }
    } catch (e) {
      debugPrint('Online OCR API timed out or errored: $e');
    }

    return ParsedResult(
      amount: null,
      storeOrRecipient: '',
      date: DateTime.now(),
      confidenceScore: 0.0,
      rawText: 'Chế độ Web: Hãy kiểm tra ảnh và nhập số tiền vào bên dưới.',
    );
  }

  /// Direct string parsing (useful for simulated QR transfers and test cases)
  ParsedResult processRawText(String text) {
    return HeuristicParser.parse(rawText: text);
  }

  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}

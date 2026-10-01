import '../core/constants/categories.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/parsed_result.dart';

class HeuristicParser {
  // Vietnamese Banking Entities
  static final List<String> _vietnameseBanks = [
    'Vietcombank', 'VCB',
    'Techcombank', 'TCB',
    'MBBank', 'MB Bank', 'MB',
    'VPBank', 'VP Bank',
    'TPBank', 'TP Bank',
    'BIDV',
    'Agribank',
    'ACB',
    'OCB',
    'VIB',
    'Sacombank',
    'HDBank',
    'SHB',
    'SeABank',
    'MSB',
    'Eximbank',
    'MoMo', 'Ví MoMo',
    'ZaloPay',
    'VNPay',
    'Cake', 'Cake by VPBank',
    'Timo',
    'Viettel Money',
  ];

  static final List<String> _popularStores = [
    'Highlands Coffee', 'Highlands',
    'The Coffee House', 'Phúc Long', 'Phuc Long',
    'Katinat', 'Trung Nguyên', 'Starbucks',
    'Circle K', 'WinMart', 'WinMart+', 'GS25', 'Ministop', 'FamilyMart', '7-Eleven',
    'Annam Gourmet', 'Co.opmart', 'Coopmart', 'Bách Hóa Xanh', 'Bach Hoa Xanh',
    'Shopee', 'Lazada', 'Tiki', 'Grab', 'Be', 'Xanh SM', 'Gojek',
    'Cơm Tấm', 'Phở 24', 'Lotteria', 'KFC', 'Jollibee', 'Pizza Hut', 'The Pizza Company',
  ];

  /// Main parse method that transforms OCR raw text and lines into a structured ParsedResult
  static ParsedResult parse({
    required String rawText,
    List<String> lines = const [],
  }) {
    final textLines = lines.isNotEmpty
        ? lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList()
        : rawText
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

    final matchedTokens = <String>[];

    // 1. Detect Payment Method (QR Banking Transfer vs Paper Receipt)
    final paymentMethod = _detectPaymentMethod(rawText, textLines);

    // 2. Parse Amount
    final amountResult = _parseAmount(textLines, rawText, matchedTokens);

    // 3. Parse Recipient / Store / Bank
    final storeResult = _parseStoreOrRecipient(textLines, rawText, paymentMethod, matchedTokens);

    // 4. Parse Date
    final dateResult = _parseDate(textLines, rawText, matchedTokens);

    // 5. Parse Transaction Code
    final txCode = _parseTransactionCode(textLines, rawText, matchedTokens);

    // 6. Parse Content / Note
    final note = _parseTransferNote(textLines, rawText);

    // 7. Auto-categorize based on context
    final category = _autoCategorize(
      store: storeResult.recipient,
      note: note,
      rawText: rawText,
      bank: storeResult.bank,
    );

    // Calculate Confidence Score
    double confidence = 0.0;
    if (amountResult.amount != null && amountResult.amount! > 0) confidence += 0.40;
    if (storeResult.recipient.isNotEmpty && storeResult.recipient != 'Chưa rõ') confidence += 0.30;
    if (dateResult.date != null) confidence += 0.20;
    if (txCode != null && txCode.isNotEmpty) confidence += 0.10;

    return ParsedResult(
      amount: amountResult.amount,
      amountRaw: amountResult.rawStr,
      storeOrRecipient: storeResult.recipient,
      bankName: storeResult.bank,
      date: dateResult.date ?? DateTime.now(),
      dateRaw: dateResult.rawStr,
      transactionCode: txCode,
      note: note,
      paymentMethod: paymentMethod,
      category: category,
      confidenceScore: confidence.clamp(0.0, 1.0),
      rawText: rawText,
      matchedTokens: matchedTokens,
      rawLines: textLines,
    );
  }

  // --- 1. PAYMENT METHOD DETECTION ---
  static String _detectPaymentMethod(String fullText, List<String> lines) {
    final lower = fullText.toLowerCase();
    if (lower.contains('vietqr') ||
        lower.contains('mã qr') ||
        lower.contains('quét qr') ||
        lower.contains('qr pay') ||
        lower.contains('vnpay-qr')) {
      return 'VietQR / QR Code';
    }
    if (lower.contains('chuyển khoản') ||
        lower.contains('chuyển tiền') ||
        lower.contains('giao dịch thành công') ||
        lower.contains('người thụ hưởng') ||
        lower.contains('tài khoản nhận') ||
        lower.contains('biến động số dư') ||
        lower.contains('stk:')) {
      return 'Chuyển khoản Banking';
    }
    if (lower.contains('momo') || lower.contains('zalopay') || lower.contains('viettel money') || lower.contains('shopeepay')) {
      return 'Ví điện tử';
    }
    if (lower.contains('hóa đơn') || lower.contains('phiếu thanh toán') || lower.contains('bill') || lower.contains('vat')) {
      return 'Hóa đơn giấy / POS';
    }
    return 'QR Chuyển khoản';
  }

  // --- 2. HEURISTIC AMOUNT PARSER ---
  static ({double? amount, String? rawStr}) _parseAmount(
    List<String> lines,
    String fullText,
    List<String> matchedTokens,
  ) {
    // Priority 1: Lines containing direct amount keywords
    // e.g. "Số tiền: 50.000 VND", "Tổng cộng: 65.000 đ", "Thanh toán: 45k", "TOTAL: 120,000"
    final keywordPattern = RegExp(
      r'(?:số\s*tiền|tổng\s*(?:cộng|tiền)?|thanh\s*toán|amount|total|đã\s*chuyển|giá\s*trị|tiền\s*thanh\s*toán|số\s*tiền\s*giao\s*dịch)\s*[:=]?\s*([+]?[-]?\s*[\d.,kK]+(?:\s*(?:đ|vnd|vnđ|d))?)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = keywordPattern.firstMatch(line);
      if (match != null) {
        final rawVal = match.group(1);
        if (rawVal != null) {
          final parsed = CurrencyFormatter.parseAmount(rawVal);
          if (parsed != null && parsed >= 1000) {
            matchedTokens.add('Số tiền (keyword): $rawVal');
            return (amount: parsed, rawStr: rawVal.trim());
          }
        }
      }
    }

    // Priority 2: Look for lines right AFTER an amount label line (e.g. Line 1: "Số tiền", Line 2: "150.000 VND")
    final labelPattern = RegExp(
      r'^(?:số\s*tiền|tổng\s*cộng|tổng\s*tiền|thanh\s*toán|amount|total|tiền)$',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length - 1; i++) {
      if (labelPattern.hasMatch(lines[i].trim())) {
        final nextLine = lines[i + 1].trim();
        final parsed = CurrencyFormatter.parseAmount(nextLine);
        if (parsed != null && parsed >= 1000) {
          matchedTokens.add('Số tiền (dưới label): $nextLine');
          return (amount: parsed, rawStr: nextLine);
        }
      }
    }

    // Priority 3: Scan for tokens with currency indicators: đ, VND, VNĐ, k
    // e.g. "65.000 đ", "120,000VND", "-50.000 VND", "45k"
    final currencyTokenPattern = RegExp(
      r'([+-]?\s*\d{1,3}(?:[.,]\d{3})+(?:\s*(?:đ|vnd|vnđ|d))|\b\d+[kK]\b)',
      caseSensitive: false,
    );

    double? maxAmount;
    String? maxRaw;

    for (final line in lines) {
      // Avoid phone numbers, account numbers (e.g. 090..., 03...)
      if (RegExp(r'^(?:0|\+84)\d{8,11}$').hasMatch(line.replaceAll(' ', ''))) {
        continue;
      }

      for (final match in currencyTokenPattern.allMatches(line)) {
        final token = match.group(0);
        if (token != null) {
          final parsed = CurrencyFormatter.parseAmount(token);
          if (parsed != null && parsed >= 1000) {
            // Keep the most reasonable amount (usually the largest total on receipts or transfer amount)
            if (maxAmount == null || parsed > maxAmount) {
              maxAmount = parsed;
              maxRaw = token.trim();
            }
          }
        }
      }
    }

    if (maxAmount != null) {
      matchedTokens.add('Số tiền (currency token): $maxRaw');
      return (amount: maxAmount, rawStr: maxRaw);
    }

    // Priority 4: Look for isolated formatted numbers (e.g. "65.000" or "120,000")
    final isolatedNumPattern = RegExp(r'\b\d{1,3}(?:[.,]\d{3})+\b');
    for (final line in lines) {
      // Don't treat dates as amounts (e.g. 2026.01.01 or similar)
      if (line.contains('/') || line.contains(':')) continue;

      final match = isolatedNumPattern.firstMatch(line);
      if (match != null) {
        final token = match.group(0)!;
        final parsed = CurrencyFormatter.parseAmount(token);
        if (parsed != null && parsed >= 1000 && parsed < 1000000000) {
          matchedTokens.add('Số tiền (formatted number): $token');
          return (amount: parsed, rawStr: token);
        }
      }
    }

    return (amount: null, rawStr: null);
  }

  // --- 3. RECIPIENT / STORE / BANK PARSER ---
  static ({String recipient, String? bank}) _parseStoreOrRecipient(
    List<String> lines,
    String fullText,
    String paymentMethod,
    List<String> matchedTokens,
  ) {
    String? foundBank;
    // Detect Bank if mentioned
    for (final bank in _vietnameseBanks) {
      final reg = RegExp('\\b${RegExp.escape(bank)}\\b', caseSensitive: false);
      if (reg.hasMatch(fullText)) {
        foundBank = bank;
        matchedTokens.add('Ngân hàng: $bank');
        break;
      }
    }

    // Pattern for Banking transfer recipient
    // "Người thụ hưởng: NGUYEN VAN A", "Tên người nhận: LE THI B", "Đến: HIGHLANDS COFFEE"
    final recipientKeywordPattern = RegExp(
      r'(?:tên\s*người\s*nhận|người\s*(?:thụ\s*hưởng|nhận)|đơn\s*vị\s*thụ\s*hưởng|tài\s*khoản\s*nhận|chuyển\s*(?:đến|tới)|đến\s*tài\s*khoản|beneficiary|tới|đến)\s*[:=]?\s*(.+)',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final match = recipientKeywordPattern.firstMatch(line);
      if (match != null) {
        String name = match.group(1)?.trim() ?? '';
        // If the label is on its own line and name is on next line:
        if (name.isEmpty && i + 1 < lines.length) {
          name = lines[i + 1].trim();
        }
        if (name.isNotEmpty && !name.contains(RegExp(r'^\d+$'))) {
          matchedTokens.add('Người nhận (keyword): $name');
          return (recipient: _cleanRecipientName(name), bank: foundBank);
        }
      }
    }

    // Pattern for UPPERCASE Beneficiary Name common in Vietnamese Banking Receipts:
    // e.g. "NGUYEN VAN HOANG", "CONG TY TNHH ABC"
    final uppercaseNamePattern = RegExp(r'^[A-ZÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬĐÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴ\s]{4,35}$');
    for (final line in lines) {
      if (uppercaseNamePattern.hasMatch(line)) {
        // Exclude system status like "GIAO DICH THANH CONG", "CHUYEN TIEN THANH CONG"
        final lower = line.toLowerCase();
        if (!lower.contains('thanh cong') &&
            !lower.contains('giao dich') &&
            !lower.contains('chuyen khoan') &&
            !lower.contains('chuyen tien') &&
            !lower.contains('vietqr') &&
            !lower.contains('vcb') &&
            !lower.contains('vietcombank') &&
            !lower.contains('techcombank') &&
            !lower.contains('mbbank')) {
          matchedTokens.add('Người nhận (UPPERCASE): $line');
          return (recipient: line, bank: foundBank);
        }
      }
    }

    // Check popular store brand names
    for (final store in _popularStores) {
      final reg = RegExp('\\b${RegExp.escape(store)}\\b', caseSensitive: false);
      if (reg.hasMatch(fullText)) {
        matchedTokens.add('Thương hiệu/Quán: $store');
        return (recipient: store, bank: foundBank);
      }
    }

    // Fallback: If it's a paper bill, store name is typically in the first 3 lines
    for (int i = 0; i < lines.length && i < 3; i++) {
      final line = lines[i];
      if (line.length >= 4 &&
          !line.contains(RegExp(r'\d{6,}')) &&
          !line.toLowerCase().contains('hóa đơn') &&
          !line.toLowerCase().contains('phiếu')) {
        return (recipient: line, bank: foundBank);
      }
    }

    return (recipient: foundBank != null ? 'Giao dịch qua $foundBank' : 'Chưa rõ', bank: foundBank);
  }

  static String _cleanRecipientName(String name) {
    return name
        .replaceAll(RegExp(r'^(stk|số tk|tk|tài khoản|stk:)\s*[\d\s]+', caseSensitive: false), '')
        .trim();
  }

  // --- 4. DATE PARSER ---
  static ({DateTime? date, String? rawStr}) _parseDate(
    List<String> lines,
    String fullText,
    List<String> matchedTokens,
  ) {
    // Pattern 1: dd/MM/yyyy or dd-MM-yyyy with optional HH:mm(:ss)
    final datePattern = RegExp(
      r'\b(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})(?:\s+[àa]t\s*|\s*,?\s*)?(\d{1,2}:\d{2}(?::\d{2})?)?',
      caseSensitive: false,
    );

    // Pattern 2: HH:mm(:ss) dd/MM/yyyy
    final timeFirstPattern = RegExp(
      r'\b(\d{1,2}:\d{2}(?::\d{2})?)\s+(?:ngày\s*)?(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})',
      caseSensitive: false,
    );

    for (final line in lines) {
      final m2 = timeFirstPattern.firstMatch(line);
      if (m2 != null) {
        final timeStr = m2.group(1)!;
        final d = m2.group(2)!;
        final m = m2.group(3)!;
        final y = m2.group(4)!;
        final combined = '$d/$m/$y $timeStr';
        final parsed = DateFormatter.parseVietnameseDate(combined);
        if (parsed != null) {
          matchedTokens.add('Thời gian: $combined');
          return (date: parsed, rawStr: combined);
        }
      }

      final m1 = datePattern.firstMatch(line);
      if (m1 != null) {
        final raw = m1.group(0)!;
        final parsed = DateFormatter.parseVietnameseDate(raw);
        if (parsed != null) {
          matchedTokens.add('Thời gian: $raw');
          return (date: parsed, rawStr: raw);
        }
      }
    }

    return (date: null, rawStr: null);
  }

  // --- 5. TRANSACTION CODE / REF ---
  static String? _parseTransactionCode(
    List<String> lines,
    String fullText,
    List<String> matchedTokens,
  ) {
    final pattern = RegExp(
      r'(?:mã\s*(?:giao\s*dịch|gd|tham\s*chiếu|đơn)|trace\s*no|ref(?:\s*no)?|ft)\s*[:=]?\s*([A-Za-z0-9_\-]+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = pattern.firstMatch(line);
      if (match != null) {
        final code = match.group(1);
        if (code != null && code.length >= 4) {
          matchedTokens.add('Mã GD: $code');
          return code;
        }
      }
    }

    return null;
  }

  // --- 6. TRANSFER NOTE / CONTENT ---
  static String? _parseTransferNote(List<String> lines, String fullText) {
    final pattern = RegExp(
      r'(?:nội\s*dung(?:\s*chuyển\s*khoản)?|lời\s*nhắn|diễn\s*giải|thông\s*tin\s*ck|message|desc)\s*[:=]?\s*(.+)',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final match = pattern.firstMatch(lines[i]);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        if (content.isEmpty && i + 1 < lines.length) {
          content = lines[i + 1].trim();
        }
        if (content.isNotEmpty) {
          return content;
        }
      }
    }
    return null;
  }

  // --- 7. AUTO CATEGORIZE (Dart 3 Pattern Matching & Heuristics) ---
  static ExpenseCategory _autoCategorize({
    required String store,
    String? note,
    required String rawText,
    String? bank,
  }) {
    final combined = '${store.toLowerCase()} ${note?.toLowerCase() ?? ''} ${rawText.toLowerCase()}';

    // 1. Food & Beverage
    if (combined.contains('cafe') ||
        combined.contains('coffee') ||
        combined.contains('trà sữa') ||
        combined.contains('highland') ||
        combined.contains('phúc long') ||
        combined.contains('katinat') ||
        combined.contains('cơm') ||
        combined.contains('phở') ||
        combined.contains('bún') ||
        combined.contains('quán') ||
        combined.contains('lẩu') ||
        combined.contains('nướng') ||
        combined.contains('pizza') ||
        combined.contains('kfc') ||
        combined.contains('lotteria') ||
        combined.contains('ăn uống') ||
        combined.contains('bánh')) {
      return ExpenseCategory.food;
    }

    // 2. Transport & Gas
    if (combined.contains('grab') ||
        combined.contains('be ') ||
        combined.contains('xanh sm') ||
        combined.contains('gojek') ||
        combined.contains('taxi') ||
        combined.contains('xăng') ||
        combined.contains('petrolimex') ||
        combined.contains('gửi xe') ||
        combined.contains('vé xe')) {
      return ExpenseCategory.transport;
    }

    // 3. Shopping & Supermarket
    if (combined.contains('winmart') ||
        combined.contains('circle k') ||
        combined.contains('gs25') ||
        combined.contains('ministop') ||
        combined.contains('7-eleven') ||
        combined.contains('siêu thị') ||
        combined.contains('co.opmart') ||
        combined.contains('shopee') ||
        combined.contains('lazada') ||
        combined.contains('tiki') ||
        combined.contains('quần áo') ||
        combined.contains('thời trang') ||
        combined.contains('shop') ||
        combined.contains('mart')) {
      return ExpenseCategory.shopping;
    }

    // 4. Utilities & Bills
    if (combined.contains('điện') ||
        combined.contains('nước') ||
        combined.contains('internet') ||
        combined.contains('viettel') ||
        combined.contains('fpt') ||
        combined.contains('vnpt') ||
        combined.contains('tiền nhà') ||
        combined.contains('học phí') ||
        combined.contains('bảo hiểm')) {
      return ExpenseCategory.utilities;
    }

    // 5. Entertainment
    if (combined.contains('cgv') ||
        combined.contains('lotte cinema') ||
        combined.contains('vé xem phim') ||
        combined.contains('bida') ||
        combined.contains('karaoke') ||
        combined.contains('du lịch') ||
        combined.contains('khách sạn')) {
      return ExpenseCategory.entertainment;
    }

    // 6. Personal Transfer / Banking
    if (combined.contains('chuyển khoản') ||
        combined.contains('trả tiền') ||
        combined.contains('góp') ||
        combined.contains('lì xì') ||
        combined.contains('vay') ||
        combined.contains('mượn')) {
      return ExpenseCategory.personal;
    }

    return ExpenseCategory.other;
  }
}

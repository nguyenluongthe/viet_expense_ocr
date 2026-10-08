import '../core/constants/categories.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../models/parsed_result.dart';

class HeuristicParser {
  // All Vietnamese Banking Entities & E-Wallets / Payment Services
  static final List<String> _vietnameseBanks = [
    // Big 4 & Commercial Banks in Vietnam
    'NHTMCP Ngoại Thương', 'Vietcombank', 'VCB',
    'NHTMCP Quân Đội', 'Ngân hàng Quân Đội', 'MBBank', 'MB Bank', 'MB',
    'NHTMCP Kỹ Thương', 'Techcombank', 'TCB',
    'NHTMCP Công Thương', 'VietinBank', 'Vietin Bank', 'CTG',
    'NHTMCP Đầu tư và Phát triển', 'BIDV',
    'Agribank', 'Nông nghiệp và Phát triển Nông thôn',
    'NHTMCP Việt Nam Thịnh Vượng', 'VPBank', 'VP Bank',
    'NHTMCP Tiên Phong', 'TPBank', 'TP Bank',
    'NHTMCP Á Châu', 'ACB',
    'NHTMCP Sài Gòn Thương Tín', 'Sacombank',
    'NHTMCP Phát triển TP.HCM', 'HDBank', 'HD Bank',
    'NHTMCP Sài Gòn - Hà Nội', 'SHB',
    'NHTMCP Quốc tế', 'VIB',
    'NHTMCP Hàng Hải', 'MSB', 'Maritime Bank',
    'NHTMCP Phương Đông', 'OCB',
    'NHTMCP Đông Nam Á', 'SeABank',
    'NHTMCP Xuất Nhập Khẩu', 'Eximbank',
    'NHTMCP Lộc Phát', 'LPBank', 'LienVietPostBank',
    'NHTMCP Nam Á', 'Nam A Bank',
    'NHTMCP Bắc Á', 'Bac A Bank',
    'NHTMCP Việt Á', 'Viet A Bank',
    'NHTMCP Kiên Long', 'Kienlongbank',
    'NHTMCP Bảo Việt', 'BaoViet Bank',
    'NHTMCP Sài Gòn Công Thương', 'Saigonbank',
    'NHTMCP Đại Chúng', 'PVcomBank',
    'NHTMCP Quốc Dân', 'NCB',
    'Shinhan Bank', 'HSBC', 'Standard Chartered', 'Citibank', 'UOB', 'Public Bank', 'Hong Leong', 'CIMB', 'Woori Bank', 'Indovina Bank',

    // Top E-Wallets & Digital Banks
    'MoMo', 'Ví MoMo', 'MoMo E-Wallet',
    'ZaloPay', 'Ví ZaloPay',
    'VNPay', 'VNPay-QR', 'VNPAY', 'Cổng VNPay',
    'ShopeePay', 'Ví ShopeePay', 'AirPay',
    'Viettel Money', 'ViettelPay', 'ViettelPay Pro',
    'VNPT Money', 'VNPT Pay',
    'Apple Pay', 'Google Pay', 'Samsung Pay',
    'VETC', 'ePass',
    'Timo', 'Cake', 'Cake by VPBank', 'TNEX', 'Liobank', 'Ubank',
    'PayOS', 'Napas', 'Napas 247', 'VietQR',
  ];

  static final List<String> _popularStores = [
    'Highlands Coffee', 'Highlands',
    'The Coffee House', 'Phúc Long', 'Phuc Long',
    'Katinat', 'Trung Nguyên', 'Starbucks', 'Cheese Coffee', 'Gong Cha', 'TocoToco', 'Mixue',
    'Circle K', 'WinMart', 'WinMart+', 'GS25', 'Ministop', 'FamilyMart', '7-Eleven',
    'Annam Gourmet', 'Co.opmart', 'Coopmart', 'Bách Hóa Xanh', 'Bach Hoa Xanh', 'Emart', 'Lotte Mart', 'Big C', 'GO!', 'Aeon', 'Aeon Mall',
    'Shopee', 'Lazada', 'Tiki', 'Grab', 'Be', 'Xanh SM', 'Gojek', 'TikTok Shop',
    'Cơm Tấm', 'Cơm Tấm Phúc Lộc Thọ', 'Phở 24', 'Lotteria', 'KFC', 'Jollibee', 'Pizza Hut', 'The Pizza Company', 'Gogi House', 'Kichi Kichi', 'Manwah', 'Haidilao',
    'Fahasa', 'Nhà sách Phương Nam', 'Tiền phòng', 'Tiền trọ', 'Điện lực EVN', 'Cấp nước',
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

    // Priority 1: Direct recipient keywords (Người nhận, Đến, Người thụ hưởng, Đơn vị nhận...)
    // Handles both same-line: "Đến: NGUYEN DANG DUC HUY" and multi-line: "Đến:" \n "NGUYEN DANG DUC HUY"
    final recipientKeywordPattern = RegExp(
      r'^(?:tên\s*người\s*nhận|người\s*(?:thụ\s*hưởng|nhận|hưởng)|đơn\s*vị\s*(?:thụ\s*hưởng|nhận)|tài\s*khoản\s*(?:nhận|thụ\s*hưởng|đến|hưởng)|chuyển\s*(?:đến|tới)|đến\s*tài\s*khoản|tới\s*tài\s*khoản|beneficiary|tới|đến)\s*[:=]?\s*(.*)$',
      caseSensitive: false,
    );

    // Exclusion keywords for sender or system labels
    final ignoreLinePattern = RegExp(
      r'^(?:từ|người\s*chuyển|người\s*gửi|tài\s*khoản\s*(?:nguồn|trích|chuyển)|nguồn\s*tiền|số\s*dư|phí\s*giao\s*dịch|phí\s*chuyển|giao\s*dịch\s*thành\s*công|chuyển\s*tiền\s*thành\s*công)\b',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (ignoreLinePattern.hasMatch(line)) continue;

      final match = recipientKeywordPattern.firstMatch(line);
      if (match != null) {
        String name = match.group(1)?.trim() ?? '';
        // If label was alone on line (e.g. "Đến:" or "Người thụ hưởng:"), look at next line
        if ((name.isEmpty || name == ':') && i + 1 < lines.length) {
          name = lines[i + 1].trim();
        }
        name = _cleanRecipientName(name);
        if (name.isNotEmpty && !RegExp(r'^\d+$').hasMatch(name) && !ignoreLinePattern.hasMatch(name)) {
          matchedTokens.add('Người nhận (keyword): $name');
          return (recipient: name, bank: foundBank);
        }
      }
    }

    // Priority 2: Look for UPPERCASE beneficiary name (e.g. "NGUYEN DANG DUC HUY")
    final uppercaseNamePattern = RegExp(r'^[A-ZÀÁẢÃẠĂẮẰẲẴẶÂẤẦẨẪẬĐÈÉẺẼẸÊẾỀỂỄỆÌÍỈĨỊÒÓỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢÙÚỦŨỤƯỨỪỬỮỰỲÝỶỸỴ\s]{4,35}$');
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (uppercaseNamePattern.hasMatch(line)) {
        final lower = line.toLowerCase();
        // Exclude system status & bank names
        if (!lower.contains('thanh cong') &&
            !lower.contains('giao dich') &&
            !lower.contains('chuyen khoan') &&
            !lower.contains('chuyen tien') &&
            !lower.contains('vietqr') &&
            !lower.contains('vcb') &&
            !lower.contains('vietcombank') &&
            !lower.contains('techcombank') &&
            !lower.contains('mbbank') &&
            !lower.contains('bidv') &&
            !lower.contains('quan doi') &&
            !lower.contains('dong a') &&
            !lower.contains('vietinbank') &&
            !lower.contains('agribank') &&
            !lower.contains('sacombank')) {
          // Check if previous line was a sender label (skip if sender)
          if (i > 0 && RegExp(r'^(?:từ|người\s*chuyển|người\s*gửi|tài\s*khoản\s*nguồn)', caseSensitive: false).hasMatch(lines[i - 1].trim())) {
            continue;
          }
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
      r'^(?:mã\s*(?:giao\s*dịch|gd|tham\s*chiếu|đơn)|số\s*tham\s*chiếu|trace\s*no|ref(?:\s*no)?|ft)\s*[:=]?\s*(.*)$',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final match = pattern.firstMatch(line);
      if (match != null) {
        String code = match.group(1)?.trim() ?? '';
        if ((code.isEmpty || code == ':') && i + 1 < lines.length) {
          code = lines[i + 1].trim();
        }
        if (code.isNotEmpty && code.length >= 4 && !code.contains(' ')) {
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
      r'^(?:nội\s*dung(?:\s*chuyển\s*khoản)?|lời\s*nhắn|diễn\s*giải|thông\s*tin\s*ck|message|desc)\s*[:=]?\s*(.*)$',
      caseSensitive: false,
    );

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      final match = pattern.firstMatch(line);
      if (match != null) {
        String content = match.group(1)?.trim() ?? '';
        if ((content.isEmpty || content == ':') && i + 1 < lines.length) {
          content = lines[i + 1].trim();
        }
        if (content.isNotEmpty && !content.toLowerCase().startsWith('số tham chiếu')) {
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
    // Check store / recipient / note first with high priority
    final primaryContext = _removeDiacritics('${store.toLowerCase()} ${note?.toLowerCase() ?? ''}');
    final fullContext = _removeDiacritics('$primaryContext ${rawText.toLowerCase()}');

    // 1. Shopping & Supermarket (Check supermarkets / malls first before generic words)
    final shoppingRegex = RegExp(
      r'\b(winmart|circle k|gs25|ministop|7-eleven|7 eleven|sieu thi|co\.opmart|coopmart|bach hoa xanh|shopee|lazada|tiki|tiktok shop|quan ao|thoi trang|my pham|mua sam|tap hoa|store|shop|mart)\b',
      caseSensitive: false,
    );
    if (shoppingRegex.hasMatch(primaryContext) || shoppingRegex.hasMatch(fullContext)) {
      return ExpenseCategory.shopping;
    }

    // 2. Transport & Gas (Grab, Be, Xanh SM, Gojek, VETC, Taxi, Vé xe)
    final transportRegex = RegExp(
      r'\b(grab|be|xanh sm|gojek|taxi|xang|petrolimex|gui xe|ve xe|vetc|epass|may bay|flight|vietnam airlines|vietjet|shopee food driver)\b',
      caseSensitive: false,
    );
    if (transportRegex.hasMatch(primaryContext) || transportRegex.hasMatch(fullContext)) {
      return ExpenseCategory.transport;
    }

    // 3. Food & Beverage (Ăn uống, cafe, trà sữa, quán ăn, phở, bún, cơm...)
    final foodRegex = RegExp(
      r'\b(cafe|coffee|tra sua|tra chanh|highland|phuc long|katinat|starbuck|the coffee house|com|pho|bun|quan an|lau|nuong|pizza|kfc|lotteria|jollibee|an uong|an trua|an toi|an sang|tien an|do an|thuc pham|nuoc uong|banh|nhau|food|drink|dinner|lunch|breakfast)\b',
      caseSensitive: false,
    );
    // Avoid matching 'com' from 'techcombank' or 'commerce'
    final cleanContextWithoutBankNames = primaryContext
        .replaceAll('techcombank', '')
        .replaceAll('saigonbank', '')
        .replaceAll('pvcombank', '');
    if (foodRegex.hasMatch(cleanContextWithoutBankNames)) {
      return ExpenseCategory.food;
    }
    final fullCleanContext = fullContext
        .replaceAll('techcombank', '')
        .replaceAll('saigonbank', '')
        .replaceAll('pvcombank', '');
    if (foodRegex.hasMatch(fullCleanContext)) {
      return ExpenseCategory.food;
    }

    // 4. Utilities & Bills (Điện, nước, internet, học phí, tiền nhà)
    final utilitiesRegex = RegExp(
      r'\b(dien|nuoc|evn|cap nuoc|internet|viettel|fpt|vnpt|tien nha|tien tro|hoc phi|bao hiem|chung cu|phi dich vu)\b',
      caseSensitive: false,
    );
    if (utilitiesRegex.hasMatch(primaryContext) || utilitiesRegex.hasMatch(fullContext)) {
      return ExpenseCategory.utilities;
    }

    // 5. Entertainment (Xem phim, du lịch, bida, game)
    final entertainmentRegex = RegExp(
      r'\b(cgv|lotte cinema|ve xem phim|cinema|bida|karaoke|du lich|khach san|hotel|resort|netflix|spotify|game|steam)\b',
      caseSensitive: false,
    );
    if (entertainmentRegex.hasMatch(primaryContext) || entertainmentRegex.hasMatch(fullContext)) {
      return ExpenseCategory.entertainment;
    }

    // 6. Personal Transfer / Banking (Chuyển khoản cá nhân, trả nợ, lì xì)
    final personalRegex = RegExp(
      r'\b(chuyen khoan|tra tien|tra no|gop|li xi|vay|muon)\b',
      caseSensitive: false,
    );
    if (personalRegex.hasMatch(primaryContext) || personalRegex.hasMatch(fullContext)) {
      return ExpenseCategory.personal;
    }

    return ExpenseCategory.other;
  }

  static String _removeDiacritics(String str) {
    const withDia = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDia = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyydAAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';
    var result = str;
    for (int i = 0; i < withDia.length; i++) {
      result = result.replaceAll(withDia[i], withoutDia[i]);
    }
    return result;
  }
}

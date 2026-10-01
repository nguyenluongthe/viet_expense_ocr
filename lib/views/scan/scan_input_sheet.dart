import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../services/ocr_service.dart';
import '../../widgets/sample_receipt_selector.dart';
import 'verification_screen.dart';

class ScanInputSheet extends StatefulWidget {
  const ScanInputSheet({super.key});

  @override
  State<ScanInputSheet> createState() => _ScanInputSheetState();
}

class _ScanInputSheetState extends State<ScanInputSheet> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;

  Future<void> _handleImagePick(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (photo == null) return;

      setState(() => _isProcessing = true);

      // Process with Edge AI Offline OCR
      final parsedResult = await OcrService.instance.processImageFile(photo.path);

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // Navigate to Verification UI
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            parsedResult: parsedResult,
            imagePath: photo.path,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi xử lý hình ảnh: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _handlePresetSelect(SampleTransaction sample) {
    setState(() => _isProcessing = true);

    // Process with Heuristic Engine
    final parsedResult = OcrService.instance.processRawText(sample.rawText);

    setState(() => _isProcessing = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(
          parsedResult: parsedResult,
        ),
      ),
    ).then((saved) {
      if (saved == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  void _showPasteTextDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Dán nội dung giao dịch / SMS', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Dán nội dung thông báo biến động số dư, SMS banking hoặc bill text:',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'VD: GD thanh cong: -65.000VND tai HIGHLANDS COFFEE...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('HỦY', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final txt = textController.text.trim();
                if (txt.isEmpty) return;
                final nav = Navigator.of(context);
                nav.pop();

                final parsed = OcrService.instance.processRawText(txt);
                nav.push(
                  MaterialPageRoute(
                    builder: (context) => VerificationScreen(parsedResult: parsed),
                  ),
                ).then((saved) {
                  if (saved == true && mounted) {
                    nav.pop(true);
                  }
                });
              },
              child: const Text('PHÂN TÍCH REGEX'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nhập giao dịch / Biên lai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Chọn ảnh chụp màn hình chuyển khoản VietQR, banking hoặc bill:',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),

          if (_isProcessing)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  CircularProgressIndicator(color: AppTheme.primary),
                  SizedBox(height: 14),
                  Text(
                    'Đang trích xuất OCR & Regex Heuristics...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            )
          else ...[
            // Hardware Input Buttons
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Chụp ảnh',
                    subtitle: 'Camera máy',
                    color: AppTheme.primary,
                    onTap: () => _handleImagePick(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Thư viện ảnh',
                    subtitle: 'Ảnh chụp màn hình',
                    color: AppTheme.accent,
                    onTap: () => _handleImagePick(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.text_snippet_rounded,
                    label: 'Dán Text/SMS',
                    subtitle: 'Nhập tay nhanh',
                    color: const Color(0xFFF59E0B),
                    onTap: _showPasteTextDialog,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.border),
            const SizedBox(height: 10),

            // Preset Vietnamese Banking Transfer Mockups
            const Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded, size: 16, color: AppTheme.primary),
                SizedBox(width: 6),
                Text(
                  'HOẶC THỬ NHANH MẪU CHUYỂN KHOẢN VIỆT NAM (PRESETS):',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: SampleReceiptData.presets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final preset = SampleReceiptData.presets[index];
                  return InkWell(
                    onTap: () => _handlePresetSelect(preset),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.receipt_rounded, size: 18, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  preset.subtitle,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

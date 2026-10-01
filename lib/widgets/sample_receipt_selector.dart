class SampleTransaction {
  final String title;
  final String subtitle;
  final String rawText;
  final String mockStore;
  final double mockAmount;

  const SampleTransaction({
    required this.title,
    required this.subtitle,
    required this.rawText,
    required this.mockStore,
    required this.mockAmount,
  });
}

class SampleReceiptData {
  static const List<SampleTransaction> presets = [
    SampleTransaction(
      title: 'Vietcombank - Quét VietQR Cà phê',
      subtitle: 'HIGHLANDS COFFEE • 65.000 VND',
      mockStore: 'HIGHLANDS COFFEE',
      mockAmount: 65000,
      rawText: '''
Vietcombank Digibank
CHUYỂN TIỀN THÀNH CÔNG
Quét mã VietQR - 247
Số tiền: 65.000 VND
Bằng chữ: Sáu mươi lăm nghìn đồng
Người nhận: HIGHLANDS COFFEE
Ngân hàng: Ngân hàng Ngoại Thương (Vietcombank)
Thời gian: 01/10/2026 09:15:30
Mã giao dịch: VCB918237192
Nội dung: Thanh toan 2 ly Freeze tra xanh
      ''',
    ),
    SampleTransaction(
      title: 'MB Bank - Chuyển khoản ăn trưa',
      subtitle: 'CƠM TẤM PHÚC LỘC THỌ • 85k',
      mockStore: 'CƠM TẤM PHÚC LỘC THỌ',
      mockAmount: 85000,
      rawText: '''
MB Bank - Giao dịch thành công
Chuyển khoản liên ngân hàng 24/7
Số tiền giao dịch: -85.000 VND
Tên người nhận: CƠM TẤM PHÚC LỘC THỌ
Tại ngân hàng: MBBank
Thời gian: 30/09/2026 12:35
Mã GD: MB9921827419
Nội dung chuyển khoản: Com tam bi cha va canh
      ''',
    ),
    SampleTransaction(
      title: 'Techcombank - Siêu thị WinMart',
      subtitle: 'WINMART VINHOMES • 145.000 đ',
      mockStore: 'WINMART VINHOMES',
      mockAmount: 145000,
      rawText: '''
TECHCOMBANK
CHUYỂN KHOẢN TỚI TÀI KHOẢN
Thanh toán: 145.000 đ
Người thụ hưởng: WINMART VINHOMES
Tài khoản nhận: 190348271891
Ngân hàng: Techcombank
Thời gian thực hiện: 29/09/2026 18:40:22
Mã tham chiếu: FT262729182
Nội dung: Mua do tieu dung thiet yeu
      ''',
    ),
    SampleTransaction(
      title: 'Hóa đơn giấy POS - Cửa hàng tiện lợi',
      subtitle: 'CIRCLE K • 45k (Tổng cộng: 45.000 đ)',
      mockStore: 'CIRCLE K',
      mockAmount: 45000,
      rawText: '''
CIRCLE K VIETNAM
Cửa hàng 128 Nguyễn Thị Minh Khai, Q3, TP.HCM
PHIẾU THANH TOÁN
1. Bánh mì que: 18.000
2. Nước ngọt Coca: 15.000
3. Kẹo cao su: 12.000
--------------------------------
Tổng cộng: 45.000 đ
Thanh toán: 45k
Ngày: 28/09/2026 21:10
Mã đơn: CK-98124
Cảm ơn quý khách và hẹn gặp lại!
      ''',
    ),
    SampleTransaction(
      title: 'Ví MoMo - Đặt xe Xanh SM',
      subtitle: 'XANH SM BIKE • 38.000 VND',
      mockStore: 'XANH SM BIKE',
      mockAmount: 38000,
      rawText: '''
MoMo - Thanh toán thành công
Dịch vụ: Di chuyển XANH SM
Số tiền: 38.000 VND
Đơn vị thụ hưởng: CONG TY CP DI DONG XANH VA THONG MINH GSM
Thời gian: 27/09/2026 08:05:12
Mã giao dịch: MOMO9182371
Hình thức: Ví điện tử MoMo
      ''',
    ),
  ];
}

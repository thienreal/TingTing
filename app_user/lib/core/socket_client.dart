/// File: socket_client.dart
/// Module: CoreFeature
/// Description: Singleton quản lý kết nối WebSocket (Socket.IO) giữa User App
///   và Backend TingTing. Nhận thông báo real-time khi có điểm mới được cộng.
///
/// Responsibility:
///   - Kết nối tới WebSocket server tại WEBSOCKET_PORT (3001)
///   - Emit sự kiện `join` với userId sau khi kết nối để đăng ký nhận thông báo
///   - Lắng nghe sự kiện `points_earned` và truyền ra ngoài qua callback
///   - Ngắt kết nối khi user đăng xuất hoặc app đóng
///
/// Dependencies:
///   - socket_io_client: ^3.0.2 (pub.dev)
///   - api_client.dart (lấy host LAN)
///
/// Todo:
///   - [ ] Tự động reconnect khi mất mạng
///   - [ ] Gửi JWT trong handshake auth thay vì emit join riêng (bảo mật hơn cho Production)

// ignore_for_file: avoid_print
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'api_client.dart';

// ==========================================
// KIỂU DỮ LIỆU
// ==========================================

/// Payload nhận được khi có điểm mới được cộng vào tài khoản.
/// Tương ứng với PointsEarnedPayload ở backend.
class PointsEarnedData {
  final int pointsEarned;
  final int newTotalPoints;
  final String newMembershipTier;
  final bool tierUpgraded;
  final String merchantName;

  const PointsEarnedData({
    required this.pointsEarned,
    required this.newTotalPoints,
    required this.newMembershipTier,
    required this.tierUpgraded,
    required this.merchantName,
  });

  factory PointsEarnedData.fromJson(Map<String, dynamic> json) {
    return PointsEarnedData(
      pointsEarned: (json['points_earned'] as num).toInt(),
      newTotalPoints: (json['new_total_points'] as num).toInt(),
      newMembershipTier: json['new_membership_tier'] as String,
      tierUpgraded: json['tier_upgraded'] as bool,
      merchantName: json['merchant_name'] as String,
    );
  }
}

// ==========================================
// SINGLETON SOCKET CLIENT
// ==========================================

/// Service quản lý kết nối WebSocket dưới dạng Singleton.
/// Gọi [connect] sau khi đăng nhập thành công, [disconnect] khi đăng xuất.
class SocketClient {
  SocketClient._internal();
  static final SocketClient _instance = SocketClient._internal();

  /// Truy cập instance duy nhất của SocketClient
  static SocketClient get instance => _instance;

  io.Socket? _socket;

  // ==========================================
  // KẾT NỐI
  // ==========================================

  /// Kết nối tới WebSocket server và đăng ký nhận thông báo cho userId.
  ///
  /// Gọi hàm này ngay sau khi user đăng nhập thành công.
  /// Nếu đã kết nối trước đó, hàm sẽ ngắt kết nối cũ và kết nối lại.
  ///
  /// [userId] — UUID của user đang đăng nhập, dùng để join room nhận notification.
  void connect(String userId) {
    // Ngắt kết nối cũ nếu có để tránh duplicate socket
    disconnect();

    // Lấy host từ api_client, thay port 3000 → 3001 (WEBSOCKET_PORT)
    final baseUrl = ApiClient.getBaseUrl();
    final wsUrl = baseUrl.replaceFirst(':3000', ':3001');

    _socket = io.io(
      wsUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          // Không tự reconnect vô hạn để tránh spam kết nối khi server down
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );

    // ==========================================
    // XỬ LÝ SỰ KIỆN SOCKET
    // ==========================================

    _socket!.onConnect((_) {
      print('[WS] Đã kết nối tới server: $_socket?.id');
      // Ngay sau khi kết nối, emit join để server ánh xạ userId → socketId
      _socket!.emit('join', {'userId': userId});
    });

    _socket!.on('join_ack', (data) {
      print('[WS] Đăng ký nhận thông báo thành công: $data');
    });

    _socket!.onDisconnect((_) {
      print('[WS] Đã ngắt kết nối khỏi server');
    });

    _socket!.onConnectError((error) {
      print('[WS] Lỗi kết nối: $error');
    });

    _socket!.onError((error) {
      print('[WS] Lỗi socket: $error');
    });
  }

  // ==========================================
  // ĐĂNG KÝ LẮNG NGHE SỰ KIỆN
  // ==========================================

  /// Đăng ký callback để nhận dữ liệu khi sự kiện `points_earned` được phát.
  ///
  /// Gọi hàm này sau [connect] để bắt đầu nhận thông báo điểm.
  /// Callback nhận [PointsEarnedData] đã được parse sẵn.
  ///
  /// [callback] — Hàm xử lý khi có điểm mới, nhận 1 tham số [PointsEarnedData].
  void onPointsEarned(void Function(PointsEarnedData data) callback) {
    if (_socket == null) {
      print('[WS] Chưa kết nối — bỏ qua đăng ký listener points_earned');
      return;
    }

    _socket!.on('points_earned', (rawData) {
      try {
        // rawData có thể là Map hoặc dynamic — cần cast an toàn
        final json = Map<String, dynamic>.from(rawData as Map);
        final data = PointsEarnedData.fromJson(json);
        callback(data);
      } catch (e) {
        print('[WS] Lỗi parse points_earned payload: $e');
      }
    });
  }

  // ==========================================
  // NGẮT KẾT NỐI
  // ==========================================

  /// Ngắt kết nối WebSocket và giải phóng socket.
  /// Gọi khi user đăng xuất hoặc app bị dispose.
  void disconnect() {
    if (_socket != null) {
      _socket!.dispose();
      _socket = null;
      print('[WS] Đã ngắt kết nối và giải phóng socket');
    }
  }

  /// Kiểm tra xem socket đang kết nối hay không
  bool get isConnected => _socket?.connected ?? false;
}

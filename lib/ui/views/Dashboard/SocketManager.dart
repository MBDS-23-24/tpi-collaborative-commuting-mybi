import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();

  late IO.Socket socket;
  final String _url = 'http://localhost:3001';

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal() {
    socket = IO.io(_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
  }

  void connect() {
    if (!socket.connected) {
      socket.connect();
    }
  }

  void disconnect() {
    if (socket.connected) {
      socket.disconnect();
    }
  }
}

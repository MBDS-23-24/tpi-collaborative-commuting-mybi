import 'dart:convert';
import 'package:web_socket_channel/io.dart';

class SignalingClient {
  final String url;
  IOWebSocketChannel? channel;
  Function(dynamic)? onSignal;

  SignalingClient(this.url);

  void connect() {
    channel = IOWebSocketChannel.connect(url);
    channel!.stream.listen((message) {
      onSignal?.call(jsonDecode(message));
    });
  }

  void sendSignal(dynamic data) {
    channel?.sink.add(jsonEncode(data));
  }

  void close() {
    channel?.sink.close();
  }
}

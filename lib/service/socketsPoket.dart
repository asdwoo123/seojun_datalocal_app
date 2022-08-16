import 'package:socket_io_client/socket_io_client.dart' as IO;


class SocketsPoket {
  List<IO.Socket> _sockets = [];

  List<IO.Socket> get sockets => _sockets;

  set sockets(List<IO.Socket> s0ckets) {
    _sockets = sockets;
  }

  static final SocketsPoket _instance = SocketsPoket._internal();

  factory SocketsPoket() => _instance;

  SocketsPoket._internal() {}
}

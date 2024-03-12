
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/io.dart';

class webRtcManager {
  late RTCPeerConnection _peerConnection;
  final _iceServers = {
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
      {
        'url': 'turn:TURN_SERVER_URL',
        'username': 'TURN_SERVER_USERNAME',
        'credential': 'TURN_SERVER_CREDENTIAL'
      },
    ]
  };

  final _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  // Remplacer par votre URL de serveur WebSocket pour signaling
  final _channel = IOWebSocketChannel.connect('wss://integrationlalabi.azurewebsites.net:443');

  // Remplacer par votre URL de serveur WebSocket pour signaling
  /*
  late IO.Socket socket;
  socket = IO.io('wss://integrationlalabi.azurewebsites.net:443', <String, dynamic>{


  'transports': ['websocket'],
  'autoConnect': false,
  });

  socket.connect();
  */

  Future<void> initWebRTC() async {
    _peerConnection = await createPeerConnection(_iceServers, _config);

    _peerConnection.onIceCandidate = (candidate) {
      // Envoyer le candidat ICE au pair via WebSocket
      _sendSignal('new-ice-candidate', candidate.toMap());
    };

    // Écouter les messages du serveur de signaling
    _channel.stream.listen((message) {
      final signal = jsonDecode(message);
      switch (signal['type']) {
        case 'offer':
        // Traiter l'offre reçue
          break;
        case 'answer':
        // Traiter la réponse reçue
          break;
        case 'new-ice-candidate':
        // Ajouter le candidat ICE reçu
          break;
      // Autres cas...
      }
    });

    // Ajoutez ici la logique pour créer/accepter des offres et réponses
  }


  Future<void> _initPeerConnection() async {
    _peerConnection = await createPeerConnection(_iceServers, _config);
    // Configurez ici votre _peerConnection, par exemple, en définissant les gestionnaires d'événements.
  }

  Future<RTCDataChannel> createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel dataChannel = await _peerConnection.createDataChannel(
        'locationChannel', dataChannelDict);

    dataChannel.onMessage = (RTCDataChannelMessage message) {
      final data = jsonDecode(message.text);
      print("Localisation reçue : ${data['latitude']}, ${data['longitude']}");
      // Ici, vous pouvez traiter la localisation reçue selon vos besoins.
    };

    return dataChannel;
  }




  void _sendSignal(String type, dynamic data) {
    final signal = jsonEncode({'type': type, 'data': data});
    _channel.sink.add(signal);
  }

}
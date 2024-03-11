

class MessageModel {
  int id;
  int? receiver;
  int? sender;
  String message;
  DateTime time;

  MessageModel(this.id, this.sender, this.receiver, this.message, this.time);

  Map<String, dynamic> toJson() => {
    'senderId' : sender,
    'receiverId': receiver,
    'content': message
// Ajoutez d'autres champs ici
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
        json['messageId'],
        json['senderId'],
        json['receiverId'],
        json['content'],
        DateTime.parse(json['timestamp']),
       // json['type']
    );
  }
}
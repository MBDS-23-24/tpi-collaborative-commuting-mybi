class LatestMessageModel{
  final int? senderId;
  final int? receiverId;
  final String content;
  final String timestamp;

  LatestMessageModel({this.senderId, this.receiverId, required this.content, required this.timestamp});

  factory LatestMessageModel.fromJson(Map<String, dynamic> json) {
    return LatestMessageModel(
      timestamp: json['latestTimestamp'],
      content: json['content'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
    );
  }

}
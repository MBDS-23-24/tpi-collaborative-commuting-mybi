import 'dart:html';

class MessageModel {
  int id;
  int receiver;
  int sender;
  String message;
  DateTime time;

  MessageModel(this.id, this.receiver, this.sender, this.message, this.time);
}
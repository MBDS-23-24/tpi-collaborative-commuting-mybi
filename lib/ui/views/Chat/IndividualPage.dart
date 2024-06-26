// import 'package:camera/camera.dart';
// import 'package:chatapp/CustomUI/CameraUI.dart';



//import 'package:emoji_picker/emoji_picker.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:tpi_mybi/Data/DataManager.dart';

import 'package:tpi_mybi/model/User.dart';

import '../../../Components/OwnMessageCard.dart';
import '../../../Components/ReplyCard.dart';
import '../../../Components/Tools/Utils.dart';
import '../../../Data/DataLoader.dart';
import 'Meesage.dart';

class IndividualPage extends StatefulWidget {
  IndividualPage({ required this.chatModel, required this.sourchat});
  final UserModel chatModel;
  final UserModel sourchat;
  @override
  _IndividualPageState createState() => _IndividualPageState();
}



class _IndividualPageState extends State<IndividualPage> {


  bool show = false;
  FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<MessageModel> messages = [];
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late IO.Socket socket;

  String getRandomImagePath() {
    List<String> images = [
      "assets/covoiturage.png",
      "assets/covoiturage2.png",
      "assets/covoiturage3.jpg"
    ];
    int randomIndex = Random().nextInt(images.length);
    return images[randomIndex];
  }

  @override
  void initState() {
    super.initState();

    DataManager.instance.addListener(_onResponse);
     // connect();
    DataLoader.instance.getMessages(widget.sourchat.userID, widget.chatModel.userID);
    /*
    setState(() {
      messages.add(messageModel);
    });
     */

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
     connect();
  }

/*
  @override
  void dispose() {
    super.dispose();
    DataManager.instance.removeListener(_onResponse);

    socket.emit("disconnect");
    socket.disconnect();
    socket.close();

  }
  */

  void _onResponse(DataManagerUpdateType type) {
    if (type == DataManagerUpdateType.getMessagesSuccess) {
      // chatmodels = DataManager.instance.getUsers();
      setState(() {
        messages = DataManager.instance.getMessages();
      });

    }
  }

  void connect() {
   // MessageModel messageModel = MessageModel(0, widget.chatModel.uid, widget.sourchat.uid,  );

    socket = IO.io("wss://lalabi.azurewebsites.net:443", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
      "upgrade": false
    });
    socket.connect();
    socket.on("connect", (data) {
      print("Connection Successfully Established...");
     // onSocketConnected(socketIO);
    });
   // socket.emit("/test","hello world");

    socket.emit("signin", widget.sourchat.userID);
    //socket.onConnect((data) => print("connected"));
    //socket.emit("/signin",/* widget.sourchat.uid*/ 1);
    socket.onConnect((data) {
      print("Connected");
      socket.on("message", (msg) {
        print(msg);
        setMessage("destination", msg["message"], widget.chatModel.userID, widget.sourchat.userID);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
    print(socket.connected);

  }

  void sendMessage(String message, int? sourceId, int? targetId) {
    setMessage("source", message,  sourceId, targetId);
    /*socket.emit("message",
        {"messageId": 0, "senderId": sourceId, "receiverId": targetId, "content": message, "timestamp": DateTime.now()});

     */
   print("message sourceId ="+sourceId.toString() + " targetId ="+targetId.toString());
    socket.emit("message",
        {"message": message, "sourceId": sourceId, "targetId": targetId});
    DataLoader.instance.postMessage(message,targetId,sourceId);
   // socket.emit("/test",message);
  }

  void setMessage(String type, String message, int? sourceId, int? targetId) {
    MessageModel messageModel = MessageModel(
          0,
        sourceId,
        targetId,
         message,
        DateTime.now(),
        );
    _controller.clear();

    setState(() {
      messages.add(messageModel);
    });
    print("messages");
    print(messages);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
      /*  Image.asset(
          "assets/messagewal.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.contain, // Modifiez ceci pour voir les différentes options
        ),*/
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ), CircleAvatar(
                      backgroundImage: AssetImage(getRandomImagePath()),
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                    ),/*
                    CircleAvatar(
                      child: Image.network(

                        widget.chatModel.pathImage != null
                            ? "assets/facebook.png"
                            : "assets/facebook.png",
                        color: Color(0xFF3FCC69),
                        height: 36,
                        width: 36,
                      ),
                      radius: 20,
                      backgroundColor: Colors.blueGrey,
                    ),
                    */
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.all(6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatModel.lastName.toString() +
                            " " +
                            widget.chatModel.firstName.toString(),
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      /*Text(
                        "last seen today at 12:05",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )*/

                      /*Text(
                        "last seen today at 12:05",
                        style: TextStyle(
                          fontSize: 13,
                        ),
                      )

                       */
                    ],
                  ),
                ),
              ),
            /*  actions: [
              //  IconButton(icon: Icon(Icons.videocam), onPressed: () {}),
              //  IconButton(icon: Icon(Icons.call), onPressed: () {}),
                PopupMenuButton<String>(
                  padding: EdgeInsets.all(0),
                  onSelected: (value) {
                    print(value);
                  },
                  itemBuilder: (BuildContext contesxt) {
                    return [
                      PopupMenuItem(
                        child: Text("View Contact"),
                        value: "View Contact",
                      ),
                      PopupMenuItem(
                        child: Text("Media, links, and docs"),
                        value: "Media, links, and docs",
                      ),
                      PopupMenuItem(
                        child: Text("Whatsapp Web"),
                        value: "Whatsapp Web",
                      ),
                      PopupMenuItem(
                        child: Text("Search"),
                        value: "Search",
                      ),
                      PopupMenuItem(
                        child: Text("Mute Notification"),
                        value: "Mute Notification",
                      ),
                      PopupMenuItem(
                        child: Text("Wallpaper"),
                        value: "Wallpaper",
                      ),
                    ];
                  },
                ),
              ],

             */
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: WillPopScope(
              child: Column(
                children: [
                  Expanded(
                    // height: MediaQuery.of(context).size.height - 150,
                    child: ListView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemCount: messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return Container(
                            height: 70,
                          );
                        }
                        if (messages[index].sender == widget.sourchat.userID){
                          return OwnMessageCard(
                            message: messages[index].message,
                            time: Utils.convertirFormatDate(messages[index].time.toString()), key: "",
                          );
                        } else {
                          return ReplyCard(
                            message: messages[index].message,
                            time: Utils.convertirFormatDate(messages[index].time.toString()),
                          );
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width - 60,
                                child: Card(
                                  margin: EdgeInsets.only(
                                      left: 2, right: 2, bottom: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: TextFormField(
                                    controller: _controller,
                                    focusNode: focusNode,
                                    textAlignVertical: TextAlignVertical.center,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    onChanged: (value) {
                                      if (value.length > 0) {
                                        setState(() {
                                          sendButton = true;
                                        });
                                      } else {
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Type a message",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      prefixIcon: IconButton(
                                        icon: Icon(
                                          show
                                              ? Icons.keyboard
                                              : Icons.keyboard,
                                        ),
                                        onPressed: () {
                                          if (!show) {
                                            focusNode.unfocus();
                                            focusNode.canRequestFocus = false;
                                          }
                                          setState(() {
                                            show = !show;
                                          });
                                        },
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          /*    IconButton(
                                            icon: Icon(Icons.attach_file),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                  backgroundColor:
                                                  Colors.transparent,
                                                  context: context,
                                                  builder: (builder) =>
                                                      bottomSheet());
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.camera_alt),
                                            onPressed: () {
                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (builder) =>
                                              //             CameraApp()));
                                            },
                                          ),*/
                                        ],
                                      ),
                                      contentPadding: EdgeInsets.all(5),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 8,
                                  right: 2,
                                  left: 2,
                                ),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Color(0xFF128C7E),
                                  child: IconButton(
                                    icon: Icon(
                                      sendButton ? Icons.send : Icons.cancel_schedule_send,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      if (sendButton) {
                                        _scrollController.animateTo(
                                            _scrollController
                                                .position.maxScrollExtent,
                                            duration:
                                            Duration(milliseconds: 300),
                                            curve: Curves.easeOut);
                                            sendMessage(
                                            _controller.text,
                                            widget.sourchat.userID,
                                            widget.chatModel.userID);
                                        setState(() {
                                          sendButton = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                         /* show ? emojiSelect() : Container(),*/
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onWillPop: () {
                if (show) {
                  setState(() {
                    show = false;
                  });
                } else {
                  Navigator.pop(context);
                }
                return Future.value(false);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, Colors.indigo, "Document"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.insert_photo, Colors.purple, "Gallery"),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.headset, Colors.orange, "Audio"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.location_pin, Colors.teal, "Location"),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.person, Colors.blue, "Contact"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }

  Widget emojiSelect() {
    return Text("Hello");
    /*EmojiPicker(
        rows: 4,
        columns: 7,
        onEmojiSelected: (emoji, category) {
          print(emoji);
          setState(() {
            _controller.text = _controller.text + emoji.emoji;
          });
        });*/
  }
}
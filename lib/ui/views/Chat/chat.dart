
import 'package:flutter/material.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';

import '../../../Components/CustomCard.dart';
import '../../../Data/DataLoader.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(/*{ required this.chatmodels, required this.sourchat}*/) ;
   late List<UserModel> chatmodels;
   late UserModel sourchat;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}



class _ChatScreenState extends State<ChatScreen> {

   List<UserModel> _chatModels = [];
   late DataManager dataManager;
  @override
  void initState() {
    super.initState();
    DataLoader dataLoader = DataLoader.instance;
     dataManager = DataManager.instance;
    dataLoader.getUsers(dataManager.getToken());
    dataManager.addListener(_onResponse);
  }

 @override
  void dispose() {
    super.dispose();
    dataManager.removeListener(_onResponse);
  }

  void _onResponse(DataManagerUpdateType type) {
    if (type == DataManagerUpdateType.getUsersSuccess) {
      // chatmodels = DataManager.instance.getUsers();
      setState(() {
        _chatModels = DataManager.instance.getUsers();
      });

    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          /*Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => SelectContact(
                        sourchat: widget.sourchat,
                      )));*/
        },
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
      ),
      body:
     // Text("Chat"),

      ListView.builder(
        itemCount:_chatModels.length,
        itemBuilder: (contex, index) =>
            
            CustomCard(
          chatModel: DataManager.instance.getUsers()[index],
          sourchat: DataManager.instance.getUser(), key : UniqueKey(),
        ),
        //Text("hello"),
      ),
    );
  }
}

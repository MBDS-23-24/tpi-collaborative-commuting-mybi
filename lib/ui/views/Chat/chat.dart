
import 'package:flutter/material.dart';
import 'package:tpi_mybi/Data/DataManager.dart';
import 'package:tpi_mybi/model/User.dart';
import 'package:tpi_mybi/ui/views/Chat/LatestMessageModel.dart';

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

   List<LatestMessageModel> _chatModels = [];
   List<UserModel> _userModels = [];

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
        _userModels = DataManager.instance.getUsers();
      });

    }
    else if (type == DataManagerUpdateType.getLatestMessagesSuccess){
      setState(() {
        _chatModels = DataManager.instance.getLatestMessages();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mes messages',
          style: TextStyle(color: Color(0xFF3FCC69)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
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
        itemCount: _chatModels.length,
        itemBuilder: (context, index) {
          final currentUser = DataManager.instance.getUser();
          UserModel? senderUser;

          for (var user in DataManager.instance.getUsers()) {
            if (user.userID == _chatModels[index].senderId && user.userID != currentUser.userID){
              senderUser = user;
              break; // Sort de la boucle une fois que l'utilisateur est trouvé
            }
          }

          // Ajoutez votre condition if ici
          if (senderUser != null) {
            return CustomCard(
              chatModel: senderUser,
              sourchat: currentUser,
              key: UniqueKey(),
              content: _chatModels[index].content,
              timestamp: _chatModels[index].timestamp,
            );
          } else {
            return SizedBox.shrink(); // Retourne un widget vide si l'utilisateur n'existe pas
          }
        },
      ),

    );
  }
}

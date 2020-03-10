import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final _auth = FirebaseAuth.instance;


  final messageTextController = TextEditingController();

  String messageText;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();

  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();

      if (user != null) {
        loggedInUser = user;
        print(loggedInUser.email);
      }
    }catch(e){
      print(e);
    }
  }

//

//  void messagesStream() async {
//
//     await for(var snapshot in _fireStore.collection('messages').snapshots()){
//       for(var message in snapshot.documents){
//         print(message.data);
//       }
//     }
//
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
//                messagesStream();
                //Implement logout functionality
                _auth.signOut();
                Navigator.pop(context);
              //getMessaages();

              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                        // messageText + loggedInUser.email
                      _fireStore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messages').snapshots(),
        builder: (context, snapshot){
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,

              ),
            );
          }
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageBubbles = [];
          for(var message in messages ){
            final messageText = message.data['text'];
            final messageSender = message.data['sender'];

            final currentUser = loggedInUser.email;
            
            if (currentUser == messageSender) {
              //The message is going to be from the logged in user

            }  

            final messageBubble = MessageBubble(sender: messageSender, text: messageText, isMe: currentUser == messageSender,);

            messageBubbles.add(messageBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageBubbles,
            ),
          );
        }
    );
  }
}



class MessageBubble extends StatelessWidget {

  MessageBubble({this.text,this.sender, this.isMe});

  final String sender;
  final String text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(sender, style: TextStyle(fontSize: 12, color: Colors.black54),),
          Material(
            borderRadius: isMe ? BorderRadius.only(topLeft: Radius.circular(30), bottomLeft: Radius.circular(30), bottomRight: Radius.circular((30)))
                : BorderRadius.only(bottomRight: Radius.circular(30), bottomLeft: Radius.circular(30), topRight: Radius.circular((30))) ,
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical :10.0, horizontal: 20),
              child: Text('$text',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black54
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chatapp/components/%20chat_bubble.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receriverEmail;
  final String receiverId;

  ChatPage({super.key, required this.receriverEmail, required this.receiverId});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // text controller
  final TextEditingController _messageController = TextEditingController();

  // chat & auth service instance
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // for text field focus
  final FocusNode myfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // add listener to focus Node
    myfocusNode.addListener(() {
      if (myfocusNode.hasFocus) {
        // cause a delay so that the keyboard has time to show up
        // the amount of remaing space will be calculated
        // them scroll downn
        Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
      }
    });

    // wait a bit for listview to be built, then scroll down to bottom
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  // wait a bit for listview to be built, then scroll down to bottom

  @override
  void dispose() {
    myfocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // scroll down function
  final ScrollController _scrollController = ScrollController();
  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message function
  void _sendMessage() async {
    // if there is somthing inside the text field
    if (_messageController.text.isNotEmpty) {
      // send message
      await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text,
      );
    }
    // clear text field
    _messageController.clear();
    // scroll down
    scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receriverEmail),
        centerTitle: true,
        backgroundColor: Colors.transparent,

        // foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // display all the message
          Expanded(child: buildMessageList()),

          // user input
          buildMessageInput(),
        ],
      ),
    );
  }

  // build message list
  Widget buildMessageList() {
    String currentUserId = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(currentUserId, widget.receiverId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        // loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // return list view
        return ListView(
          controller: _scrollController,
          children: snapshot.data!.docs
              .map((doc) => _buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  // build each message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    //is curent user
    bool isCurrentUser = data['senderId'] == _authService.getCurrentUser()!.uid;

    // align message to the right if sender is the current user, otherwise left
    var alignment = isCurrentUser
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment: isCurrentUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data['message'],
            isCurrentUser: isCurrentUser,
            messageId: doc.id,
            userId: data['senderId'],
          ),
        ],
      ),
    );
  }

  // build message input
  Widget buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          // textfield
          Expanded(
            child: MyTextfield(
              controller: _messageController,
              hintText: 'Type a message',
              obscureText: false,
              focusNode: myfocusNode,
            ),
          ),
          SizedBox(width: 10),

          // send icon
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              // shape: BoxShape.circle,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(right: 15),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:chat_flutter/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {


  final TextEditingController _textController = new TextEditingController();
  final _focusNode = new FocusNode();
  bool _estaEscribiendo = false;


  List <ChatMessage> _messages = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text('Te', style: TextStyle(fontSize: 12),),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 3),
            Text('Melisa Flores', style: TextStyle(fontSize: 12, color: Colors.black87),)
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _messages[index];
                },
              ),
            ),
            const Divider(height: 1),

            Container(
              color: Colors.white,
              child: _inputChat(),
            )
            // _Input(),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handreSubmit,
                onChanged: ( String text ) {
                  setState(() {
                    if (text.trim().length > 0) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(color: Colors.black38)
                ),
                focusNode: _focusNode,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Platform.isIOS 
                ? CupertinoButton(
                  child: const Text('Enviar'),
                  onPressed: _estaEscribiendo
                    ? () => _handreSubmit(_textController.text.trim())
                    : null,
                )
                : Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: IconTheme(
                    data: IconThemeData(color: Colors.blue[400]),
                    child: IconButton(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: const Icon(Icons.send),
                      onPressed: _estaEscribiendo
                        ? () => _handreSubmit(_textController.text.trim())
                        : null,
                    ),
                  ),
                ),
            
            )
          ],
        ),
    ),);

  }


  _handreSubmit (String text) {

    if ( text.length == 0 ) return;

    print(text);

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text,
      uid: '123',
      animationController: AnimationController(
        duration: Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _messages.insert(0, newMessage);

    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });
  }

  @override
  void dispose() {
    // TODO: off del socket
    for ( ChatMessage message in _messages ) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
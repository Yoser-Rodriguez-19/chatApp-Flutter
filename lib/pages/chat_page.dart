import 'dart:io';

import 'package:chat_flutter/models/mensajes_response.dart';
import 'package:chat_flutter/services/auth_service.dart';
import 'package:chat_flutter/services/chat_service.dart';
import 'package:chat_flutter/services/socket_service.dart';
import 'package:chat_flutter/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {


  final TextEditingController _textController = new TextEditingController();
  final _focusNode = new FocusNode();
  bool _estaEscribiendo = false;

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;


  List <ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket.on('mensaje-personal', _escucharMensaje);

    _cargarHistorial( chatService.usuarioPara.uid );
    
  }

  void _cargarHistorial(String usuarioID) async {

    List<Mensaje> chat = await chatService.getChat(usuarioID);

    final historial = chat.map( (mensaje) =>  ChatMessage(
      text: mensaje.mensaje,
      uid: mensaje.de,
      animationController:  AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 0)
      )..forward()
    )).toList();

    setState(() {
      _messages.insertAll(0, historial);
    });


  }


  void _escucharMensaje(dynamic payload){
    print('Mensaje recibido: ${payload}');

    ChatMessage message = ChatMessage(
      text: payload['mensaje'],
      uid: payload['de'],
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200)
      ),
    );

    setState(() {
      _messages.insert(0, message);
    });

    message.animationController.forward();

    // ChatMessage message = ChatMessage(
    //   text: payload['mensaje'],
    //   uid: payload['de'],
    //   animationController: AnimationController(
    //     vsync: this,
    //     duration: const Duration(milliseconds: 200)
    //   ),
    // );
    // setState(() {
    //   _messages.insert(0, message);
    // });
    // message.animationController.forward();
  }


  @override
  Widget build(BuildContext context) {

    final usuarioPara = chatService.usuarioPara;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text(usuarioPara.nombre.substring(0,2), style: TextStyle(fontSize: 12),),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            const SizedBox(height: 3),
            Text(usuarioPara.nombre, style: TextStyle(fontSize: 12, color: Colors.black87),)
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
                onSubmitted: _handleSubmit,
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
                    ? () => _handleSubmit(_textController.text.trim())
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
                        ? () => _handleSubmit(_textController.text.trim())
                        : null,
                    ),
                  ),
                ),
            
            )
          ],
        ),
    ),);

  }


  _handleSubmit (String text) {

    if ( text.length == 0 ) return;

    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text,
      uid: authService.usuario!.uid,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );

    _messages.insert(0, newMessage);

    newMessage.animationController.forward();

    setState(() {
      _estaEscribiendo = false;
    });

    socketService.emit('mensaje-personal', {
      'de': authService.usuario!.uid,
      'para': chatService.usuarioPara.uid,
      'mensaje': text
    });

  }

  @override
  void dispose() {
    for ( ChatMessage message in _messages ) {
      message.animationController.dispose();
    }
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
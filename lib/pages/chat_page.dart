import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  @override
  State<ChatPage> createState() => _ChatPageState();
}

//with para usar la animación
class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  //al hacer ésto quiere decir que ya puedo trabajar con animaciones
  final _textController = new TextEditingController();
  final _focusNode = new FocusNode();
  List<ChatMessage> _messages = [];
  bool _estaEscribiendo = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            CircleAvatar(
              child: Text(
                'Te',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            SizedBox(height: 3),
            Text(
              'Melissa Flores',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 1,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            //necesitamos un widget que sea capaz de expandirse
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            Divider(height: 1),
            //TODO: Caja de texto
            Container(
              color: Colors.white,
              child: _inputChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            //vamos a usar un Flexible para que la caja de texto ocupe todo el espacio posible
            Flexible(
              child: TextField(
                controller: _textController,
                //cuando se haga un submit de éste campo voy a manejar el posteo
                onSubmitted: _handleSubmit,
                onChanged: (texto) {
                  //TODO: saber cuando está escribiendo
                  setState(() {
                    if (texto.trim().length > 0) {
                      _estaEscribiendo = true;
                    } else {
                      _estaEscribiendo = false;
                    }
                  });
                },
                decoration:
                    InputDecoration.collapsed(hintText: 'Enviar mensaje'),
                //quiero que vuelva el foco a la caja de texto cuando preisono enviar
                focusNode: _focusNode,
              ),
            ),
            //botón para enviar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              //el child va a depender de la plataforma en que me encuentro
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: Text('Enviar'),
                      onPressed: _estaEscribiendo
                          ? () => _handleSubmit(_textController.text.trim())
                          : null,
                    )
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        //iconTheme para que cuando se active el color sea azul y no tenga el negro por defecto
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          //vamos a quitar el efecto que tiene al presionar el botón para enviar
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: Icon(Icons.send),
                          onPressed: _estaEscribiendo
                              ? () => _handleSubmit(_textController.text.trim())
                              : null,
                        ),
                      )),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String texto) {
    //cuando está vacío que no haga nada
    if (texto.length == 0) return;
    //y no hace nada
    print(texto);
    //limpiamos la caja de texto porque el mensaje ya se envió
    _textController.clear();
    //mandamos el foco de nuevo a la caja de texto
    //no desaparece el teclado al enviar el mensaje
    _focusNode.requestFocus();
    //CREAMOS UNA NUEVA INSTANCIA DE CHATMESSAGE
    final newMessage = new ChatMessage(
      uid: '123',
      texto: texto,
      //le pasamos el animationController
      //este this lo obtenemos gracias al mixin con animationController
      animationController: AnimationController(
          vsync: this, duration: Duration(milliseconds: 200)),
    );

    //agregamos el mensaje al arreglo
    _messages.insert(0, newMessage);
    //iniciamos la animación del mensaje
    newMessage.animationController!.forward();
    setState(() {
      _estaEscribiendo = false;
    });
  }

  //vamos a llamar al dispose cuando ya no utilicemos los controladores
  @override
  void dispose() {
    // TODO: Limpiamos off del socket
    //limpiamos las instancias de nuestro arreglo de mensajes porque puede todo ese
    //montón de controladores que estamos creando nos consuma mucha memoria
    for (ChatMessage message in _messages) {
      message.animationController!.dispose();
      //cuando se cierra la ventana del chat se ejecuta el dispose
    }
    super.dispose();
  }
}

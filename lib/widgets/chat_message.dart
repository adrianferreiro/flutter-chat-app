import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  final String? texto;
  final String? uid;
  final AnimationController? animationController;

  const ChatMessage({
    Key? key,
    @required this.texto,
    @required this.uid,
    @required this.animationController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animationController!,
      child: SizeTransition(
        //sizetransition me ayuda a animar con el tamaño
        sizeFactor: CurvedAnimation(
          parent: animationController!,
          //curve define como queremos que sea la animación
          //lento al principio y rápido al final por ej
          curve: Curves.easeOut,
        ),
        child: Container(
          //tenemos que saber quien es el que manda el mesaje para mostrar la burbuja determinada
          //si yo mandé el mensaje, color azul - sino color gris
          child: this.uid == '123' ? _myMessage() : _notMyMessage(),
        ),
      ),
    );
  }

  Widget _myMessage() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(right: 5, bottom: 5, left: 50),
        child: Text(
          this.texto!,
          style: TextStyle(color: Colors.white),
        ),
        decoration: BoxDecoration(
          color: Color(0xff4D9EF6),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _notMyMessage() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 5, bottom: 5, right: 50),
        child: Text(
          this.texto!,
          style: TextStyle(color: Colors.black87),
        ),
        decoration: BoxDecoration(
          color: Color(0xffE4E5E8),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}

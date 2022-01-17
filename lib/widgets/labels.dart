import 'package:flutter/material.dart';

class Labels extends StatelessWidget {
  final String? ruta;
  final String? tituloUno;
  final String? tituloDos;

  const Labels({
    Key? key,
    @required this.ruta,
    @required this.tituloUno,
    @required this.tituloDos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            this.tituloUno!,
            style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w300),
          ),
          SizedBox(height: 10),
          GestureDetector(
            //me permite poner cualquier gesto y reconocerlo (ej. onTap)
            child: Text(
              this.tituloDos!,
              style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, this.ruta!);
            },
          )
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  //Variables
  bool _isComposing = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              decoration:
                  InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {},
            ),
          ),
          IconButton(
            color: Colors.blue,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _isComposing ? () {} : null,
          )
        ],
      ),
    );
  }
}

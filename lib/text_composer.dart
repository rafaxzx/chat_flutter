import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  final void Function({String message, File imgFile}) _sendMessage;

  TextComposer(this._sendMessage);

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  //Controles
  final TextEditingController _txtControllerMessage = TextEditingController();
  //Variáveis
  bool _isComposing = false;
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () async {
              final _pickedImage = await _picker.getImage(source: ImageSource.camera);
              final _pickedImageFile = File(_pickedImage.path);
              if (_pickedImageFile == null) return;
              widget._sendMessage(imgFile: _pickedImageFile);
              setState(() {
                _reset();
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _txtControllerMessage,
              decoration: InputDecoration.collapsed(hintText: 'Enviar uma mensagem'),
              onChanged: (text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                //Chama a função passada por parâmetro com o texto do TextField
                //depois limpa o campo e reseta o estado do icone
                widget._sendMessage(message: text);
                _reset();
              },
            ),
          ),
          IconButton(
            color: Colors.blue,
            icon: Icon(
              Icons.send,
            ),
            onPressed: _isComposing
                ? () {
                    //Chama a função passada por parâmetro com o texto do TextField
                    //depois limpa o campo e reseta o estado do icone
                    widget._sendMessage(message: _txtControllerMessage.text);
                    _reset();
                  }
                : null,
          )
        ],
      ),
    );
  }

  void _reset() {
    _txtControllerMessage.clear();
    setState(() {
      _isComposing = false;
    });
  }
}

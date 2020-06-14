import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  //Variaveis
  final Map<String, dynamic> data;
  final bool mine;

  ChatMessage(this.data, this.mine);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: <Widget>[
          !mine
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(backgroundImage: NetworkImage(data['senderPhotoUrl'])),
                )
              : Container(),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: <Widget>[
                  data['imgUrl'] != null
                      ? Image.network(
                          data['imgUrl'],
                          width: 250,
                        )
                      : Text(
                          data['message'],
                          textAlign: mine ? TextAlign.right : TextAlign.left,
                          style: TextStyle(fontSize: 16),
                        ),
                  Text(
                    data['senderName'],
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          mine
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(backgroundImage: NetworkImage(data['senderPhotoUrl'])),
                )
              : Container()
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:chatflutter/chat_message.dart';
import 'package:chatflutter/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //Overrides
  @override
  void initState() {
    super.initState();

    //Criar um listener para verificar quando o user mudar e obter esse user
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  //Variáveis
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _keyScaffoldState = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  //Funções
  void _sendMessage({String message, File imgFile}) async {
    //Obter usuario
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _keyScaffoldState.currentState.showSnackBar(SnackBar(
        content: Text('Você precisa estar logado, reinicie o App'),
        duration: Duration(seconds: 4),
      ));
    }

    Map<String, dynamic> data = {
      'uid': user.uid,
      'senderName': user.displayName,
      'senderPhotoUrl': user.photoUrl,
      'time': Timestamp.now()
    };

    if (imgFile != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if (message != null) data['message'] = message;

    Firestore.instance.collection('messages').add(data);
  }

  Future<FirebaseUser> _getUser() async {
    //Caso já tiver um usuário logado
    if (_currentUser != null) return _currentUser;
    try {
      //Passos para fazer Login com o Google
      //Obter uma conta Google
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      //Obter dados de autenticação da conta obtida anteriormente
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      //Obter credenciais a partir dos dados de autenticação obtidos anteriormente
      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      //Resultado do Login com as credenciais obtidas anteriormente
      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(authCredential);

      //Usuario Firebase autenticado
      final FirebaseUser user = authResult.user;

      //Retornar o usuario obtido
      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _keyScaffoldState,
      appBar: AppBar(
        centerTitle: true,
        title: Text(_currentUser != null ? 'Olá, ${_currentUser.displayName}' : 'Chat App'),
        elevation: 0.0,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _keyScaffoldState.currentState
                        .showSnackBar(SnackBar(content: Text('Você fez logoff')));
                  },
                )
              : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child:
                            Container(height: 200, width: 200, child: CircularProgressIndicator()),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                      return ListView.builder(
                          reverse: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            return ChatMessage(documents[index].data,
                                documents[index].data['uid'] == _currentUser?.uid);
                          });
                  }
                }),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}

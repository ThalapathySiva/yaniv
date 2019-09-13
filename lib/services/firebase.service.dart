import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:yaniv/models/game.model.dart';

import '../models/player.model.dart';

class FirebaseService {
  static final FirebaseService _singleton = new FirebaseService._internal();
  final Firestore _db = Firestore.instance;
  String email;

  factory FirebaseService() {
    return _singleton;
  }

  FirebaseService._internal();

  // @TODO improve this, maybe by using stream instead?
  setEmail(String email) {
    this.email = email;
  }

  Stream<Game> getGame(String id) {
    return _db
        .collection('games')
        .document(this.email)
        .collection('games')
        .document(id)
        .snapshots()
        .map((game) {
      List<dynamic> playersJson = game['players'];

      List<Player> players = playersJson.map((player) {
        return Player.fromJSON(new Map.from(player));
      }).toList();

      return new Game(
        completed: game['completed'],
        id: game.documentID,
        createdAt: game['createdAt'],
        players: players,
      );
    });
  }

  // @TODO do the map magic in here and return Stream<List<Game>>
  Stream<QuerySnapshot> getGames() {
    return _db
        .collection('games')
        .document(this.email)
        .collection('games')
        .snapshots();
  }

  Future<String> createNewGame() async {
    DocumentReference ref = await _db
        .collection('games')
        .document(this.email)
        .collection('games')
        .add({
      'completed': false,
      'createdAt': Timestamp.now(),
      'players': [],
    });

    return ref.documentID;
  }

  Future<String> addPlayerToGame(String gameId, String name) async {
    DocumentReference ref = _db
        .collection('games')
        .document(this.email)
        .collection('games')
        .document(gameId);

    List<dynamic> players = List.from((await ref.get()).data['players']);
    players.insert(players.length, {'name': name, 'points': 0});

    await ref.setData({
      'players': players,
    }, merge: true);

    return ref.documentID;
  }
}
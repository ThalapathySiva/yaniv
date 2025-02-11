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

  Future<void> deleteGame(String gameId) async {
    return _db
        .collection('games')
        .document(this.email)
        .collection('games')
        .document(gameId)
        .delete();
  }

  Future<String> addPlayerToGame(String gameId, String name) async {
    DocumentReference ref = _db
        .collection('games')
        .document(email)
        .collection('games')
        .document(gameId);

    List<dynamic> players = List.from((await ref.get()).data['players']);
    players.insert(players.length, {'name': name, 'points': 0});

    await ref.setData({
      'players': players,
    }, merge: true);

    return ref.documentID;
  }

  Future<void> completeGame(String gameId) async {
    // @OTOD implement
  }

  int _calculatePoints(int oldPoints, int pointsToAdd) {
    int newPoints = oldPoints + pointsToAdd;
    if (newPoints == 100 || newPoints == 150) {
      return newPoints - 50;
    }
    if (newPoints == 200) {
      return 100;
    }
    return newPoints;
  }

  Future<void> addPointsToPlayer(String gameId, String name, int points) async {
    DocumentReference ref = _db
        .collection('games')
        .document(email)
        .collection('games')
        .document(gameId);

    List<dynamic> players = (await ref.get()).data['players'];

    players.forEach((player) {
      if (player['name'] == name) {
        int updatedPoints = _calculatePoints(player['points'], points);
        if (updatedPoints > 200) {
          completeGame(gameId);
        }
        player['points'] = updatedPoints;
      }
    });

    debugPrint(players.toString());

    await ref.setData({
      'players': players,
    }, merge: true);
  }
}

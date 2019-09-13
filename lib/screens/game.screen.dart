import 'package:flutter/material.dart';
import 'package:yaniv/components/add-player.component.dart';

import 'package:yaniv/components/players.component.dart';
import 'package:yaniv/models/game.model.dart';
import 'package:yaniv/services/firebase.service.dart';

class GameScreen extends StatelessWidget {
  final FirebaseService firebaseService = FirebaseService();
  final String gameId;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  GameScreen({this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game scores"),
      ),
      body: StreamBuilder(
          stream: firebaseService.getGame(this.gameId),
          builder: (BuildContext context, AsyncSnapshot<Game> snapshot) {
            if (!snapshot.hasData) {
              return new Center(child: new CircularProgressIndicator());
            }

            Game game = snapshot.data;

            if (game.players.length == 0) {
              return Center(
                  child: Text('No players added, go ahead and add some!'));
            } else {
              return PlayersComponent(
                players: game.players,
                gameId: gameId,
              );
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (context) => new AddPlayer(gameId: this.gameId));
        },
        tooltip: 'Add player',
        child: Icon(Icons.add),
      ),
    );
  }
}

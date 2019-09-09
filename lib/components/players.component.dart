import 'package:flutter/material.dart';
import 'package:yaniv/components/score-form.component.dart';

import 'package:yaniv/models/player.model.dart';

class PlayersComponent extends StatelessWidget {
  PlayersComponent({this.players});

  final List<Player> players;

  void _handleTappedPlayer(Player player, BuildContext context) {
    debugPrint(player.name);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        child: ScoreFormComponent(player: player),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: players.length,
      separatorBuilder: (BuildContext context, int index) => const Divider(),
      itemBuilder: (BuildContext context, int index) {
        Player player = players[index];

        return Container(
          child: ListTile(
            leading: Text(
              player.points.toString(),
              style: TextStyle(fontSize: 18.0),
            ),
            title: Text(player.name),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => _handleTappedPlayer(player, context),
          ),
        );
      },
    );
  }
}

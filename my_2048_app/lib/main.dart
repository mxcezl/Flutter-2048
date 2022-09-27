import 'package:flutter/material.dart';
import 'package:my_2048_app/grid_moved_result.dart';
import 'package:my_2048_app/tile_types.dart';
import 'action_manager.dart';
import 'tile_manager.dart';
import 'constants.dart' as Constants;

Future<void> main() async {
  runApp(MaterialApp(
    title: '2048',
    home: HomePageGame(
      key: UniqueKey(),
    ),
  ));
}

class HomePageGame extends StatefulWidget {
  const HomePageGame({super.key});

  @override
  State<StatefulWidget> createState() => HomePageGameState();
}

class HomePageGameState extends State<HomePageGame> {
  late List<Widget> tiles;
  static const int matriceSize = 4;
  int score = 0;
  int best_score = 0;

  @override
  void initState() {
    super.initState();
    tiles = TileManager.generateInitList();
  }

  /// This function is called when the user swipe the screen.
  /// It will move the tiles in the direction of the swipe
  /// and add a new tile if possible.
  void _onSwipe(String direction) {
    GridMovedResult result = ActionManager.performMovement(tiles, direction);
    if (result.isGameEnded) {
      _showEndGameDialog();
    }

    if (result.isGridChanged) {
      setState(() {
        tiles = result.tiles;
        score += result.score;
        if (score > best_score) {
          best_score = score;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int sensitivity = 250;
    double width = MediaQuery.of(context).size.width;
    width = width - (width * 0.07);
    return Container(
        color: const Color.fromRGBO(252, 249, 240, 1),
        alignment: Alignment.center,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(50.0)),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                score.toString(),
                style: const TextStyle(
                  color: Color.fromRGBO(119, 110, 101, 1),
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              Container(
                height: width,
                width: width,
                alignment: Alignment.center,
                color: const Color.fromRGBO(187, 173, 160, 1),
                child: GestureDetector(
                  onVerticalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dy < -sensitivity) {
                      _onSwipe(Constants.UP);
                    } else if (details.velocity.pixelsPerSecond.dy >
                        sensitivity) {
                      _onSwipe(Constants.DOWN);
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (details.velocity.pixelsPerSecond.dx < -sensitivity) {
                      _onSwipe(Constants.LEFT);
                    } else if (details.velocity.pixelsPerSecond.dx >
                        sensitivity) {
                      _onSwipe(Constants.RIGHT);
                    }
                  },
                  child: GridView.count(
                      key: UniqueKey(),
                      shrinkWrap: true,
                      primary: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(10),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: matriceSize,
                      children: tiles),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("Meilleur score : ${best_score.toString()}",
                      style: const TextStyle(
                        color: Color.fromRGBO(119, 110, 101, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(187, 173, 160, 1),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          score = 0;
                          tiles = TileManager.generateInitList();
                        });
                      },
                      child: const Text("Restart")),
                ],
              ),
            ])));
  }

  void _showEndGameDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Game Over"),
            content: Text("Votre score est de ${score.toString()}"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      score = 0;
                      tiles = TileManager.generateInitList();
                    });
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }
}

class StatefulColorfulTile extends StatefulWidget {
  final Color color;
  final int value;
  final String strValue;

  const StatefulColorfulTile(
      {Key? key,
      required this.color,
      required this.value,
      required this.strValue})
      : super(key: key);

  @override
  ColorfulTileState createState() => ColorfulTileState();

  static StatefulColorfulTile fromValueTile(int value) {
    return StatefulColorfulTile(
        key: UniqueKey(),
        color: TileTypes.tiles[value]!,
        value: value,
        strValue: value.toString());
  }

  static StatefulColorfulTile emptyTile(Key key) {
    return StatefulColorfulTile(
      key: key,
      color: TileTypes.tiles[0]!,
      value: 0,
      strValue: "",
    );
  }
}

class ColorfulTileState extends State<StatefulColorfulTile> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        child: Container(
            key: UniqueKey(),
            color: widget.color,
            alignment: Alignment.center,
            child: Text(
              widget.strValue,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  decoration: TextDecoration.none,
                  fontSize: 50,
                  color: Colors.black,
                  backgroundColor: Colors.transparent),
            )));
  }
}

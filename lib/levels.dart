import 'package:blinky_bulb/globals.dart';
import 'package:blinky_bulb/complete_board.dart';

List<CompleteRound> getLevels() {
  List<CompleteRound> levels = [];
//figure out how to output a CompleteBoard...
  levels.add(new CompleteRound(new CompleteBoard(), [], []));

  levels.add(CompleteRound(
      CompleteBoard(4, 5, 4, true, false, [
        [
          NodeType(0, false),
          NodeType(0, false),
          NodeType(0, false),
          NodeType(0, false),
          NodeType(0, false)
        ],
        [
          NodeType(0, false),
          NodeType(0, false),
          NodeType(2, false),
          NodeType(0, false),
          NodeType(0, false)
        ],
        [
          NodeType(0, false),
          NodeType(0, false),
          NodeType(2, false),
          NodeType(0, false),
          NodeType(0, false)
        ],
        [
          NodeType(1, false, false, false, false, false, false, false, true,
              true, false, false),
          NodeType(1, false, false, false, false, false, false, false, true,
              false, false, false),
          NodeType(0, false),
          NodeType(1, false, false, false, false, false, false, false, true,
              false, false, false),
          NodeType(0, false)
        ]
      ]),
      [Node(0, 0), Node(0, 2), Node(0, 3), Node(3, 4)],
      [Node(3, 0), Node(3, 1)]));

  return levels;
}

CompleteRound levelDecompressor(String lvlString) {
  CompleteRound cRound;
  return cRound;
}

class Levels {
  List metaP = [];
  List boardP = [];
  List arrowsP = [];
  List solutionP = [];
  List bannedP = [];

  int getMaxLevel() {
    return metaP.length;
  }

  CompleteRound loadLevel(int levelNum) {
    int rows = metaP[levelNum][0];
    int cols = metaP[levelNum][1];
    int selectionsMax = metaP[levelNum][2];
    bool cornerStart = metaP[levelNum][3] == 1 ? true : false;
    bool isHex = metaP[levelNum][4] == 1 ? true : false;

    List<List<NodeType>> gBoard = [];
    int aSpot = 0;
    int subSpot = 0;
    for (int x = 0; x < rows; x++) {
      gBoard.add([]);
      for (int y = 0; y < cols; y++) {
        if (boardP[levelNum][x][y] != 1) {
          gBoard[x].add(NodeType(boardP[levelNum][x][y], isHex));
        } else {
          List<bool> arrows = [];
          for (int z = 0; z < 10; z++) {
            if (subSpot < arrowsP[levelNum][aSpot].length &&
                arrowsP[levelNum][aSpot][subSpot] == z + 2) {
              arrows.add(true);
              subSpot++;
            } else {
              arrows.add(false);
            }
          }
          subSpot = 0;
          aSpot++;
          gBoard[x].add(NodeType(
              boardP[levelNum][x][y],
              isHex,
              arrows[0],
              arrows[1],
              arrows[2],
              arrows[3],
              arrows[4],
              arrows[5],
              arrows[6],
              arrows[7],
              arrows[8],
              arrows[9]));
        }
      }
    }
    List<Node> solutions = [];
    for (int x = 0; x < solutionP[levelNum].length; x += 2) {
      solutions.add(Node(solutionP[levelNum][x], solutionP[levelNum][x + 1]));
    }
    List<Node> bans = [];
    for (int x = 0; x < bannedP[levelNum].length; x += 2) {
      bans.add(Node(bannedP[levelNum][x], bannedP[levelNum][x + 1]));
    }
    return CompleteRound(
        CompleteBoard(rows, cols, selectionsMax, cornerStart, isHex, gBoard),
        solutions,
        bans);
  }

  Levels() {
    //*******************
    metaP.add([4, 5, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0],
      [0, 0, 2, 0, 0],
      [0, 0, 2, 0, 0],
      [1, 1, 0, 1, 0]
    ]);
    arrowsP.add([
      [8, 9],
      [8],
      [8]
    ]);
    solutionP.add([0, 0, 0, 2, 0, 3, 3, 4]);
    bannedP.add([3, 0, 3, 1]);
//*******************
    metaP.add([10, 5, 5, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 1, 2],
      [0, 2, 2, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [2, 2, 0, 2, 2]
    ]);
    arrowsP.add([
      [2, 7]
    ]);
    solutionP.add([3, 0, 3, 4, 7, 0, 7, 4, 8, 1]);
    bannedP.add([1, 0]);
//******************* needs to be checked
    metaP.add([7, 5, 4, 1, 1]);
    boardP.add([
      [0, 2, 0, 2, 0],
      [2, 2, 2, 2, 2],
      [0, 2, 1, 2, 0],
      [2, 0, 2, 0, 2],
      [1, 2, 1, 2, 0],
      [2, 2, 2, 2, 2],
      [0, 2, 0, 2, 0]
    ]);
    arrowsP.add([
      [6],
      [2],
      [2]
    ]);
    solutionP.add([3, 1, 3, 3, 4, 0, 4, 2]);
    bannedP.add([]);
//*******************
    metaP.add([5, 5, 5, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 2],
      [0, 0, 0, 0, 0],
      [2, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0]
    ]);
    arrowsP.add([]);
    solutionP.add([1, 1, 2, 1, 3, 3, 3, 4, 4, 4]);
    bannedP.add([]);
//*******************
    metaP.add([7, 6, 4, 1, 0]);
    boardP.add([
      [2, 1, 1, 0, 1, 2],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [2, 0, 0, 1, 0, 2]
    ]);
    arrowsP.add([
      [10],
      [10],
      [10],
      [8, 9, 10, 11],
      [8, 9, 10, 11],
      [8]
    ]);
    solutionP.add([2, 2, 2, 4, 3, 2, 5, 2]);
    bannedP.add([]);

//***Easy but fun early level ****************
    metaP.add([5, 6, 4, 1, 0]);
    boardP.add([
      [0, 0, 2, 2, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [1, 1, 1, 1, 1, 1]
    ]);
    arrowsP.add([
      [8],
      [8],
      [8],
      [8],
      [8],
      [8]
    ]);
    solutionP.add([1, 1, 2, 0, 4, 1, 4, 5]);
    bannedP.add([]);
//*******************
    metaP.add([5, 7, 4, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 1, 2, 1, 2, 1, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2]
    ]);
    arrowsP.add([
      [2, 3, 4, 5, 6, 7],
      [2, 3, 4, 5, 6, 7],
      [2, 3, 4, 5, 6, 7]
    ]);
    solutionP.add([0, 3, 3, 4, 3, 6, 4, 3]);
    bannedP.add([]);
//*******************
    metaP.add([7, 5, 4, 1, 1]);
    boardP.add([
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 1, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 1, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0]
    ]);
    arrowsP.add([
      [3, 4, 5, 6, 7],
      [2, 3, 4, 6, 7]
    ]);
    solutionP.add([0, 0, 2, 2, 3, 1, 3, 3]);
    bannedP.add([]);
//*******************
    metaP.add([5, 5, 4, 0, 1]);
    boardP.add([
      [2, 2, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2]
    ]);
    arrowsP.add([]);
    solutionP.add([1, 4, 2, 3, 3, 0, 4, 1]);
    bannedP.add([]);
//*******************
    metaP.add([11, 3, 4, 0, 1]);
    boardP.add([
      [2, 0, 2],
      [1, 2, 1],
      [2, 1, 2],
      [0, 2, 0],
      [2, 2, 2],
      [0, 2, 0],
      [2, 2, 2],
      [0, 2, 0],
      [2, 0, 2],
      [1, 2, 0],
      [2, 1, 2]
    ]);
    arrowsP.add([
      [3, 4, 5],
      [5, 6, 7],
      [2, 7],
      [2],
      [3]
    ]);
    solutionP.add([3, 2, 7, 0, 9, 0, 10, 1]);
    bannedP.add([]);
//*******************
    metaP.add([6, 4, 4, 0, 1]);
    boardP.add([
      [2, 2, 2, 1],
      [0, 2, 0, 2],
      [2, 0, 2, 0],
      [0, 2, 0, 2],
      [2, 0, 2, 0],
      [1, 2, 1, 2]
    ]);
    arrowsP.add([
      [5, 6],
      [2, 3],
      [2, 3, 7]
    ]);
    solutionP.add([2, 3, 4, 3, 5, 0, 5, 2]);
    bannedP.add([]);
//*******************
  }
}

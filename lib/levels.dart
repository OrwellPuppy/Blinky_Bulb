import 'package:blinky_bulb/globals.dart';
import 'package:blinky_bulb/complete_board.dart';
import 'package:blinky_bulb/extended_levels.dart';

List<CompleteRound> getLevels() {
  List<CompleteRound> levels = [];

  levels.add(CompleteRound(CompleteBoard(), [], []));

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
/*
CompleteRound levelDecompressor(String lvlString) {
  CompleteRound cRound;
  return cRound;
}*/

class Levels {
  List metaP = [];
  List boardP = [];
  List arrowsP = [];
  List solutionP = [];
  List bannedP = [];

  Levels(){
    loadLevels();
    loadExtendedLevels();
  }

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

  void loadExtendedLevels(){
    //Only reasons this function exists is to
    // seperate the extended levels into a seperate file
    ExtendedLevels myExtendedLevels = ExtendedLevels();
    for(var lvl in myExtendedLevels.metaP){
      metaP.add(lvl);
    }
    for(var lvl in myExtendedLevels.boardP){
      boardP.add(lvl);
    }
    for(var lvl in myExtendedLevels.arrowsP){
      arrowsP.add(lvl);
    }
    for(var lvl in myExtendedLevels.solutionP){
      solutionP.add(lvl);
    }
    for(var lvl in myExtendedLevels.bannedP){
      bannedP.add(lvl);
    }
  }



  loadLevels() {
    //******************* LVL 1
    metaP.add([6, 6, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
    ]);
    arrowsP.add([]);
    solutionP.add([0, 0, 1, 4, 4, 1, 5, 5]);
    bannedP.add([]);
    //******************* LVL 2
    metaP.add([5, 5, 3, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0],
    ]);
    arrowsP.add([]);
    solutionP.add([1, 1, 2, 2, 3, 3]);
    bannedP.add([]);
    //******************* LVL 3
    metaP.add([7, 7, 4, 1, 0]);
    boardP.add([
      [2, 2, 0, 0, 0, 2, 2],
      [2, 0, 0, 0, 0, 0, 2],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 0],
      [2, 0, 0, 0, 0, 0, 2],
      [2, 2, 0, 0, 0, 2, 2],
    ]);
    arrowsP.add([]);
    solutionP.add([2, 4, 4, 2, 4, 4, 2, 2]);
    bannedP.add([]);
    //******************* LVL 4
    metaP.add([12, 8, 4, 1, 1]);
    boardP.add([
      [2, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 0],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 0],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 2],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 2],
      [0, 2, 0, 2, 0, 2, 2, 2],
      [2, 0, 2, 0, 2, 0, 2, 2],
      [2, 2, 0, 2, 0, 2, 2, 2],
      [2, 2, 2, 0, 2, 2, 2, 2]
    ]);
    arrowsP.add([]);
    solutionP.add([2, 4, 2, 6, 5, 5, 7, 1]);
    bannedP.add([]);
//******************* LVL 5
    metaP.add([7, 6, 5, 1, 0]);
    boardP.add([
      [0, 0, 2, 2, 0, 0],
      [0, 0, 2, 2, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 2, 2, 0, 0],
      [0, 0, 2, 2, 0, 0]
    ]);
    arrowsP.add([]);
    solutionP.add([1, 5, 3, 2, 3, 5, 5, 0, 6, 0]);
    bannedP.add([]);
//******************* LVL 6
    metaP.add([5, 6, 5, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0]
    ]);
    arrowsP.add([]);
    solutionP.add([0, 0, 1, 2, 2, 3, 3, 4, 4, 4]);
    bannedP.add([]);
//******************* LVL 7
    metaP.add([10, 5, 5, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0]
    ]);
    arrowsP.add([]);
    solutionP.add([0, 3, 4, 1, 7, 2, 8, 1, 9, 2]);
    bannedP.add([]);
//******************* LVL 8
    metaP.add([4, 5, 5, 1, 0]);
    boardP.add([
      [2, 0, 0, 0, 2],
      [0, 0, 2, 0, 0],
      [0, 0, 2, 0, 0],
      [2, 0, 0, 0, 2]
    ]);
    arrowsP.add([]);
    solutionP.add([0, 1, 0, 2, 1, 3, 2, 4, 3, 2]);
    bannedP.add([]);
//******************* LVL 9
    metaP.add([9, 6, 5, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2, 2],
      [0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0],
      [0, 2, 2, 2, 0, 2],
      [2, 0, 2, 2, 2, 0],
      [0, 2, 2, 2, 0, 2],
      [2, 0, 2, 0, 2, 0],
      [0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 2]
    ]);
    arrowsP.add([]);
    solutionP.add([1, 0, 2, 3, 4, 1, 5, 4, 7, 4]);
    bannedP.add([]);
//******************* LVL 10
    metaP.add([6, 5, 5, 1, 0]);
    boardP.add([
      [2, 0, 0, 0, 2],
      [0, 0, 0, 0, 0],
      [0, 0, 2, 0, 0],
      [0, 0, 2, 0, 0],
      [0, 0, 0, 0, 0],
      [2, 0, 0, 0, 2]
    ]);
    arrowsP.add([]);
    solutionP.add([1, 2, 1, 3, 1, 4, 2, 3, 3, 4]);
    bannedP.add([]);
//******************* LVL 11
    //introduce arrows
    metaP.add([7, 5, 3, 1, 0]);
    boardP.add([
      [2, 0, 0, 0, 2],
      [0, 1, 0, 0, 0],
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1],
      [0, 0, 0, 0, 0],
      [0, 1, 0, 0, 0],
      [2, 0, 0, 0, 2],
    ]);
    arrowsP.add([
      [9],
      [11],
      [9]
    ]);
    solutionP.add([2, 2, 3, 4, 4, 2]);
    bannedP.add([]);

    //******************* LVL 12
    metaP.add([13, 7, 4, 0, 1]);
    boardP.add([
      //[0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 1, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
    ]);
    arrowsP.add([
      [2, 3, 4, 5, 6, 7]
    ]);
    solutionP.add([8, 1, 8, 5, 2, 3, 6, 3]);
    bannedP.add([]);
//******************* LVL 13
    metaP.add([6, 4, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 0]
    ]);
    arrowsP.add([
      [8, 10],
      [8, 10],
      [8, 10],
      [8, 10]
    ]);
    solutionP.add([0, 2, 1, 2, 3, 0, 3, 1]);
    bannedP.add([]);
//******************* LVL 14
    metaP.add([8, 4, 4, 1, 0]);
    boardP.add([
      [2, 0, 0, 2],
      [1, 0, 0, 0],
      [1, 0, 0, 0],
      [0, 0, 2, 0],
      [0, 2, 0, 0],
      [1, 0, 0, 0],
      [1, 0, 0, 0],
      [2, 0, 0, 2]
    ]);
    arrowsP.add([
      [9],
      [9],
      [9],
      [9]
    ]);
    solutionP.add([2, 0, 2, 1, 4, 0, 4, 2]);
    bannedP.add([]);
    //******************* LVL 15
    metaP.add([4, 5, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0],
      [0, 0, 0, 0, 1],
      [0, 0, 0, 0, 1],
      [0, 0, 0, 0, 0]
    ]);
    arrowsP.add([
      [11],
      [11]
    ]);
    solutionP.add([0, 1, 1, 1, 2, 0, 3, 1]);
    bannedP.add([]);
//******************* LVL 16
    metaP.add([6, 4, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 2],
      [0, 0, 0, 2],
      [1, 1, 1, 1],
      [0, 0, 0, 0],
      [0, 0, 0, 0],
      [0, 0, 0, 2]
    ]);
    arrowsP.add([
      [8, 10],
      [8, 10],
      [8, 10],
      [10]
    ]);
    solutionP.add([0, 0, 1, 0, 2, 0, 3, 1]);
    bannedP.add([]);
//******************* LVL 17
    metaP.add([6, 11, 5, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 1],
      [2, 2, 2, 2, 2, 0, 2, 0, 2, 0, 2],
      [2, 2, 2, 2, 2, 2, 0, 2, 0, 2, 1],
      [2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 1]
    ]);
    arrowsP.add([
      [6],
      [6],
      [7]
    ]);
    solutionP.add([0, 3, 1, 4, 1, 6, 5, 2, 5, 4]);
    bannedP.add([]);
//******************* LVL 18
    metaP.add([6, 4, 4, 1, 0]);
    boardP.add([
      [2, 0, 0, 2],
      [0, 1, 0, 0],
      [0, 0, 2, 0],
      [0, 2, 0, 0],
      [0, 1, 0, 0],
      [2, 0, 0, 2]
    ]);
    arrowsP.add([
      [9],
      [9]
    ]);
    solutionP.add([0, 1, 0, 2, 1, 2, 2, 3]);
    bannedP.add([]);
//******************* LVL 19
    metaP.add([7, 5, 5, 1, 0]);
    boardP.add([
      [0, 0, 2, 0, 0],
      [0, 0, 2, 1, 0],
      [0, 0, 0, 0, 0],
      [2, 1, 0, 0, 2],
      [0, 0, 0, 0, 0],
      [0, 0, 2, 0, 0],
      [0, 0, 2, 0, 0]
    ]);
    arrowsP.add([
      [10],
      [10]
    ]);
    solutionP.add([0, 1, 2, 3, 4, 1, 4, 2, 6, 3]);
    bannedP.add([]);
//******************* LVL 20
    metaP.add([7, 7, 4, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 0, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 1, 2, 0],
      [2, 0, 2, 0, 2, 0, 2],
      [0, 2, 0, 2, 1, 2, 0],
      [2, 0, 2, 0, 2, 0, 2]
    ]);
    arrowsP.add([
      [7],
      [7]
    ]);
    solutionP.add([1, 4, 3, 2, 5, 4, 6, 5]);
    bannedP.add([]);
//******************* LVL 21
    metaP.add([6, 5, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 1, 2],
      [0, 0, 0, 1, 0],
      [0, 0, 0, 1, 0],
      [0, 0, 0, 1, 0],
      [0, 2, 0, 0, 0],
      [0, 0, 0, 1, 0]
    ]);
    arrowsP.add([
      [11],
      [11],
      [11],
      [11],
      [11]
    ]);
    solutionP.add([0, 2, 1, 1, 2, 3, 4, 0]);
    bannedP.add([]);
//******************* LVL 22
    metaP.add([5, 7, 3, 0, 1]);
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
    solutionP.add([2, 5, 3, 4, 3, 6]);
    bannedP.add([]);
//******************* LVL 23
    metaP.add([10, 8, 4, 0, 1]);
    boardP.add([
      [2, 0, 2, 0, 2, 0, 2, 2],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 0],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 1, 2, 0, 2, 0],
      [0, 2, 0, 2, 1, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 0],
      [0, 2, 0, 2, 0, 2, 0, 2],
      [2, 0, 2, 0, 2, 0, 2, 0],
      [2, 2, 0, 2, 0, 2, 0, 2]
    ]);
    arrowsP.add([
      [2, 3, 4, 5, 6, 7],
      [2, 3, 4, 5, 6, 7]
    ]);
    solutionP.add([1, 2, 4, 3, 8, 3, 5, 4]);
    bannedP.add([]);
//******************* LVL 24
    metaP.add([5, 6, 4, 1, 0]);
    boardP.add([
      [0, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 0, 1, 1, 0, 0],
      [0, 0, 0, 0, 0, 0],
      [0, 1, 1, 1, 1, 0]
    ]);
    arrowsP.add([
      [8, 9, 10, 11],
      [8, 9, 10, 11],
      [8],
      [8],
      [8],
      [8]
    ]);
    solutionP.add([2, 1, 2, 5, 2, 2, 4, 1]);
    bannedP.add([]);

    //******************* LVL 25
    //single cross: intro to banned nodes
    metaP.add([7, 3, 4, 1, 0]);
    boardP.add([
      [2, 0, 2],
      [0, 1, 0],
      [2, 0, 2],
      [0, 0, 0],
      [2, 1, 2],
      [0, 0, 0],
      [2, 0, 2],
    ]);
    arrowsP.add([
      [10],
      [8],
    ]);
    solutionP.add([4, 1, 3, 0, 3, 2, 0, 1]);
    bannedP.add([3, 1]);

//******************* LVL 26
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









    //*******************tests for icon
    /*
    metaP.add([5, 3, 1, 0, 1]);
    boardP.add([
      [0, 0, 0],
      [0, 2, 0],
      [2, 0, 2],
      [0, 2, 0],
      [2, 0, 2],
      //[0, 2, 0],
     // [2, 0, 2]
    ]);
    arrowsP.add([

    ]);
    solutionP.add([2, 1]);
    bannedP.add([]);
    */
//*******************
    /*
    metaP.add([1, 1, 4, 1, 0]);
    boardP.add([
      [0],
    ]);
    arrowsP.add([]);
    solutionP.add([0, 0]);
    bannedP.add([]);
    */
  }
}

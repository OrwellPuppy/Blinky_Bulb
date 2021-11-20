import 'dart:math' as math;
import 'package:blinky_bulb/globals.dart';
//import 'package:flutter/cupertino.dart';

class CompleteBoard {
  int rows;
  int columns;
  int selectionsMax;
  bool cornerStart;
  bool isHexBoard;
  List<List<NodeType>> gameBoard; //matrix of node types

  //not required in definition of CompleteBoard
  int typeZero = 0;
  int typeOne = 0;
  int typeTwo = 0;
  int arrows = 0;
  double arrowDensity = 0.0;
  double arrowWtdDensity = 0.0;
  double boardDifficulty = 0.0;
  var rng = new math.Random();

  CompleteBoard(
      [this.rows,
      this.columns,
      this.selectionsMax,
      this.cornerStart = true,
      this.isHexBoard,
      this.gameBoard]);

  String getValues() {
    return 'CompleteBoard($rows, $columns, $selectionsMax, $cornerStart, $isHexBoard, ${getNodeTypeMatrixValues(gameBoard)})';
  }

  //todo: QQ cBoard (2nd-level)
  void printCompact() {
    print(
        'metaP.add([$rows, $columns, $selectionsMax, ${cornerStart ? 1 : 0}, ${isHexBoard ? 1 : 0}]);');
    printMatrixCompact(gameBoard);
  }

  String getNodeTypeMatrixValues(List<List<NodeType>> gb) {
    String values = '[';
    for (int x = 0; x < gb.length; x++) {
      values += '[';
      for (int y = 0; y < gb[x].length; y++) {
        values += '${gb[x][y].getValues()}, ';
      }
      if (values.length > 2 &&
          values.substring(values.length - 2, values.length - 1) == ',') {
        values = values.substring(0, values.length - 2);
      }
      values += '], ';
    }

    if (values.length > 2 &&
        values.substring(values.length - 2, values.length - 1) == ',') {
      values = values.substring(0, values.length - 2);
    }
    values += ']';
    return values;
  }

  //todo: QQ board matrix
  void printMatrixCompact(List<List<NodeType>> gb) {
    String boardValues = 'boardP.add([';
    String paramValues = 'arrowsP.add([';
    for (int x = 0; x < gb.length; x++) {
      boardValues += '[';
      for (int y = 0; y < gb[x].length; y++) {
        //boardValues += '${gb[x][y].getCompact()}, ';
        boardValues += '${gb[x][y].type}, ';
        if (gb[x][y].type == 1) {
          paramValues += '[';
          List<bool> arrows;
          arrows = [
            gb[x][y].north,
            gb[x][y].northEast,
            gb[x][y].southEast,
            gb[x][y].south,
            gb[x][y].southWest,
            gb[x][y].northWest,
            gb[x][y].truNorth,
            gb[x][y].truEast,
            gb[x][y].truSouth,
            gb[x][y].truWest
          ];
          for (int i = 0; i < arrows.length; i++) {
            if (arrows[i]) {
              paramValues += '${i + 2}, ';
            }
          }
          paramValues = paramValues.substring(0, paramValues.length - 2);
          paramValues += '], ';
        }
      }
      if (boardValues.length > 2 &&
          boardValues.substring(
                  boardValues.length - 2, boardValues.length - 1) ==
              ',') {
        boardValues = boardValues.substring(0, boardValues.length - 2);
      }
      boardValues += '],';
    }

    if (boardValues.length > 2 &&
        boardValues.substring(boardValues.length - 1, boardValues.length - 0) ==
            ',') {
      boardValues = boardValues.substring(0, boardValues.length - 1);
    }
    if (paramValues.length > 2 &&
        paramValues.substring(paramValues.length - 2, paramValues.length - 1) ==
            ',') {
      paramValues = paramValues.substring(0, paramValues.length - 2);
    }
    boardValues += ']);';
    paramValues += ']);';
    print(boardValues);
    print(paramValues);
  }

  void loadLoadingScreen() {
    //for loading screen
    rows = 5;
    columns = 3;
    selectionsMax = 0;
    cornerStart = false;
    isHexBoard = true;
    gameBoard = getBlankBoard(rows, columns, isHexBoard);
    gameBoard[2][1].type = 2;
  }

  void reroll() {
    if (rng.nextInt(100) < 50) {
      isHexBoard = true;
    } else {
      isHexBoard = false;
    }
    int rerollCounter = 0;
    do {
      rerollCounter++;
      if (isHexBoard) {
        _rollHexBoardSize();
        gameBoard = getBlankBoard(rows, columns, isHexBoard);
        _moldHexBoard();
      } else {
        _rollSquareBoardSize();
        gameBoard = getBlankBoard(rows, columns, isHexBoard);
        _moldSquareBoard();
        purgeOppositeSquareArrows();
      }
      purgeExtraArrows(false);
      _deleteUnusedNodes();
      updateCounts();
      if (rows > 5 && columns >= 4 && typeZero + typeOne > 12) {
        purgeShortArrows();
        updateCounts();
      }
      //calc difficulty
      arrowDensity = (arrows * 100 / (typeZero + typeOne)).round() / 100;
      arrowWtdDensity =
          (arrows * 100 / (typeZero * 1.25 + typeOne + 3)).round() / 100;
      boardDifficulty = (((typeOne + 5 + arrows * 2 / (typeOne + 1)) /
                      (1 + typeZero * 2.5 + typeTwo)) *
                  100)
              .round() /
          100;
    } while (!meetsBasicReqs() && rerollCounter < 100);

    //print('t0: $typeZero');
    //print('t1: $typeOne');
    //print('t2: $typeTwo');
    //print('arrows: $arrows');
    //print('density: $arrowDensity');
    //print('wtdDensity: $arrowWtdDensity');
    print('boardDifficulty: $boardDifficulty');

    //use difficulty to determine selectionsMax
    if (boardDifficulty < 0.15) {
      selectionsMax = 5;
    } else if (boardDifficulty > 0.85) {
      selectionsMax = 3;
    } else {
      selectionsMax = 4;
    }
  }

  void _rollHexBoardSize() {
    do {
      rows = rng.nextInt(11) + 3; //for the columns (13 max, 3 min)
      columns = rng.nextInt(10) + 3; //for the rows (12 max, 3 min)
      //one re-roll for extreme maps
      if (rows > 10 || rows < 6 || columns > 7 || columns < 4) {
        rows = rng.nextInt(11) + 3; //for the columns (13 max, 3 min)
        columns = rng.nextInt(10) + 3; //for the rows (12 max, 3 min)
      }
      //2nd re-roll for extra extreme maps
      if (rows > 11 || rows < 5 || columns > 8 || columns < 4) {
        rows = rng.nextInt(11) + 3; //for the columns (13 max, 3 min)
        columns = rng.nextInt(10) + 3; //for the rows (12 max, 3 min)
      }
      //check for too small maps
      if (columns <= 4 && rows < 6) {
        rows = 6;
      } else if (rows <= 4 && columns < 6) {
        columns = 6;
      }
      //check for too large maps
      if (rows >= 9 && columns >= 9) {
        if (rng.nextInt(100) > 50) {
          rows = rng.nextInt(3) + 6;
        } else {
          columns = rng.nextInt(3) + 6;
        }
      }
      cornerStart = (rng.nextInt(2) == 0);
    } while (!isSymUsually(rows, columns, 33));
  }

  void _rollSquareBoardSize() {
    rows = rng.nextInt(5) + 4; //for the columns (9 max, 4 min)
    columns = rng.nextInt(3) + 4; //for the rows (7 max, 4 min)
    //one re-roll for extreme maps
    /*if(rows>10||rows<6||columns>7||columns<4){
      rows = rng.nextInt(11) + 3; //for the columns (13 max, 3 min)
      columns = rng.nextInt(11) + 3; //for the rows (13 max, 3 min)
    }*/
  }

  void _moldHexBoard() {
    //**List of Select Functions:**
    //  selectAllNodes
    //  selectPerimeterNodes
    //  selectLeftRightPerimeterNodes
    //  selectTopBottomPerimeterNodes
    //  selectCornerNodes
    //  selectMiddleNodes
    //  selectBottomSliceNodes
    //  selectTopSliceNodes
    //  selectLeftSliceNodes
    //  selectRightSliceNodes
    //  selectThisRow
    //  selectTwoSymRows
    //  selectVertStripes

    //**List of Action Functions:**
    //  deleteNodes
    //  restoreNodes
    //  addArrows
    //  addAllArrows
    //  addOneArrow

    //**List of Other Tools:**
    //purgeExtraArrows(true) -- "true" purges side arrows
    //purgeShortArrows() -- purges arrows that only point to one node

    int subChance = rng.nextInt(90) + 10;
    bool middleDeletes = false;

    //deletes
    if (subChance > 90) {
      selectPerimeterNodes(28, deleteNodes);
    } else if (subChance > 85) {
      selectTwoSymRows(100, deleteNodes);
    } else if (subChance > 75) {
      selectMiddleNodesOfHex(100, deleteNodes);
      middleDeletes = true;
    } else if (subChance > 65) {
      selectCornerNodes(100, deleteNodes);
    } else if (subChance > 55) {
      selectMiddleNodesOfHex(100, deleteNodes);
      selectCornerNodes(100, deleteNodes);
      middleDeletes = true;
    } else if (subChance > 45) {
      selectAllNodes(30, deleteNodes);
    } else if (subChance > 43) {
      selectTopSliceNodes(100, deleteNodes);
    } else if (subChance > 41) {
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 39) {
      selectRightSliceNodes(100, deleteNodes);
    } else if (subChance > 37) {
      selectLeftSliceNodes(100, deleteNodes);
    } else if (subChance > 35) {
      selectRightSliceNodes(100, deleteNodes);
      selectLeftSliceNodes(100, deleteNodes);
    } else if (subChance > 33) {
      selectTopSliceNodes(100, deleteNodes);
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 32) {
      selectRightSliceNodes(100, deleteNodes);
      selectLeftSliceNodes(100, deleteNodes);
      selectTopSliceNodes(100, deleteNodes);
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 28) {
      selectAllNodes(33, deleteNodes);
      selectPerimeterNodes(41, deleteNodes);
    } else if (subChance > 26) {
      selectLeftRightPerimeterNodes(50, deleteNodes);
    } else if (subChance > 24) {
      selectAllNodes(11, deleteNodes);
    } else if (subChance > 22) {
      selectVertStripes(50, deleteNodes);
    }

    //Add arrows
    int myChance = rng.nextInt(100);
    subChance = rng.nextInt(100);
    int subSubChance = rng.nextInt(100);

    if (myChance > 90) {
      //Moderate single arrows, chance of abundant
      selectAllNodes(33, addOneArrow);
      if (subChance > 73) {
        selectAllNodes(60, addOneArrow);
        purgeShortArrows();
      }
      //checks that some arrows were assigned
      purgeExtraArrows(false);
      updateCounts();
      if (arrows == 0) {
        selectAllNodes(40, addOneArrow);
        purgeExtraArrows(false);
        updateCounts();
      }
    } else if (myChance > 80) {
      //all single arrows along perimeters; random middle spikes
      if (subChance > 60) {
        if (subSubChance > 80 && (rows > 5 && columns >= 4)) {
          selectPerimeterNodes(100, addOneArrow);
        } else {
          for (int i = 0; i < 30; i++) {
            selectPerimeterNodes(100, addOneArrow);
            purgeExtraArrows(true);
            purgeShortArrows();
          }
        }
      } else if (subChance > 30) {
        for (int i = 0; i < 30; i++) {
          selectLeftRightPerimeterNodes(100, addOneArrow);
          purgeExtraArrows(true);
        }
      } else {
        for (int i = 0; i < 30; i++) {
          selectTopBottomPerimeterNodes(100, addOneArrow);
          purgeExtraArrows(true);
        }
      }
      if (rows > 6 && columns >= 6 && (rng.nextInt(100) > 75)) {
        selectMiddleNodesOfHex(65, addAllArrows);
      }
      purgeExtraArrows(true);
    } else if (myChance > 70) {
      //small chance--perimeter spikes
      selectPerimeterNodes(100, addAllArrows);
      purgeShortArrows();
      purgeExtraArrows(true);
    } else if (myChance > 60) {
      //small chance -- random arrows
      selectAllNodes(50, addArrows);
    } else if (myChance > 50) {
      //middle spikes or corner spikes
      if (middleDeletes || rng.nextInt(100) > 70) {
        selectCornerNodes(100, addAllArrows);
      }
      if (rng.nextInt(100) > 40) {
        selectMiddleNodesOfHex(100, addAllArrows);
      } else {
        selectCornerNodes(100, addAllArrows);
      }
    } else if (myChance > 40) {
      //top/bottom or left/right spikes
      if (rng.nextInt(100) > 50) {
        selectLeftRightPerimeterNodes(100, addAllArrows);
      } else {
        selectTopBottomPerimeterNodes(100, addAllArrows);
      }
      purgeExtraArrows(true);
    } else if (myChance > 30) {
      //vert arrows or horz spikes
      if (rng.nextInt(100) > 50) {
        selectTwoSymRows(100, addAllArrows);
      } else {
        selectVertStripes(100, addArrows);
      }
    } else if (myChance > 20) {
      //Small chance--random spikes; pretty random results
      selectAllNodes(15, addAllArrows);
    } else if (myChance > 10) {
      //small chance-random arrows to random slices
      if (subChance > 70) {
        selectBottomSliceNodes(100, addArrows);
      } else if (subChance > 50) {
        selectRightSliceNodes(100, addArrows);
      } else if (subChance > 25) {
        selectLeftSliceNodes(100, addArrows);
      } else {
        selectTopSliceNodes(100, addArrows);
      }
    }
  }

  void _moldSquareBoard() {
    //**List of Select Functions:**
    //  selectAllNodes
    //  selectPerimeterNodes
    //  selectLeftRightPerimeterNodes
    //  selectTopBottomPerimeterNodes
    //  selectCornerNodes
    //  selectMiddleNodes
    //  selectBottomSliceNodes
    //  selectTopSliceNodes
    //  selectLeftSliceNodes
    //  selectRightSliceNodes
    //  selectThisRow
    //  selectTwoSymRows
    //  selectVertStripes

    //**List of Action Functions:**
    //  deleteNodes
    //  restoreNodes
    //  addArrows
    //  addAllArrows
    //  addOneArrow

    //**List of Other Tools:**
    //purgeExtraArrows(true) -- "true" purges side arrows
    //purgeShortArrows() -- purges arrows that only point to one node

    int subChance = rng.nextInt(90) + 10;

    //deletes
    if (subChance > 90) {
      selectPerimeterNodes(23, deleteNodes);
    } else if (subChance > 85) {
      selectTwoSymRows(50, deleteNodes);
    } else if (subChance > 75) {
      selectMiddleNodesOfSquare(100, false, deleteNodes);
    } else if (subChance > 65) {
      selectCornerNodes(100, deleteNodes);
    } else if (subChance > 55) {
      selectMiddleNodesOfSquare(100, false, deleteNodes);
      selectCornerNodes(100, deleteNodes);
    } else if (subChance > 45) {
      selectAllNodes(20, deleteNodes);
    } else if (subChance > 40) {
      selectTopSliceNodes(100, deleteNodes);
    } else if (subChance > 39) {
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 38) {
      selectRightSliceNodes(100, deleteNodes);
    } else if (subChance > 37) {
      selectLeftSliceNodes(100, deleteNodes);
    } else if (subChance > 36) {
      selectRightSliceNodes(100, deleteNodes);
      selectLeftSliceNodes(100, deleteNodes);
    } else if (subChance > 34) {
      selectTopSliceNodes(100, deleteNodes);
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 32) {
      selectRightSliceNodes(100, deleteNodes);
      selectLeftSliceNodes(100, deleteNodes);
      selectTopSliceNodes(100, deleteNodes);
      selectBottomSliceNodes(100, deleteNodes);
    } else if (subChance > 30) {
      selectRightSliceNodes(100, deleteNodes);
      selectLeftSliceNodes(100, deleteNodes);
      selectTopSliceNodes(100, deleteNodes);
      selectBottomSliceNodes(100, deleteNodes);
      selectCornerNodes(100, deleteNodes);
    } else if (subChance > 28) {
      selectAllNodes(15, deleteNodes);
      selectPerimeterNodes(15, deleteNodes);
    } else if (subChance > 25) {
      selectLeftRightPerimeterNodes(50, deleteNodes);
    } else if (subChance > 24) {
      selectAllNodes(11, deleteNodes);
    } else if (subChance > 22) {
      selectVertStripes(30, deleteNodes);
    }

    //Add arrows
    int myChance = rng.nextInt(100);
    subChance = rng.nextInt(100);
    int subSubChance = rng.nextInt(100);

    if (myChance > 90) {
      //Moderate single arrows, chance of abundant
      selectAllNodes(22, addOneArrow);
      if (rng.nextInt(100) > 80) {
        selectAllNodes(40, addOneArrow);
        purgeShortArrows();
      }
      //checks that some arrows were assigned
      purgeExtraArrows(false);
      updateCounts();
      if (arrows == 0) {
        selectAllNodes(30, addOneArrow);
        purgeExtraArrows(false);
        updateCounts();
      }
    } else if (myChance > 80) {
      //all single arrows along perimeters; random middle/corner spikes

      if (subChance > 60) {
        if (subSubChance > 0 && (rows > 5 && columns >= 4)) {
          selectPerimeterNodes(100, addOneArrow);
        } else {
          selectPerimeterNodes(100, addAllArrows);
          purgeExtraArrows(true);
          purgeShortArrows();
        }
      } else if (subChance > 30) {
        selectLeftRightPerimeterNodes(100, addAllArrows);
        purgeExtraArrows(true);
      } else {
        selectTopBottomPerimeterNodes(100, addAllArrows);
        purgeExtraArrows(true);
      }
      if (rows >= 5 && columns >= 5 && (rng.nextInt(100) > 60)) {
        selectMiddleNodesOfSquare(100, false, addAllArrows);
      }
      if (rng.nextInt(100) > 60) {
        selectCornerNodes(100, addAllArrows);
      }
      purgeExtraArrows(false);
    } else if (myChance > 65) {
      //small chance--corner spike only
      selectCornerNodes(100, addAllArrows);
      purgeExtraArrows(false);
    } else if (myChance > 55) {
      //small chance -- random spikes
      selectAllNodes(15, addAllArrows);
      purgeExtraArrows(false);
      purgeShortArrows();
    } else if (myChance > 45) {
      //add a vert and horz stripe
      addArrowColumnToSquare();
    } else if (myChance > 35) {
      //add a vert and horz stripe
      addArrowRowToSquare();
    } else if (myChance > 25) {
      //add a vert and horz stripe
      addArrowColumnToSquare();
      addArrowRowToSquare();
    }
  }

  void _deleteUnusedNodes() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (isHexBoard) {
          //check if DOESN'T exist
          if ((cornerStart && (r % 2 == c % 2)) ||
              (!cornerStart && (r % 2 != c % 2))) {
          } else {
            gameBoard[r][c] = new NodeType(2, isHexBoard);
          }
        }
      }
    }
  }

  void updateCounts() {
    typeZero = 0;
    typeOne = 0;
    typeTwo = 0;
    arrows = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (isHexBoard) {
          //check if exists
          if ((cornerStart && (r % 2 == c % 2)) ||
              (!cornerStart && (r % 2 != c % 2))) {
            if (gameBoard[r][c].type == 0) {
              typeZero++;
            }
            if (gameBoard[r][c].type == 1) {
              typeOne++;
              if (gameBoard[r][c].north) {
                arrows++;
              }
              if (gameBoard[r][c].northEast) {
                arrows++;
              }
              if (gameBoard[r][c].southEast) {
                arrows++;
              }
              if (gameBoard[r][c].south) {
                arrows++;
              }
              if (gameBoard[r][c].southWest) {
                arrows++;
              }
              if (gameBoard[r][c].northWest) {
                arrows++;
              }
            }
            if (gameBoard[r][c].type == 2) {
              typeTwo++;
            }
          } else {
            //erase the unused nodes
            gameBoard[r][c] = new NodeType(2, isHexBoard);
          }
        } else {
          //for Square boards
          if (gameBoard[r][c].type == 0) {
            typeZero++;
          }
          if (gameBoard[r][c].type == 1) {
            typeOne++;
            if (gameBoard[r][c].truNorth) {
              arrows++;
            }
            if (gameBoard[r][c].truEast) {
              arrows++;
            }
            if (gameBoard[r][c].truSouth) {
              arrows++;
            }
            if (gameBoard[r][c].truWest) {
              arrows++;
            }
          }
          if (gameBoard[r][c].type == 2) {
            typeTwo++;
          }
        }
      }
    }
  }

  bool meetsBasicReqs() {
    if (typeZero + typeOne < 10) {
      print('REROLLED: $typeZero + $typeOne < 10');
      return false;
    } else if (arrowDensity > 1.75) {
      print('REROLLED: $arrowDensity > 1.7');
      return false;
    } else if (arrowWtdDensity > 1.3) {
      print('REROLLED: $arrowWtdDensity > 1.3');
      return false;
    } else if (!isOneMass()) {
      print('REROLLED: multiple masses');
      return false;
    } else if (!hasAllSides()) {
      print('REROLLED: side missing');
      return false;
    }
    return true;
  }

  bool hasAllSides() {
    bool leftExists = false;
    bool rightExists = false;
    bool topExists = false;
    bool bottomExists = false;
    for (int r = 0; r < rows; r++) {
      if (checkExists(r, 0)) {
        leftExists = true;
      }
      if (checkExists(r, columns - 1)) {
        rightExists = true;
      }
    }
    for (int c = 0; c < columns; c++) {
      if (checkExists(0, c)) {
        topExists = true;
      }
      if (checkExists(rows - 1, c)) {
        bottomExists = true;
      }
    }
    if (leftExists && rightExists && topExists && bottomExists) {
      //print('ALL SIDES PRESENT!!');
      return true;
    }
    return false;
  }

  bool checkIfSym(int rows, int columns) {
    if ((columns % 2 == 1) && (rows % 2 == 1)) {
      return true;
    } else {
      return false;
    }
  }

  bool isSymUsually(int rows, int columns, int chance) {
    //chance is the % chance that a non-sym board is accepted
    if (checkIfSym(rows, columns)) {
      return true;
    } else if (rng.nextInt(100) < chance) {
      return true;
    } else {
      return false;
    }
  }

  bool isOneMass() {
    //find starting node
    updateCounts();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((!isHexBoard) ||
            (cornerStart && (r % 2 == 0 % 2)) ||
            (!cornerStart && (r % 2 != 0 % 2))) {
          if (gameBoard[r][c].type != 2) {
            return typeOne + typeZero == countConnectedNodes(r, c);
          }
        }
      }
    }
    print('ERROR: completely blank board!');
    return false;
  }

  int countConnectedNodes(int r, int c) {
    List<Node> myNodeList = [];
    //myNodeList.add(Node(-10,-10));
    checkNode(int myR, int myC) {
      if (checkExists(myR, myC)) {
        if (!myNodeList
            .any((thisNode) => (thisNode.row == myR && thisNode.col == myC))) {
          myNodeList.add(Node(myR, myC));
          if (isHexBoard) {
            checkNode(myR - 2, myC - 0); //north
            checkNode(myR - 1, myC + 1); //northEast
            checkNode(myR + 1, myC + 1); //southEast
            checkNode(myR + 2, myC + 0); //south
            checkNode(myR + 1, myC - 1); //southWest
            checkNode(myR - 1, myC - 1); //northWest
          } else {
            checkNode(myR - 1, myC + 0); //truNorth
            checkNode(myR + 0, myC + 1); //trueEast
            checkNode(myR + 1, myC + 0); //trueSouth
            checkNode(myR + 0, myC - 1); //truWest
          }
        }
      }
    }

    checkNode(r, c);
    //print('* * * * * * * *');
    //myNodeList.forEach((i)=>print('[${i.row}, ${i.col}]'));
    return myNodeList.length;
  }

  bool checkExists(int thisRow, int thisCol) {
    //checks that it exists AND that it's not type2
    bool exists = false;
    if (thisRow < 0 || thisRow >= rows) {
      return false;
    }
    if (thisCol < 0 || thisCol >= columns) {
      return false;
    }

    if (!isHexBoard || (cornerStart && (thisRow % 2 == thisCol % 2))) {
      exists = true;
    } else if (!cornerStart && (thisRow % 2 != thisCol % 2)) {
      exists = true;
    }
    if (gameBoard[thisRow][thisCol].type == 2) {
      exists = false;
    }
    return exists;
  }

  List<List<NodeType>> getBlankBoard(int rows, int columns, bool isHexBoard) {
    List<List<NodeType>> myGameBoard;
    myGameBoard = List.generate(
        rows,
        (int i) => List.generate(
            columns, (int j) => new NodeType(0, isHexBoard),
            growable: false),
        growable: false);

    return myGameBoard;
  }

  selectVertStripes(int chance, Function doThis) {
    for (int i = 1; i < rows; i = i + 2) {
      selectThisRow(i, chance, doThis);
    }
  }

  selectTwoSymRows(int chance, Function doThis) {
    if (rows == 5) {
      selectThisRow(2, chance, doThis);
    } else if (rows > 5) {
      int myNumber = rng.nextInt((rows / 2).floor() - 1);
      if (rows % 2 == 0 && myNumber == 0) {
        myNumber = 1;
      }
      selectThisRow((rows / 2).floor() - myNumber - 1, chance, doThis);
      selectThisRow((rows / 2).ceil() + myNumber, chance, doThis);
    }
  }

  selectMiddleNodesOfHex(int chance, Function doThis) {
    double rMin = rows / 2 - 1.5;
    double rMax = rows / 2 + .5;
    double cMin = columns / 2 - 1;
    double cMax = columns / 2;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r >= rMin && r <= rMax && c <= cMax && c >= cMin && rows > 5) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectMiddleNodesOfSquare(int chance, bool makeLarge, Function doThis) {
    //the makeLarge parameter makes the middle selections larger in some cases
    bool breaker = false;
    bool reverser = rng.nextInt(2) >= 0.5;
    int rMin = math.max(2, ((rows / 2 - .001).floor()));
    int cMin = math.max(2, ((columns / 2 - .001).floor()));
    if (rows >= 5 && columns <= 4) {
      cMin = 1;
      if (rows % 2 == 0) {
        breaker = true;
      }
    } else if (columns >= 5 && rows <= 4) {
      rMin = 1;
      if (columns % 2 == 0) {
        breaker = true;
      }
    }
    int rMax = rows - rMin;
    int cMax = columns - cMin;
    if (makeLarge) {
      rMin = math.max(1, (rows / 2.5).floor());
      rMax = rows - rMin;
      cMin = math.max(1, (columns / 2.5).floor());
      cMax = columns - cMin;
      breaker = false;
    }
    for (int r = rMin; r < rMax; r++) {
      for (int c = cMin; c < cMax; c++) {
        if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
          if (!(breaker &&
              reverser &&
              ((r == rMin && c == cMin) || (r == rMax - 1 && c == cMax - 1)))) {
            doThis(r, c);
          }
          if (breaker && r < rMax - 1 && !reverser) {
            r++;
          }
        }
      }
    }
  }

  selectLeftSliceNodes(int chance, Function doThis) {
    double rMin = rows / 2 - 1.5;
    double rMax = rows / 2 + .5;
    double cMin = columns / 2 - 1;
    if (!isHexBoard) {
      cMin -= math.min(1, columns - 4);
      rMin += 2.5 / rows;
      rMax -= 2.5 / rows;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r >= rMin && r <= rMax && c < cMin) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectRightSliceNodes(int chance, Function doThis) {
    double rMin = rows / 2 - 1.5;
    double rMax = rows / 2 + .5;
    double cMax = columns / 2;
    if (!isHexBoard) {
      cMax += math.min(1, columns - 4);
      rMin += 2.5 / rows;
      rMax -= 2.5 / rows;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r >= rMin && r <= rMax && c > cMax) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectBottomSliceNodes(int chance, Function doThis) {
    double cMin = columns / 2 - 1;
    double cMax = columns / 2;
    double rMax = rows / 2 + .5;
    if (!isHexBoard) {
      cMin -= 0.5;
      cMax += 0.5;
      rMax -= 0.5;
      rMax += math.min(1, rows - 4);
      cMin += 2.5 / columns;
      cMax -= 2.5 / columns;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r > rMax && c <= cMax && c >= cMin) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectTopSliceNodes(int chance, Function doThis) {
    double cMin = columns / 2 - 1;
    double cMax = columns / 2;
    double rMin = rows / 2 - 1.5;
    if (!isHexBoard) {
      cMin -= 0.5;
      cMax += 0.5;
      rMin += 0.5;
      rMin -= math.min(1, rows - 4);
      cMin += 2.5 / columns;
      cMax -= 2.5 / columns;
    }
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (r < rMin && c <= cMax && c >= cMin) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectCornerNodes(int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((r == 0 && c == 0) ||
            (r == rows - 1 && c == 0) ||
            (r == 0 && c == columns - 1) ||
            (r == rows - 1 && c == columns - 1)) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectPerimeterNodes(int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((r == 0) || (r == rows - 1) || (c == columns - 1) || (c == 0)) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectTopBottomPerimeterNodes(int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((r == 0) || (r == rows - 1)) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectLeftRightPerimeterNodes(int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if ((c == columns - 1) || (c == 0)) {
          if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
            doThis(r, c);
          }
        }
      }
    }
  }

  selectAllNodes(int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
          doThis(r, c);
        }
      }
    }
  }

  selectThisRow(int r, int chance, Function doThis) {
    for (int c = 0; c < columns; c++) {
      if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
        doThis(r, c);
      }
    }
  }

  selectThisColumnOfSquare(int c, int chance, Function doThis) {
    for (int r = 0; r < rows; r++) {
      if (gameBoard[r][c].type == 0 && rng.nextInt(100) < chance) {
        doThis(r, c);
      }
    }
  }

  deleteNodes(int r, int c) {
    gameBoard[r][c] = new NodeType(2, isHexBoard);
  }

  restoreNodes(int r, int c) {
    //never used
    gameBoard[r][c] = new NodeType(0, isHexBoard);
  }

  addArrows(int r, int c) {
    if (gameBoard[r][c].type != 2) {
      gameBoard[r][c] = new NodeType(1, isHexBoard);
    }
  }

  addAllArrows(int r, int c) {
    if (gameBoard[r][c].type != 2) {
      gameBoard[r][c].addAllArrowsToNode();
    }
  }

  addOneArrow(int r, int c) {
    if (gameBoard[r][c].type == 0 && isHexBoard) {
      int aSelect = rng.nextInt(6);
      gameBoard[r][c] = new NodeType(1, isHexBoard, aSelect == 0, aSelect == 1,
          aSelect == 2, aSelect == 3, aSelect == 4, aSelect == 5);
    } else if (gameBoard[r][c].type == 0 && !isHexBoard) {
      int aSelect = rng.nextInt(4);
      gameBoard[r][c] = new NodeType(1, isHexBoard, false, false, false, false,
          false, false, aSelect == 0, aSelect == 1, aSelect == 2, aSelect == 3);
    }
  }

  void purgeExtraArrows(bool purgeSideArrows) {
    //remove arrows that point off screen or to type2 nodes
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (isHexBoard) {
          //NORTH
          if (r <= 1 || gameBoard[r - 2][c].type == 2) {
            gameBoard[r][c].north = false;
          }
          //NORTH EAST
          if (r == 0 || c == columns - 1 || gameBoard[r - 1][c + 1].type == 2) {
            gameBoard[r][c].northEast = false;
          }
          //SOUTH EAST
          if (r == rows - 1 ||
              c == columns - 1 ||
              gameBoard[r + 1][c + 1].type == 2) {
            gameBoard[r][c].southEast = false;
          }
          //SOUTH
          if (r >= rows - 2 || gameBoard[r + 2][c].type == 2) {
            gameBoard[r][c].south = false;
          }
          //SOUTH WEST
          if (r == rows - 1 || c == 0 || gameBoard[r + 1][c - 1].type == 2) {
            gameBoard[r][c].southWest = false;
          }
          //NORTH WEST
          if (r == 0 || c == 0 || gameBoard[r - 1][c - 1].type == 2) {
            gameBoard[r][c].northWest = false;
          }
        } else {
          //truNORTH
          if (r <= 0 || gameBoard[r - 1][c].type == 2) {
            gameBoard[r][c].truNorth = false;
          }
          //truWEST
          if (c <= 0 || gameBoard[r][c - 1].type == 2) {
            gameBoard[r][c].truWest = false;
          }
          //truSOUTH
          if (r >= rows - 1 || gameBoard[r + 1][c].type == 2) {
            gameBoard[r][c].truSouth = false;
          }
          //truEAST
          if (c >= columns - 1 || gameBoard[r][c + 1].type == 2) {
            gameBoard[r][c].truEast = false;
          }
        }

        if (purgeSideArrows) {
          if (isHexBoard) {
            //LEFT SIDE: NORTH & SOUTH
            if ((c == 0) && (r != 0) && (r != rows - 1)) {
              gameBoard[r][c].north = false;
              gameBoard[r][c].south = false;
            }
            //RIGHT SIDE: NORTH & SOUTH
            if ((c == columns - 1) && (r != 0) && (r != rows - 1)) {
              gameBoard[r][c].north = false;
              gameBoard[r][c].south = false;
            }
          } else {
            //TOP: tEAST & tWEST
            if (r == 0) {
              gameBoard[r][c].truEast = false;
              gameBoard[r][c].truWest = false;
            }
            //BOTTOM: tEAST & tWEST
            if (r == rows - 1) {
              gameBoard[r][c].truEast = false;
              gameBoard[r][c].truWest = false;
            }
            //LEFT SIDE: tNORTH AND tSOUTH
            if (c == 0) {
              gameBoard[r][c].truNorth = false;
              gameBoard[r][c].truSouth = false;
            }
            //RIGHT SIDE: tNORTH AND tSOUTH
            if (c == columns - 1) {
              gameBoard[r][c].truNorth = false;
              gameBoard[r][c].truSouth = false;
            }
          }
        }
        gameBoard[r][c].cleanseType();
      }
    }
  }

  void purgeShortArrows() {
    //remove arrows that point off screen or to type2 nodes within a couple nodes
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (isHexBoard) {
          //NORTH
          if (r <= 3 || gameBoard[r - 4][c].type == 2) {
            gameBoard[r][c].north = false;
          }
          //NORTH EAST
          if (r <= 1 || c >= columns - 2 || gameBoard[r - 2][c + 2].type == 2) {
            gameBoard[r][c].northEast = false;
          }
          //SOUTH EAST
          if (r >= rows - 2 ||
              c >= columns - 2 ||
              gameBoard[r + 2][c + 2].type == 2) {
            gameBoard[r][c].southEast = false;
          }
          //SOUTH
          if (r >= rows - 4 || gameBoard[r + 4][c].type == 2) {
            gameBoard[r][c].south = false;
          }
          //SOUTH WEST
          if (r >= rows - 2 || c <= 1 || gameBoard[r + 2][c - 2].type == 2) {
            gameBoard[r][c].southWest = false;
          }
          //NORTH WEST
          if (r <= 1 || c <= 1 || gameBoard[r - 2][c - 2].type == 2) {
            gameBoard[r][c].northWest = false;
          }
        } else {
          //truNORTH
          if (r <= 1 || gameBoard[r - 2][c].type == 2) {
            gameBoard[r][c].truNorth = false;
          }
          //truWEST
          if (c <= 1 || gameBoard[r][c - 2].type == 2) {
            gameBoard[r][c].truWest = false;
          }
          //truSOUTH
          if (r >= rows - 2 || gameBoard[r + 2][c].type == 2) {
            gameBoard[r][c].truSouth = false;
          }
          //truEAST
          if (c >= columns - 2 || gameBoard[r][c + 2].type == 2) {
            gameBoard[r][c].truEast = false;
          }
        }
        gameBoard[r][c].cleanseType();
      }
    }
  }

  purgeOppositeSquareArrows() {
    int midRow = (rows / 2).floor();
    int midCol = (columns / 2).floor();

    for (int r = 0; r < rows; r++) {
      gameBoard[r][0].calcArrowCount();
      gameBoard[r][columns - 1].calcArrowCount();
      if (gameBoard[r][0].truEast &&
          gameBoard[r][columns - 1].truWest &&
          gameBoard[r][0].arrowCount == 1 &&
          gameBoard[r][columns - 1].arrowCount == 1 &&
          gameBoard[r][midCol].type != 2) {
        if (rng.nextInt(100) > 50) {
          gameBoard[r][0].truEast = false;
        } else {
          gameBoard[r][columns - 1].truWest = false;
        }
      }
    }
    for (int c = 0; c < columns; c++) {
      gameBoard[0][c].calcArrowCount();
      gameBoard[rows - 1][c].calcArrowCount();
      if (gameBoard[0][c].truSouth &&
          gameBoard[rows - 1][c].truNorth &&
          gameBoard[0][c].arrowCount == 1 &&
          gameBoard[rows - 1][c].arrowCount == 1 &&
          gameBoard[midRow][c].type != 2) {
        if (rng.nextInt(100) > 50) {
          gameBoard[0][c].truSouth = false;
        } else {
          gameBoard[rows - 1][c].truNorth = false;
        }
      }
    }
  }

  addArrowRowToSquare() {
    int myRow = rng.nextInt(rows);
    for (int i = 0; i < columns; i++) {
      if (gameBoard[myRow][i].type != 2) {
        gameBoard[myRow][i].truNorth = true;
        gameBoard[myRow][i].truSouth = true;
        gameBoard[myRow][i].truEast = false;
        gameBoard[myRow][i].truWest = false;
        gameBoard[myRow][i].type = 1;
      }
    }
  }

  addArrowColumnToSquare() {
    int myCol = rng.nextInt(columns);
    for (int i = 0; i < rows; i++) {
      if (gameBoard[i][myCol].type != 2) {
        gameBoard[i][myCol].truEast = true;
        gameBoard[i][myCol].truWest = true;
        gameBoard[i][myCol].truSouth = false;
        gameBoard[i][myCol].truNorth = false;
        gameBoard[i][myCol].type = 1;
      }
    }
  }
}

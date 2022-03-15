import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:blinky_bulb/complete_board.dart';

//colors
const Color shadeA = Color.fromRGBO(
    58, 134, 255, 1); //Colors.deepOrange; //Colors.lightBlueAccent;
const Color shadeB =
    Color.fromRGBO(255, 190, 11, 1); //Colors.yellow; //bulb color
const Color shadeBgrad = Colors.white; //bulb color gradient
const Color shadeC =
    Color.fromRGBO(255, 0, 110, 1); //Colors.red; //banned node color
const Color shadeD = Color.fromRGBO(58, 134, 255, 1); //selection color
const Color shadeE = Color.fromRGBO(131, 56, 236, 1); //clue highlight color
const Color shadeF = Color.fromRGBO(251, 86, 7, 1); //arrow color
final Color shadeG = Colors.grey.shade700; //bulb off color
final Color shadeGgrad = Colors.grey.shade600; //bulb off color gradient
const Color myWhite = Colors.white; //text on buttons
const Color myBackground = Colors.black; //background
const Color myBlackText = Colors.black; //black text
final Color popUpBackground = Colors.grey.shade900; //popup background color
final Color backgroundLightContrast =
    Colors.grey.shade800; //use for greyed out things, popups background
final Color backgroundContrast =
    Colors.grey.shade700; //use for greyed out things
final Color popupTextColor =
    Colors.grey.shade200; //text on popups and labels on background

//bulb animation speed settings
const bulbDuration = Duration(milliseconds: 1500);
const startDuration = Duration(milliseconds: 650);
const bulbCurve = Curves.decelerate;
const startCurve = Curves.easeInOut;
const pieceFade = Duration(milliseconds: 450);
const pieceCurve = Curves.easeOutQuad;

//ending animation speed settings
const explodeDuration = Duration(milliseconds: 1800);

class Node {
  final int row;
  final int col;

  Node(this.row, this.col);

  String getValues() {
    return 'Node($row, $col)';
  }

  String getCompact() {
    return '$row, $col, ';
  }
}

class NodeType {
  int type;
  late int arrowCount;

  //type 0: plain node
  //type 1: node with one or more arrows
  //type 2: a blank/deleted/invisible node
  bool north;
  bool northEast;
  bool southEast;
  bool south;
  bool southWest;
  bool northWest;

  //square directions
  bool truNorth;
  bool truEast;
  bool truSouth;
  bool truWest;
  bool isHex;

  NodeType(
    this.type,
    this.isHex, [
    this.north = false, //2
    this.northEast = false, //3
    this.southEast = false, //4,
    this.south = false, //5
    this.southWest = false, //6
    this.northWest = false, //7
    this.truNorth = false, //8
    this.truEast = false, //9
    this.truSouth = false, //10
    this.truWest = false, //11
  ]) {
    //generate some default arrows in case they arn't provided and type=1
    if (type == 1 &&
        !north &&
        !northEast &&
        !southEast &&
        !south &&
        !southWest &&
        !northWest &&
        !truNorth &&
        !truEast &&
        !truSouth &&
        !truWest) {
      var rng = math.Random();
      int myRandom;
      int prcnt = 50; //percent chance of an arrow
      if (isHex) {
        myRandom = rng.nextInt(100);
        north = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        northEast = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        southEast = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        south = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        southWest = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        northWest = myRandom < prcnt;
      } else {
        myRandom = rng.nextInt(100);
        truNorth = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        truEast = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        truSouth = myRandom < prcnt;
        myRandom = rng.nextInt(100);
        truWest = myRandom < prcnt;
      }
      cleanseType(); //in case all arrows arn't drawn
    }
    calcArrowCount();
  }

  //alternate constructor
  NodeType.one(bool sHex)
      : this(
          1,
          sHex,
        );

  String getValues() {
    if (type == 1) {
      return 'NodeType($type, $isHex, $north, $northEast, $southEast, $south, $southWest, $northWest, $truNorth, $truEast, $truSouth, $truWest)';
    } else {
      return 'NodeType($type, $isHex)';
    }
  }

//print nodeType
  /*
  String getCompact() {
    if (type == 4) {
      //1
      List<bool> arrows;
      arrows = [
        north,
        northEast,
        southEast,
        south,
        southWest,
        northWest,
        truNorth,
        truEast,
        truSouth,
        truWest
      ];
      String myReturnArray = ''; //[
      for (int i = 0; i < arrows.length; i++) {
        if (arrows[i]) {
          myReturnArray += '$i,';
        }
      }
      if (myReturnArray.length >= 2 &&
          myReturnArray.substring(
                  myReturnArray.length - 1, myReturnArray.length - 0) ==
              ',') {
        myReturnArray = myReturnArray.substring(0, myReturnArray.length - 1);
      }
      myReturnArray += ''; //]
      return myReturnArray;
    } else {
      return '$type';
    }
  }*/

  calcArrowCount() {
    arrowCount = 0;
    if (north) {
      arrowCount++;
    }
    if (northEast) {
      arrowCount++;
    }
    if (southEast) {
      arrowCount++;
    }
    if (south) {
      arrowCount++;
    }
    if (southWest) {
      arrowCount++;
    }
    if (northWest) {
      arrowCount++;
    }
    if (truNorth) {
      arrowCount++;
    }
    if (truEast) {
      arrowCount++;
    }
    if (truSouth) {
      arrowCount++;
    }
    if (truWest) {
      arrowCount++;
    }
  }

  cleanseType() {
    if (north ||
        northEast ||
        southEast ||
        south ||
        southWest ||
        northWest ||
        truNorth ||
        truEast ||
        truSouth ||
        truWest) {
      type = 1;
    } else if (type == 1) {
      type = 0;
    }
  }

  addAllArrowsToNode() {
    type = 1;
    if (isHex) {
      north = true;
      northEast = true;
      southEast = true;
      south = true;
      southWest = true;
      northWest = true;
    } else {
      truNorth = true;
      truEast = true;
      truSouth = true;
      truWest = true;
    }
    calcArrowCount();
  }

  makeTypeZero() {
    type = 0;
    north = false;
    northEast = false;
    southEast = false;
    south = false;
    southWest = false;
    northWest = false;
    truNorth = false;
    truEast = false;
    truSouth = false;
    truWest = false;
    calcArrowCount();
  }
}

class LightState {
  //LightState consists of a CompleteBoard plus the current state of it's lights
  final CompleteBoard cBoard;
  late List<List<bool>> lightState;

  LightState(this.cBoard, [List<Node> initialList = const []]) {
    lightState = List.generate(
        cBoard.rows,
        (int i) =>
            List.generate(cBoard.columns, (int j) => false, growable: false),
        growable: false);

    //if there's an initialList
    if (initialList.isNotEmpty) {
      updateNodeList(initialList);
    }
  }

  //for testing
  testPrintLit() {
    int onCount = 0;
    for (int i = 0; i < lightState.length; i++) {
      for (int j = 0; j < lightState[0].length; j++) {
        if (lightState[i][j]) {
          onCount++;
        }
      }
    }
    print('on: $onCount');
  }

  bool checkIfSolved() {
    for (int i = 0; i < lightState.length; i++) {
      for (int j = 0; j < lightState[0].length; j++) {
        if (lightState[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  bool checkIfSolution(List<Node> cList) {
    LightState tempLights = LightState(cBoard, cList);
    for (int i = 0; i < lightState.length; i++) {
      for (int j = 0; j < lightState[0].length; j++) {
        if (lightState[i][j] != tempLights.lightState[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  updateNodeList(List<Node> myNodeList) {
    myNodeList.forEach((element) =>
        _updateLightStateFromBulbList(_getBulbList(element.row, element.col)));
  }

  updateNode(int row, int col) {
    _updateLightStateFromBulbList(_getBulbList(row, col));
  }

  _updateLightStateFromBulbList(List<List<int>> bulbList) {
    for (int i = 0; i < bulbList.length; i++) {
      if (lightState[bulbList[i][0]][bulbList[i][1]] == false) {
        lightState[bulbList[i][0]][bulbList[i][1]] = true;
      } else {
        lightState[bulbList[i][0]][bulbList[i][1]] = false;
      }
    }
  }

  //getBulbList returns the bulbs that need to be toggled
  //  and the row & col of a bulb that's been tapped.
  List<List<int>> _getBulbList(int row, int col) {
    List<List<int>> bulbList = [];
    bulbList.add([row, col]);
    if (cBoard.gameBoard[row][col].type == 0) {
      if (cBoard.isHexBoard) {
        bulbList.add([row - 2, col]);
        bulbList.add([row + 1, col - 1]);
        bulbList.add([row + 1, col + 1]);
        bulbList.add([row + 2, col]);
        bulbList.add([row - 1, col - 1]);
        bulbList.add([row - 1, col + 1]);
      } else {
        bulbList.add([row - 1, col]);
        bulbList.add([row + 1, col]);
        bulbList.add([row, col + 1]);
        bulbList.add([row, col - 1]);
      }
    } else if (cBoard.gameBoard[row][col].type == 1) {
      int cRow;
      int cCol;
      //NORTH
      if (cBoard.gameBoard[row][col].north) {
        cRow = row - 2;
        cCol = col;
        while (cRow >= 0 && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow - 2;
        }
      }
      //NORTH EAST
      if (cBoard.gameBoard[row][col].northEast) {
        cRow = row - 1;
        cCol = col + 1;
        while (cRow >= 0 &&
            cCol < cBoard.columns &&
            cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow - 1;
          cCol = cCol + 1;
        }
      }
      //SOUTH EAST
      if (cBoard.gameBoard[row][col].southEast) {
        cRow = row + 1;
        cCol = col + 1;
        while (cRow < cBoard.rows &&
            cCol < cBoard.columns &&
            cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow + 1;
          cCol = cCol + 1;
        }
      }
      //SOUTH
      if (cBoard.gameBoard[row][col].south) {
        cRow = row + 2;
        cCol = col;
        while (cRow < cBoard.rows && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow + 2;
        }
      }
      //SOUTH WEST
      if (cBoard.gameBoard[row][col].southWest) {
        cRow = row + 1;
        cCol = col - 1;
        while (cRow < cBoard.rows &&
            cCol >= 0 &&
            cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow + 1;
          cCol = cCol - 1;
        }
      }
      //NORTH WEST
      if (cBoard.gameBoard[row][col].northWest) {
        cRow = row - 1;
        cCol = col - 1;
        while (
            cRow >= 0 && cCol >= 0 && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow - 1;
          cCol = cCol - 1;
        }
      }
      //truNORTH
      if (cBoard.gameBoard[row][col].truNorth) {
        cRow = row - 1;
        cCol = col;
        while (cRow >= 0 && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow - 1;
        }
      }
      //truEAST
      if (cBoard.gameBoard[row][col].truEast) {
        cRow = row;
        cCol = col + 1;
        while (
            cCol < cBoard.columns && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cCol = cCol + 1;
        }
      }
      //truSOUTH
      if (cBoard.gameBoard[row][col].truSouth) {
        cRow = row + 1;
        cCol = col;
        while (cRow < cBoard.rows && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cRow = cRow + 1;
        }
      }
      //truWEST
      if (cBoard.gameBoard[row][col].truWest) {
        cRow = row;
        cCol = col - 1;
        while (cCol >= 0 && cBoard.gameBoard[cRow][cCol].type != 2) {
          bulbList.add([cRow, cCol]);
          cCol = cCol - 1;
        }
      }
    }
    //check for out-of-range or nodeType.type==2
    List<int> removes = [];
    for (int i = 0; i < bulbList.length; i++) {
      if (bulbList[i][0] < 0 ||
          bulbList[i][0] >= cBoard.rows ||
          bulbList[i][1] < 0 ||
          bulbList[i][1] >= cBoard.columns ||
          cBoard.gameBoard[bulbList[i][0]][bulbList[i][1]].type == 2) {
        removes.add(i);
      }
    }
    for (int i = removes.length - 1; i >= 0; i--) {
      bulbList.removeAt(removes[i]);
    }
    return bulbList;
  }
}

class CompleteRound {
  final CompleteBoard cBoard;
  final List<Node> solution;
  final List<Node> bannedList;

  CompleteRound(this.cBoard, this.solution, this.bannedList);

  void printValues() {
    print("*******************");
    //cBoard.printValues();
    print(
        'CompleteRound(${cBoard.getValues()}, ${nodeListValues(solution)}, ${nodeListValues(bannedList)})');
    //print(solution);
    print("*******************");
  }

//CompleteRound (top level)
  void printCompact() {
    //print("//*******************");
    //cBoard.printValues();
    cBoard.printCompact();
    print('solutionP.add(${compactNodeListValues(solution)});');
    print('bannedP.add(${compactNodeListValues(bannedList)});');
    //print(solution);
    print("//*******************");
  }
}

String nodeListValues(List<Node> nList) {
  String values = '[';
  nList.forEach((element) => values += '${element.getValues()},');
  if (values.length > 2 &&
      values.substring(values.length - 2, values.length - 1) == ',') {
    values = values.substring(0, values.length - 2);
  }
  values += ']';
  return values;
}

//node list for solution and banned nodes
String compactNodeListValues(List<Node> nList) {
  String values = '[';
  nList.forEach((element) => values += '${element.getCompact()}');
  if (values.length >= 2 &&
      values.substring(values.length - 2, values.length - 0) == ', ') {
    values = values.substring(0, values.length - 2);
  }
  values += ']';
  return values;
}

/*
class MyButton extends StatelessWidget {
  MyButton(
      this.buttonMinWidth,
      this.buttonMinHeight,
      this.buttonText,
      this.buttonTextSize,
      this.paddingLeft,
      this.paddingRight,
      this.paddingTop,
      this.paddingBottom,
      this.runFunction,
      this.isSub);

  final double buttonMinWidth;
  final double buttonMinHeight;
  final String buttonText;
  final double buttonTextSize;
  final double paddingLeft;
  final double paddingRight;
  final double paddingTop;
  final double paddingBottom;
  final Function runFunction;
  final bool isSub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: paddingLeft,
          top: paddingTop,
          right: paddingRight,
          bottom: paddingBottom),
      child: Listener(
          onPointerDown: (e) {
            runFunction();
          },
          child: RawMaterialButton(
              constraints: new BoxConstraints(
                minHeight: buttonMinHeight,
                minWidth: buttonMinWidth,
              ),
              fillColor: isSub ? Colors.lightBlue : Colors.blue,
              //textStyle: TextStyle(color: buttonTextColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(80)),
              splashColor: Colors.orange,
              onPressed: () {
                //gMod.submit();
              },
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: buttonTextSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ))),
    );
  }
}
*/

double getHeight(BuildContext context) {
  //compensate for left/bottom/right/top padding for OS stuff
  double paddingHeight = MediaQuery.of(context).padding.top +
      MediaQuery.of(context).padding.bottom;
  return MediaQuery.of(context).size.height - paddingHeight;
}

double getWidth(BuildContext context) {
  //compensate for left/bottom/right/top padding for OS stuff
  double paddingWidth = MediaQuery.of(context).padding.left +
      MediaQuery.of(context).padding.right;
  double paddingHeight = MediaQuery.of(context).padding.top +
      MediaQuery.of(context).padding.bottom;
  double effectiveWidth = math.min(
      MediaQuery.of(context).size.width - paddingWidth,
      (MediaQuery.of(context).size.height - paddingHeight) * 1.1);
  return effectiveWidth;
}

math.Point getBlastPoint(double sWidth, double sHeight, double radius) {
  final rng = math.Random();
  double x;
  double y;

  //ensure it's to the left or right of screen
  x = (sWidth / 2) -
      radius +
      (rng.nextInt(2) * 2 - 1) *
          (sWidth * .1 * rng.nextDouble() + sWidth + radius);
  y = (sHeight / 2) -
      radius +
      (rng.nextInt(2) * 2 - 1) * (sHeight * .75 * rng.nextDouble());

  return math.Point(x, y);
}

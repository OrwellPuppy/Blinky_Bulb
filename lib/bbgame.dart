import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:blinky_bulb/globals.dart';
import 'package:blinky_bulb/complete_board.dart';
import 'package:blinky_bulb/levels.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:flutter/foundation.dart';

//void main() => runApp(GameScreen());

class GameScreen extends StatelessWidget {
  GameScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //color of the OS bars
      backgroundColor: Colors.deepOrangeAccent,
      body: SafeArea(
          child: Container(
        //needed to provide size for the layoutbuilder child?
        color: Colors.black,
        child: LayoutBuilder(builder: (context, constraints) {
          double top = .1;
          double bottom = .1;
          double middle = 1 - top - bottom;
          // Screen is split vertically into three sections
          double topSize = constraints.maxHeight * top;
          double bottomSize = constraints.maxHeight * bottom;
          double middleSize = constraints.maxHeight * middle;
          //top section horizontal divisions
          double exitButtonWidth = constraints.maxWidth * .2;
          double selectionsCounterWidth = constraints.maxWidth * .5;
          double levelLabelWidth = constraints.maxWidth * .2;
          double horzPads = constraints.maxWidth * .01;
          //other sizes
          double buttonTopPad = bottomSize * .1;
          double clearButtonWidth = constraints.maxWidth * .39;
          double clueButtonWidth = constraints.maxWidth * .2;
          double sidePads = constraints.maxWidth * .02;

          var rMod = Provider.of<RoundModel>(context, listen: false);
          return Column(children: [
            Container(
                color: Colors.grey[500],
                height: topSize,
                child: Padding(
                    padding: EdgeInsets.only(
                        left: sidePads, top: 0, right: sidePads, bottom: 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          new MyButton(
                              exitButtonWidth,
                              1,
                              'exit',
                              topSize * .33,
                              0,
                              horzPads,
                              buttonTopPad,
                              buttonTopPad, () {
                            rMod.gameOver(context);
                            Navigator.pop(context);
                          }, false),
                          Consumer<RoundModel>(
                              builder: (context, upMod, child) {
                            return SelectionsCounter(
                                topSize,
                                selectionsCounterWidth,
                                upMod.lights.cBoard.selectionsMax,
                                upMod.lights.cBoard.selectionsMax -
                                    upMod.selectCount,
                                buttonTopPad,
                                rMod.gameType,
                                upMod.timeRemaining);
                          }),
                          SizedBox(
                              height: topSize,
                              width: levelLabelWidth,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      rMod.gameType == 'prog'
                                          ? 'level'
                                          : 'win streak',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: topSize * .23,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                    Text(
                                      '${rMod.thisLevelOrStreak}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'roboto',
                                        fontSize: topSize * .43,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.yellow,
                                      ),
                                    )
                                  ])),
                        ]))),
            Selector<RoundModel, int>(
              //trigger rebuild with new version
              builder: (context, value, child) =>
                  MiddleScreen(constraints, middleSize),
              selector: (buildContext, myModel) => myModel.version,
            ),
            Container(
                color: Colors.grey[900],
                height: bottomSize,
                child: Consumer<RoundModel>(builder: (context, upMod, child) {
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BottomButton(
                            topSize,
                            clueButtonWidth,
                            buttonTopPad,
                            rMod.triggerClue,
                            'clue',
                            true,
                            upMod.clueA,
                            'clueA',
                            upMod.clueARelease),
                        BottomButton(
                            topSize,
                            clearButtonWidth,
                            buttonTopPad,
                            rMod.clearSelections,
                            'clear',
                            true,
                            true,
                            'clear',
                            true),
                        BottomButton(
                            topSize,
                            clueButtonWidth,
                            buttonTopPad,
                            rMod.triggerClue,
                            'clue',
                            true,
                            upMod.clueB,
                            'clueB',
                            upMod.clueBRelease),
                      ]);
                }))
          ]);
        }),
      )),
    );
  }
}

class SelectionsCounter extends StatelessWidget {
  final double height;
  final double width;
  final int selectionsMax;
  final int selectionsCurrent;
  final double buttPad;
  final isSub = false;
  final String gameType;
  final int timeRemaining;
  static const double spacerPercent = 0.1; //percent of diameter
  SelectionsCounter(this.height, this.width, this.selectionsMax,
      this.selectionsCurrent, this.buttPad, this.gameType, this.timeRemaining);

  @override
  Widget build(BuildContext context) {
    List<Widget> colList = [];
    double clockHeight = (height - buttPad * 0) * .6;
    Widget clock = Container(
      width: math.min(width * (1 - spacerPercent * 2), clockHeight * 1.8),
      height: clockHeight,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.grey[800],
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Center(
          child: Text(
        '$timeRemaining',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'roboto',
          fontSize: clockHeight * .85,
          fontWeight: FontWeight.w600,
          color: Colors.yellow,
        ),
      )),
    );

    double circleWidthMax =
        width / (selectionsMax + (selectionsMax + 1) * spacerPercent);
    double circleSize;
    if (gameType == 'roul') {
      circleSize = math.min(circleWidthMax, (height - buttPad * 0) * .3);
    } else {
      circleSize = math.min(circleWidthMax, (height - buttPad * 2));
    }

    List<Widget> selectCircles = [];
    for (int i = selectionsMax; i > 0; i--) {
      selectCircles.add(Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selectionsCurrent >= i ? Colors.greenAccent : Colors.grey,
          border: Border.all(
            color:
                selectionsCurrent >= i ? Colors.greenAccent : Colors.blueGrey,
          ),
        ),
      ));
    }
    if (gameType == 'roul') {
      colList.add(clock);
    }
    colList.add(Row(
        //change to MainAxisAlignment.spaceBetween to get rid of start/end auto space
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: selectCircles));

    Widget customCircles = SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: colList,
        ));

    return customCircles;
  }
}

class BottomButton extends StatelessWidget {
  final double height;
  final double width;
  final double buttPad;
  final Function runFunction;
  final isSub = false;
  final String bText;
  final bool buttonEnabled = true;
  final bool isVisible;
  final bool isEnabled;
  final String buttonID;
  final bool released;
  static const double spacerPercent = 0.1; //percent of diameter
  BottomButton(this.height, this.width, this.buttPad, this.runFunction,
      this.bText, this.isVisible, this.isEnabled, this.buttonID, this.released);
  @override
  Widget build(BuildContext context) {
    Widget customButton = Padding(
      padding:
          EdgeInsets.only(left: 0, top: buttPad, right: 0, bottom: buttPad),
      child: AnimatedOpacity(
          opacity: released ? 1 : 0,
          duration: const Duration(milliseconds: 600),
          child: ElevatedButton(
              onPressed: isEnabled
                  ? () {
                      runFunction(buttonID);
                    }
                  : null,
              child: SizedBox(
                  width: width,
                  child: Center(
                    child: Text(
                      bText,
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: height / 4,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )))),
    );
    return customButton;
  }
}

class MiddleScreen extends StatelessWidget {
  final BoxConstraints constraints;
  final double middleSize;

  MiddleScreen(this.constraints, this.middleSize);

  @override
  Widget build(BuildContext context) {
    var rMod = Provider.of<RoundModel>(context, listen: false);
    Widget myWidget;
    if (rMod.lights.cBoard.isHexBoard) {
      myWidget = Container(
          height: middleSize,
          child: PolygonGrid(
              rMod.lights.cBoard.rows,
              rMod.lights.cBoard.columns,
              constraints.maxWidth,
              middleSize,
              rMod.lights.cBoard.cornerStart,
              0.03,
              rMod.lights.cBoard.gameBoard));
    } else if (!rMod.lights.cBoard.isHexBoard) {
      myWidget = Container(
          height: middleSize,
          child: SquareGrid(
              rMod.lights.cBoard.rows,
              rMod.lights.cBoard.columns,
              constraints.maxWidth,
              middleSize,
              rMod.lights.cBoard.cornerStart,
              0.03,
              rMod.lights.cBoard.gameBoard));
    }
    return myWidget;
  }
}

class PolygonGrid extends StatelessWidget {
  final int rows; //number of rows in grid
  final int columns; //number of columns in grid
  final double osWidth; //original-screen grid space width
  final double osHeight; //original-screen grid space height

  final bool cornerStart; //start with hex in top left corner (true), or not
  final double spacing; //spacing as percent of radius
  final List<List<NodeType>> gameBoard; //type of bulbs

  PolygonGrid(this.rows, this.columns, this.osWidth, this.osHeight,
      this.cornerStart, this.spacing, this.gameBoard);

  @override
  Widget build(BuildContext context) {
    double sWidth; //grid space width
    double sHeight; //grid space height
    print("build: HexGrid");
    double radius;
    double littleRadius;
    double widthSlack;
    double heightSlack;
    int startTop = 1;
    int oppoStartTop = 0;
    double spacingSize;
    if (cornerStart) {
      startTop = 0;
      oppoStartTop = 1;
    }
    //initialize my list of hexagons to include a non-positioned transparent container
    //which will cause the stack to expand to the size of the parent widget
    List<Widget> gonList = [Container()];
    bool flip = false;
    //double denseSide = ((columns * 3 / 4) + 1 / 4) * (math.sqrt(3) / 2);
    //double spacedSide = (rows / 2 + .5);

    //max inner-hex-diameter size feasible based on columns/sWidth
    double colMaxD = osWidth / ((columns * 3 / 4) + 1 / 4) * (math.sqrt(3) / 2);
    double colMaxDr =
        osHeight / ((columns * 3 / 4) + 1 / 4) * (math.sqrt(3) / 2);
    //max inner--diameter size feasible base on rows/sHeight
    double rowMaxD = osHeight / (rows / 2 + .5);
    double rowMaxDr = osWidth / (rows / 2 + .5);
    flip = math.min(colMaxD, rowMaxD) < math.min(colMaxDr, rowMaxDr);
    if (flip) {
      sWidth = osHeight;
      sHeight = osWidth;
    } else {
      sWidth = osWidth;
      sHeight = osHeight;
    }

    //max inner-hex-diameter size feasible based on columns/sWidth
    colMaxD = math.min(
        sWidth / ((columns * 3 / 4) + 1 / 4) * (math.sqrt(3) / 2), sWidth / 5);
    //max inner--diameter size feasible base on rows/sHeight
    rowMaxD = math.min(sHeight / (rows / 2 + .5), sHeight / 5);

    if (rowMaxD >= colMaxD) {
      //case: width/columns is the limiting dimension
      littleRadius = colMaxD / 2;
      radius = littleRadius / (math.sqrt(3) / 2);
      spacingSize = radius * spacing;
      heightSlack = sHeight - ((littleRadius * (rows + 1)));
      //widthSlack = 0;
      widthSlack = sWidth - (radius * 2 + (3 / 4) * radius * 2 * (columns - 1));
    } else {
      //case: height/rows is the limiting dimension
      littleRadius = rowMaxD / 2;
      radius = littleRadius / (math.sqrt(3) / 2);
      spacingSize = radius * spacing;
      widthSlack = sWidth - (radius * 2 + (3 / 4) * radius * 2 * (columns - 1));
      //heightSlack = 0;
      heightSlack = sHeight - ((littleRadius * (rows + 1)));
    }

    //print('sWidth: $sWidth; sHeight: $sHeight');
    //print('rows: $rows cols: $columns radius: $radius');
    //add the hexagons to the list for the Stack
    double xCoord;
    double yCoord;
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < columns; j++) {
        if (((j % 2) == startTop) && ((i % 2) == 0) ||
            ((j % 2) == oppoStartTop) && ((i % 2) == 1)) {
          //Outer-Circle
          xCoord =
              (j) * radius * (3 / 2) + (radius - littleRadius) + widthSlack / 2;
          yCoord = (littleRadius * i) + heightSlack / 2;
          if (flip) {
            double calcCoord = xCoord;
            xCoord = yCoord;
            yCoord = calcCoord;
          }
          gonList.add(
            Positioned(
              top: yCoord,
              left: xCoord,
              child: new Bulb(radius, littleRadius, spacingSize, i, j,
                  gameBoard[i][j], flip, 6),
            ),
          );
        }
      }
    }
    //go back and add FacePaint
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < columns; j++) {
        if (((j % 2) == startTop) && ((i % 2) == 0) ||
            ((j % 2) == oppoStartTop) && ((i % 2) == 1)) {
          // add FacePaint
          if (gameBoard[i][j].type == 1) {
            xCoord = (j) * radius * (3 / 2) +
                (radius - littleRadius) +
                widthSlack / 2;
            yCoord = (littleRadius * i) + heightSlack / 2;
            if (flip) {
              double calcCoord = xCoord;
              xCoord = yCoord;
              yCoord = calcCoord;
            }
            gonList.add(
              Positioned(
                  top: yCoord,
                  left: xCoord,
                  child: new CustomPaint(
                      painter: FacePainter(Offset(littleRadius, littleRadius),
                          littleRadius, gameBoard[i][j], flip))),
            );
          }
        }
      }
    }
    return Stack(
      children: gonList,
    );
  }
}

class SquareGrid extends StatelessWidget {
  final int rows; //number of rows in grid
  final int columns; //number of columns in grid
  final double osWidth; //original-screen grid space width
  final double osHeight; //original-screen grid space height
  final bool cornerStart; //start with hex in top left corner (true), or not
  final double spacing; //spacing as percent of radius
  final List<List<NodeType>> gameBoard; //type of bulbs
  SquareGrid(this.rows, this.columns, this.osWidth, this.osHeight,
      this.cornerStart, this.spacing, this.gameBoard);

  @override
  Widget build(BuildContext context) {
    double sWidth; //grid space width
    double sHeight; //grid space height
    print("build: SquareGrid");
    double bulbSize;
    double widthSlack;
    double heightSlack;
    double spacingSize;
    int minSqNumWidth =
        5; //caps maximum square size by ensuring at least this many can fit
    //initialize my list of squares to include a non-positioned transparent container
    //which will cause the stack to expand to the size of the parent widget
    List<Widget> gonList = [Container()];
    bool flip = false;
    if ((osHeight > osWidth && rows > columns) ||
        (osHeight > osWidth && rows > columns)) {
      sWidth = osWidth;
      sHeight = osHeight;
      flip = false;
    } else {
      sWidth = osHeight;
      sHeight = osWidth;
      flip = true;
    }

    //max inner-hex-diameter size feasible based on columns/sWidth
    double colMaxD = sWidth / math.max(columns, minSqNumWidth);
    //max inner--diameter size feasible base on rows/sHeight
    double rowMaxD = sHeight / math.max(rows, minSqNumWidth);

    bulbSize = math.min(rowMaxD, colMaxD);
    heightSlack = sHeight - (bulbSize * rows);
    widthSlack = sWidth - (bulbSize * columns);
    spacingSize = bulbSize * spacing;

    //add the squares to the list for the Stack
    double xCoord;
    double yCoord;
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < columns; j++) {
        xCoord = j * bulbSize + widthSlack / 2;
        yCoord = i * bulbSize + heightSlack / 2;
        if (flip) {
          double calcCoord = xCoord;
          xCoord = yCoord;
          yCoord = calcCoord;
        }
        gonList.add(
          Positioned(
            top: yCoord,
            left: xCoord,
            child: new Bulb(math.sqrt(2 * math.pow(bulbSize / 2, 2)),
                bulbSize / 2, spacingSize, i, j, gameBoard[i][j], flip, 4),
          ),
        );
      }
    }
    //go back and add FacePaint
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < columns; j++) {
        // add FacePaint
        if (gameBoard[i][j].type == 1) {
          xCoord = j * bulbSize + widthSlack / 2;
          yCoord = bulbSize * i + heightSlack / 2;
          if (flip) {
            double calcCoord = xCoord;
            xCoord = yCoord;
            yCoord = calcCoord;
          }
          gonList.add(
            Positioned(
                top: yCoord,
                left: xCoord,
                child: new CustomPaint(
                    painter: FacePainter(Offset(bulbSize / 2, bulbSize / 2),
                        bulbSize / 2, gameBoard[i][j], flip))),
          );
        }
      }
    }

    return Stack(
      children: gonList,
    );
  }
}

class Bulb extends StatelessWidget {
  final double radius;
  final double littleRadius;
  final double spacingSize;
  final int row;
  final int col;
  final NodeType nodeType;
  final bool flip;
  final int sides;

  Bulb(this.radius, this.littleRadius, this.spacingSize, this.row, this.col,
      this.nodeType, this.flip, this.sides);

  @override
  Widget build(BuildContext context) {
    //TODO: convert Provider to Selector for the on/off state?,
    // and have the Bulb take the Type and such as static(?) parameters,
    //thus minimizing rebuilds
    var rMod = Provider.of<RoundModel>(context, listen: true);

    double calcSize = littleRadius * 2 - .8;
    return Stack(children: [
      if (rMod.clueState[row][col])
        //if (rMod.clueList[0]?.row == row && rMod.clueList[0]?.col == col)
        //if (nodeType.type == 1) //TODO: clue here
        CustomPaint(
          painter: PolygonPainter(Offset(littleRadius, littleRadius),
              radius - .5, nodeType, flip, sides),
        ),
      Listener(
          onPointerDown: (e) {
            rMod.tap(row, col);
            if (rMod.lights.checkIfSolved()) {
              rMod.gameOver(context);
            }
          },
          child: Container(
            width: calcSize,
            height: calcSize,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              color: rMod.lights.lightState[row][col]
                  ? rMod.onColor
                  : rMod.lights.cBoard.gameBoard[row][col].type == 2
                      ? Colors.black
                      : rMod.offColor,
              border: Border.all(
                color: rMod.lights.cBoard.gameBoard[row][col].type == 2
                    ? Colors.black
                    : rMod.bannedState[row][col]
                        ? Colors.red
                        : rMod.selectState[row][col]
                            ? Colors.greenAccent
                            : rMod.lights.lightState[row][col]
                                ? rMod.onColor
                                : rMod.offColor,
                width: 4,
              ),
            ),
            /* SHOWs COORDS FOR TESTING
            child: Center(
                child: Container(
              child: Text(
                '$row, $col',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: littleRadius * .5, color: Colors.deepOrange),
              ),
            )),*/
          )),
    ]);
  }
}

//Hexagon Paint Widget
class PolygonPainter extends CustomPainter {
  final double radius;
  final Offset center;
  final NodeType nodeType;
  final bool flip;
  final int sides;

  PolygonPainter(
      this.center, this.radius, this.nodeType, this.flip, this.sides);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    paint.color = Color.fromARGB(255, 150, 250, 150);
    //paint.style=PaintingStyle.stroke;
    //paint.strokeWidth=1;
    Path path = createPolygonPath();
    canvas.drawPath(path, paint);
  }

  Path createPolygonPath() {
    final path = Path();
    var angle = (math.pi * 2) / sides;
    Offset firstPoint;
    double flipOffset = math.pi / 4;

    if (flip && sides == 6) {
      flipOffset = 0.5;
    } else if (!flip && sides == 6) {
      flipOffset = 0;
    }
    firstPoint = Offset(radius * math.cos(0.0 + flipOffset),
        radius * math.sin(0.0 + flipOffset));
    //firstPoint = Offset(radius, 0);// 1,0 / 0,-1
    path.moveTo(firstPoint.dx + center.dx, firstPoint.dy + center.dy);
    for (int i = 1; i <= sides; i++) {
      double x = radius * math.cos(angle * i + flipOffset) + center.dx;
      double y = radius * math.sin(angle * i + flipOffset) + center.dy;
      path.lineTo(x, y);
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

//FacePaint Widget
class FacePainter extends CustomPainter {
  static const int SIDES = 6;
  final double radius;
  final Offset center;
  final NodeType nodeType;
  final bool flip;

  FacePainter(this.center, this.radius, this.nodeType, this.flip);

  @override
  void paint(Canvas canvas, Size size) {
    Paint extraPaint = Paint();
    extraPaint.color = Colors.blue;
    Path path = createPointerPath(nodeType);
    //extraPaint.style=PaintingStyle.stroke;
    // extraPaint.strokeWidth=2;
    canvas.drawPath(path, extraPaint);
  }

  Path createPointerPath(NodeType nodeType) {
    final double spacing = 0.02; //width of back two points of triangle
    final double pointerDepth = 0.6; //back two points of triangle
    final double lineWidth = 0.14;
    final double startDepth = .7; //starting point behind circle center
    final double extension = 1; //front point dist out of circle
    final path = Path();
    var angle = (math.pi * 2) / SIDES;
    double x;
    double y;

    getPath(double i, double z) {
      x = (radius * startDepth) * math.cos(angle * (z + .5)) + center.dx;
      y = (radius * startDepth) * math.sin(angle * (z + .5)) + center.dy;
      path.moveTo(x, y);
      x = (radius * pointerDepth) * math.cos(angle * (i + .5 - lineWidth)) +
          center.dx;
      y = (radius * pointerDepth) * math.sin(angle * (i + .5 - lineWidth)) +
          center.dy;
      path.lineTo(x, y);
      x = (radius * pointerDepth) * math.cos(angle * i + spacing) + center.dx;
      y = (radius * pointerDepth) * math.sin(angle * i + spacing) + center.dy;
      path.lineTo(x, y);
      x = (radius * extension) * math.cos(angle * (i + .5)) + center.dx;
      y = (radius * extension) * math.sin(angle * (i + .5)) + center.dy;
      path.lineTo(x, y);
      x = (radius * pointerDepth) * math.cos(angle * (i + 1) - spacing) +
          center.dx;
      y = (radius * pointerDepth) * math.sin(angle * (i + 1) - spacing) +
          center.dy;
      path.lineTo(x, y);
      x = (radius * pointerDepth) * math.cos(angle * (i + .5 + lineWidth)) +
          center.dx;
      y = (radius * pointerDepth) * math.sin(angle * (i + .5 + lineWidth)) +
          center.dy;
      path.lineTo(x, y);

      x = (radius * startDepth) * math.cos(angle * (z + .5)) + center.dx;
      y = (radius * startDepth) * math.sin(angle * (z + .5)) + center.dy;
      path.lineTo(x, y);
    }

    if (nodeType.north || nodeType.truNorth) {
      if (flip) {
        getPath(2.5, -.5);
      } else {
        getPath(4, 1);
      }
    }
    if (nodeType.northEast) {
      if (flip) {
        getPath(1.5, 4.5);
      } else {
        getPath(5, 2);
      }
    }
    if (nodeType.southEast) {
      if (flip) {
        getPath(6.5, 3.5);
      } else {
        getPath(6, 3);
      }
    }
    if (nodeType.south || nodeType.truSouth) {
      if (flip) {
        getPath(-.5, 2.5);
      } else {
        getPath(1, 4);
      }
    }
    if (nodeType.southWest) {
      if (flip) {
        getPath(4.5, 1.5);
      } else {
        getPath(2, 5);
      }
    }
    if (nodeType.northWest) {
      if (flip) {
        getPath(3.5, 6.5);
      } else {
        getPath(3, 6);
      }
    }
    if (nodeType.truWest) {
      if (flip) {
        getPath(4, 1);
      } else {
        getPath(2.5, 5.5);
      }
    }
    if (nodeType.truEast) {
      if (flip) {
        getPath(1, 4);
      } else {
        getPath(5.5, 8.5);
      }
    }
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class RoundModel extends ChangeNotifier {
  final int thisLevelOrStreak;
  LightState lights;
  List<List<bool>> selectState;
  List<Node> bannedList = []; //node list of banned nodes
  List<List<bool>> bannedState;
  List<List<bool>> clueState; //whether each node is highlighted by a used clue
  bool clueA = false; //whether the first clue is available
  bool clueB = false; //whether the second clue is available
  bool clueARelease = false; //whether clueA has been released
  bool clueBRelease = false; //whether clueB has been released
  List<Node> clueList = []; //solution list only used to generate clues
  int selectCount = 0; //count of selected nodes
  Color onColor = Colors.yellow;
  Color offColor = Colors.grey[600];
  int version = 0;
  String gameType;
  Timer timer;
  int timeRemaining = 40;

  RoundModel(BuildContext context, this.gameType, this.thisLevelOrStreak) {
    print('roundModel Built');
    CompleteRound cr;
    //start up the games based on gameType
    if (gameType == 'roul') {
      //generate simple round for temporary loading screen
      cr = new CompleteRound(new CompleteBoard()..loadLoadingScreen(), [], []);
      unpackMyCompleteRound(cr);
      //generate round using an async compute
      generateMyCompleteRound(cr);
    } else if (gameType == 'prog') {
      Levels mySavedLevels = new Levels();
      cr = mySavedLevels.loadLevel(thisLevelOrStreak - 1);
      unpackMyCompleteRound(cr);
      version++;
      notifyListeners();
      //print to console
      cr.printCompact();
      //for testing
      //cr.printValues();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    print('round model disposed.');
    super.dispose();
  }

  generateMyCompleteRound(CompleteRound cr) async {
    cr = await compute(generator, 1); //had to pass a parameter..
    unpackMyCompleteRound(cr);
    version++;
    notifyListeners();
    startTimer();
    //print to console
    cr.printCompact();
  }

  unpackMyCompleteRound(CompleteRound cr) {
    //unpack the CompleteRound into RoundModel vars
    bannedList = cr.bannedList;
    clueList = cr.solution;
    //initialize variables
    lights = new LightState(cr.cBoard, cr.solution);
    selectState = List.generate(
        lights.cBoard.rows,
        (int i) => List.generate(lights.cBoard.columns, (int j) => false,
            growable: false),
        growable: false);
    bannedState = List.generate(
        lights.cBoard.rows,
        (int i) => List.generate(lights.cBoard.columns, (int j) => false,
            growable: false),
        growable: false);
    clueState = List.generate(
        lights.cBoard.rows,
        (int i) => List.generate(lights.cBoard.columns, (int j) => false,
            growable: false),
        growable: false);
    //calc bannedState from bannedList
    bannedList
        .forEach((element) => bannedState[element.row][element.col] = true);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        print('time: $timeRemaining');
        timeRemaining--;
        if (timeRemaining <= 0) {
          timer.cancel();

          clueARelease = true;
          clueBRelease = true;
          clueA = true;
          clueB = true;
          //TODO: add end-of-time logic here
        }
        notifyListeners();
      },
    );
  }

  void gameOver(BuildContext context) {
    timer?.cancel();
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    if (lights.checkIfSolved()) {
      //todo: victory code here
      print('VICTORY!!');

      if (gameType == 'prog') {
        sMod.fileProgressionLevel(thisLevelOrStreak + 1);
      } else if (gameType == 'roul' && timeRemaining > 0) {
        //win condition
        sMod.updateWinStreak(true);
      }
    } else if (gameType == 'roul') {
      //lose condition
      if (sMod.checkHighScore()) {
        sMod.updateHighScore('testName');
      }
      sMod.updateWinStreak(false);
    }
  }

  static bool checkNoDupes(List<Node> nodeList) {
    int digits = nodeList.length;
    for (int i = 0; i < digits; i++) {
      for (int j = i + 1; j < digits; j++) {
        if (nodeList[i].row == nodeList[j].row &&
            nodeList[i].col == nodeList[j].col) {
          return false;
        }
      }
    }
    return true;
  }

  static List<Node> getRandomNodes(CompleteBoard myBoard) {
    var rng = new math.Random();
    int x1;
    int y1;
    List<Node> myList = [];
    for (var i = 0; i < myBoard.selectionsMax; i++) {
      do {
        x1 = rng.nextInt(myBoard.rows);
        y1 = rng.nextInt(myBoard.columns);
      } while (!myBoard.checkExists(x1, y1));
      myList.add(Node(x1, y1));
    }
    if (checkNoDupes(myList)) {
      return myList;
    } else {
      print("discarded duplicate");
      return getRandomNodes(myBoard);
    }
  }

  void clearSelections(String buttonID) {
    for (var i = 0; i < selectState.length; i++) {
      for (var j = 0; j < selectState[i].length; j++) {
        if (selectState[i][j]) {
          tap(i, j);
        }
      }
    }
  }

  void tap(int row, int col) {
    if (!bannedState[row][col] &&
        selectCount > (lights.cBoard.selectionsMax - 1) &&
        !selectState[row][col] &&
        lights.cBoard.gameBoard[row][col].type != 2) {
      //TODO: add animation for reached-max-selections here
    } else if (!bannedState[row][col] &&
        lights.cBoard.gameBoard[row][col].type != 2) {
      updateSelectState(row, col, selectState);
      lights.updateNode(row, col);
      notifyListeners();
    }
  }

  void triggerClue(String buttonID) {
    if (clueList.length > 0) {
      var rng = new math.Random();
      int clueIndex = rng.nextInt(clueList.length);
      clueState[clueList[clueIndex].row][clueList[clueIndex].col] = true;
      clueList.removeAt(clueIndex);

      notifyListeners();
    }
    if (buttonID == 'clueA') {
      clueA = false;
    } else if (buttonID == 'clueB') {
      clueB = false;
    }
  }

  void updateSelectState(int row, int col, List<List<bool>> selectState) {
    if (selectState[row][col]) {
      selectCount--;
    } else {
      selectCount++;
    }
    selectState[row][col] = !selectState[row][col];
  }

  static void printNodeList(String start, List<Node> myList) {
    String content = '';
    for (int i = 0; i < myList.length; i++) {
      content += '[${myList[i].row},${myList[i].col}]';
    }
    print('$start $content');
  }

  static bool isBadBoard(List<List<Node>> solutions, int selections) {
    //checks for case that there's a solution with fewer than max selections
    for (int i = 0; i < solutions.length; i++) {
      if (solutions[i].length != selections) {
        return true;
      }
    }
    return false;
  }

  static List<Node> getBannedNodes(
      List<List<Node>> roughList, List<Node> solution) {
    List<Node> banned = [];
    for (int i = 0; i < roughList.length; i++) {
      for (int j = 0; j < roughList[i].length; j++) {
        if (isNodeInList(roughList[i][j], banned)) {
          break;
        }
        if (!isNodeInList(roughList[i][j], solution)) {
          banned.add(roughList[i][j]);
          break;
        }
      }
    }
    return banned;
  }

  static bool isNodeInList(Node myNode, List<Node> myList) {
    for (int i = 0; i < myList.length; i++) {
      if (myNode.row == myList[i].row && myNode.col == myList[i].col) {
        return true;
      }
    }
    return false;
  }

  static List<List<Node>> solver(
      CompleteBoard myBoard, int sCount, LightState thisLightState) {
    List<List<Node>> allSolutions = [];
    int feasCount = 0;
    List<Node> cList =
        getInitialList(myBoard, sCount); //current solution to check
    List<Node> startNodes = getInitialList(myBoard, sCount);
    do {
      feasCount++;
      if (thisLightState.checkIfSolution(cList)) {
        allSolutions.add(cList);
        //print('found');
      }
      cList =
          incrementSolution(myBoard, cList, startNodes[0], cList.length - 1);
    } while (!(checkIfIdentical(cList, startNodes)) && feasCount < 1000000);
    if (feasCount >= 3000000) {
      print('***ERROR: solver max reached***');
    }
    //get solution to check
    if (sCount > 1) {
      allSolutions += solver(myBoard, sCount - 1, thisLightState);
    }
    return allSolutions;
  }

  static List<Node> getInitialList(CompleteBoard myBoard, int listLength) {
    List<Node> cList = []; //current solution to check
    int thisRow = 0;
    int thisCol = -1;
    int errCount = 0;
    for (int i = 0; i < listLength; i++) {
      do {
        thisCol++;
        //while ((thisCol - thisRow * cols) >= cols) {
        if (thisCol >= myBoard.columns) {
          thisRow++;
          thisCol = 0;
          errCount++;
          if (errCount > 10000) {
            print('***ERROR: broke at getInitialList***');
          }
        }
      } while (!myBoard.checkExists(thisRow, thisCol));
      cList.add(new Node(thisRow, thisCol));
    }
    return cList;
  }

  static bool checkIfIdentical(List<Node> nodeListA, List<Node> nodeListB) {
    for (int i = 0; i < nodeListA.length; i++) {
      if (nodeListA[i].row != nodeListB[i].row ||
          nodeListA[i].col != nodeListB[i].col) {
        return false;
      }
    }
    return true;
  }

  static List<Node> incrementSolution(
      myBoard, List<Node> lastS, Node startNode, int digit) {
    List<Node> newSolution = [];
    for (int i = 0; i < lastS.length; i++) {
      newSolution.add(lastS[i]);
    }
    Node thisNode;

    thisNode = incrementNode(lastS[digit], myBoard);
    if (thisNode.row == startNode.row &&
        thisNode.col == startNode.col &&
        digit > 0) {
      //if turnover
      newSolution =
          incrementSolution(myBoard, newSolution, startNode, digit - 1);
      newSolution[digit] = newSolution[digit - 1];
      newSolution = incrementSolution(myBoard, newSolution, startNode, digit);
    } else {
      //no turnover OR final turnover
      newSolution[digit] = thisNode;
    }
    return newSolution;
  }

  static Node incrementNode(Node currentNode, CompleteBoard myBoard) {
    int thisRow = currentNode.row;
    int thisCol = currentNode.col;
    do {
      thisCol++;
      if (thisCol >= myBoard.columns) {
        //if at end of cols
        thisRow++;
        thisCol = 0;
      }
      if (thisRow >= myBoard.rows) {
        //if at end of rows, turnover
        thisRow = 0;
        thisCol = 0;
      }
    } while (!myBoard.checkExists(thisRow, thisCol));
    return new Node(thisRow, thisCol);
  }

//CompleteRound generator() {
  static Future<CompleteRound> generator(int dummyInt) async {
    print('Generating............');
    List<Node> finalSolution;
    List<Node> bannedList = [];
    List<Node> initialSolution;
    List<List<Node>> roughSolutionList;
    int solutionIndex;
    var rngNew = new math.Random();
    CompleteBoard thisBoard;
    do {
      //generate a game board
      thisBoard = new CompleteBoard();
      thisBoard.reroll();
      //get random initial solution for the board
      initialSolution = getRandomNodes(thisBoard);
      //get all possible solutions
      roughSolutionList = solver(thisBoard, thisBoard.selectionsMax,
          LightState(thisBoard, initialSolution));
      roughSolutionList
          .forEach((element) => printNodeList('All Solutions', element));
      print(
          'board generated. bad? ${isBadBoard(roughSolutionList, thisBoard.selectionsMax)}');
      //loop until solutions require max selection
    } while (isBadBoard(roughSolutionList, thisBoard.selectionsMax) ||
        (roughSolutionList.length == 0));
    if (roughSolutionList.length == 1) {
      solutionIndex = 0;
    } else {
      //if multiple solutions, determine banned nodes
      print('multi solutions: ${roughSolutionList.length}');
      solutionIndex = rngNew.nextInt(roughSolutionList.length);
      bannedList =
          getBannedNodes(roughSolutionList, roughSolutionList[solutionIndex]);
    }
    finalSolution = roughSolutionList[solutionIndex];
    printNodeList('final solution:', finalSolution);
    printNodeList('banned:', bannedList);
    //delete arrows from banned nodes for simplicity
    for (int i = 0; i < bannedList.length; i++) {
      if (thisBoard.gameBoard[bannedList[i].row][bannedList[i].col].type == 1) {
        thisBoard.gameBoard[bannedList[i].row][bannedList[i].col]
            .makeTypeZero();
      }
    }
    return new CompleteRound(thisBoard, finalSolution, bannedList);
  }
}
//*****************

//Next figure out how to make the win streak/prog level update
//Next: begin work on Win Animation

//figure out how to deal with pressing back button to avoid a loss in roulette
//re: round generation, maybe make it choose new solution nodes if none are arrows and a fair number of arrows exists
//way to check a saved round for multiple solutions using existing code..

//make the clear/reset button become unavailable when no selections are made?
//figure out how to implement theme with ThemeData.elevatedButtonTheme..
//in addition to numbers, make entire background a "timer" glistening red wave?
//use the blue highlight thing for the clue? dot was cool tho. could make an octagon
//add a dark mode switch?
//add some end-of-round logic
//scale the selection-ring and banned-ring border widths to bulb radius
//make a minimum size for bulbs that's like 7 down 5 across
//rename the game modes "theraputic" and "competitive"?
//consider a "easy" and "hard" mode based on adding a selection/ changing max map size?
//make the clear button have a brief light orange background flash?
//improve the loading screen; remove top/bottom sections and add animation?

//run in Terminal:
//C:\JON\flutter\bin\flutter.bat doctor
//flutter doctor --android-licenses
//C:\JON\flutter\bin\flutter doctor --android-licenses

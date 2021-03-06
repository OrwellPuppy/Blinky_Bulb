import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
//import 'dart:core';
import 'package:provider/provider.dart';
//import 'package:flutter/rendering.dart';
import 'package:blinky_bulb/globals.dart';
import 'package:blinky_bulb/complete_board.dart';
import 'package:blinky_bulb/levels.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:flutter/foundation.dart';

//void main() => runApp(GameScreen());

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myBackground, //color of the OS bars
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          double top = .1;
          double bottom = .1;
          double middle = 1 - top - bottom;
          //screen is split vertically into three sections
          double topSize = constraints.maxHeight * top;
          double middleSize = constraints.maxHeight * middle;
          double bottomSize = constraints.maxHeight - topSize - middleSize;
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
          double smallLabelFontSize =
              math.min(levelLabelWidth, topSize * 1.5) * .17;
          double buttonFontSize = smallLabelFontSize*1.35;
          //text size for 'back button' popup
          double textSizer =
              math.min(getHeight(context) * .01, getWidth(context) * .01);
          double largeFontSize = textSizer * 4 + 6;
          double mediumFontSize = textSizer * 3 + 6;
          var rMod = Provider.of<RoundModel>(context, listen: false);

          Future<bool> _onWillPop() async {
            if (rMod.gameType == 'prog') {
              rMod.exitButtonAction(context);
              return false;
            } else {
              return (await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: backgroundLightContrast,
                      title: Text(
                        'Exit?',
                        style: TextStyle(
                          fontSize: largeFontSize,
                          fontWeight: FontWeight.bold,
                          color: popupTextColor,
                        ),
                      ),
                      //content: new Text('Do you want to exit an App'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'No',
                            style: TextStyle(
                              fontSize: mediumFontSize,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            //Navigator.of(context).pop(true);
                            //var rMod = Provider.of<RoundModel>(context, listen: false);
                            rMod.exitButtonAction(context);
                            //rMod.exitFunction(context);
                          },
                          child: Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: mediumFontSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )) ??
                  false;
            }
          }

          return WillPopScope(
              onWillPop: _onWillPop,
              child: Selector<RoundModel, String>(
                  selector: (buildContext, myModel) => myModel.phase,
                  builder: (context, phase, child) {
                    return AnimatedContainer(
                        duration: explodeDuration,
                        color: (phase == 'game') ? shadeB : myBackground,
                        key: const Key('main'),
                        curve: Curves.easeInCubic,
                        onEnd: () {
                          if (rMod.phase == 'blastOff') {
                            rMod.throwTransitionScreen(context);
                          }
                        },
                        child: Container(
                            color: (phase == 'game')
                                ? myBackground
                                : Colors.transparent,
                            child: Column(children: [
                              AnimatedOpacity(
                                  duration: pieceFade,
                                  curve: pieceCurve,
                                  opacity: phase == 'game' ? 1 : 0,
                                  child: Container(
                                      color: myBackground,
                                      height: topSize,
                                      child: Padding(
                                          padding: EdgeInsets.only(
                                              left: sidePads,
                                              top: 0,
                                              right: sidePads,
                                              bottom: 0),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 0,
                                                        top: buttonTopPad,
                                                        right: horzPads,
                                                        bottom: buttonTopPad),
                                                    child: TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          minimumSize:
                                                              Size.fromWidth(
                                                                  exitButtonWidth),
                                                          textStyle: TextStyle(
                                                              fontSize:
                                                              buttonFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        onPressed: () {
                                                          rMod.exitButtonAction(
                                                              context);
                                                        },
                                                        child: const Text('Exit'))),
                                                Consumer<RoundModel>(builder:
                                                    (context, upMod, child) {
                                                  return SelectionsCounter(
                                                      topSize,
                                                      selectionsCounterWidth,
                                                      upMod.lights.cBoard
                                                          .selectionsMax,
                                                      upMod.lights.cBoard
                                                              .selectionsMax -
                                                          upMod.selectCount,
                                                      buttonTopPad,
                                                      rMod.gameType,
                                                      upMod.timeRemaining,
                                                      smallLabelFontSize);
                                                }),
                                                SizedBox(
                                                    height: topSize,
                                                    width: levelLabelWidth,
                                                    child: Hero(
                                                        tag:
                                                            'level${rMod.thisLevelOrStreak}',
                                                        child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                  padding: EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          buttonTopPad *
                                                                              1,
                                                                          0,
                                                                          0),
                                                                  child:
                                                                      DefaultTextStyle(
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'roboto',
                                                                            fontSize:
                                                                                smallLabelFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color:
                                                                                popupTextColor,
                                                                          ),
                                                                          child:
                                                                              Text(
                                                                            rMod.gameType == 'prog'
                                                                                ? 'level'
                                                                                : 'win streak',
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ))),
                                                              DefaultTextStyle(
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'roboto',
                                                                    fontSize: smallLabelFontSize*1.5,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color:
                                                                        popupTextColor,
                                                                  ),
                                                                  child: Text(
                                                                    '${rMod.thisLevelOrStreak}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ))
                                                            ]))),
                                              ])))),
                              MiddleScreen(constraints, middleSize, phase,
                                  rMod.lights.cBoard),
                              AnimatedOpacity(
                                  duration: pieceFade,
                                  curve: pieceCurve,
                                  opacity: phase == 'game' ? 1 : 0,
                                  child: Container(
                                      color: myBackground,
                                      height: bottomSize,
                                      child: Consumer<RoundModel>(
                                          builder: (context, upMod, child) {
                                        return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              BottomButton(
                                                  clueButtonWidth,
                                                  buttonTopPad,
                                                  rMod.triggerClue,
                                                  'Clue',
                                                  true,
                                                  upMod.clueA,
                                                  'clueA',
                                                  upMod.clueARelease,
                                                  buttonFontSize),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0,
                                                      buttonTopPad * 1,
                                                      0,
                                                      buttonTopPad * 1),
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      rMod.clearSelections();
                                                    },
                                                    child: Icon(
                                                        Icons.restart_alt,
                                                        color: myWhite,
                                                        size: topSize / 2.2),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      minimumSize:
                                                          Size.fromWidth(
                                                              clearButtonWidth),
                                                      textStyle: TextStyle(
                                                          fontSize:
                                                              topSize / 4),
                                                    ),
                                                  )),
                                              BottomButton(
                                                  clueButtonWidth,
                                                  buttonTopPad,
                                                  rMod.triggerClue,
                                                  'Clue',
                                                  true,
                                                  upMod.clueB,
                                                  'clueB',
                                                  upMod.clueBRelease,
                                                  buttonFontSize),
                                            ]);
                                      })))
                            ])));
                  }));
        }),
      ),
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
  final double labelFontSize;

  static const double spacerPercent = 0.1; //percent of diameter
  const SelectionsCounter(
      this.height,
      this.width,
      this.selectionsMax,
      this.selectionsCurrent,
      this.buttPad,
      this.gameType,
      this.timeRemaining,
      this.labelFontSize, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    double clockHeight = (height - buttPad * 0) * .6;
    double widthFactor =
        math.min(width * (1 - spacerPercent), clockHeight * 2.5);
    bool odd;
    bool ending;
    odd = timeRemaining % 2 == 1;
    ending = timeRemaining < 21;
    List<Widget> colList = [];
    Widget clock = Padding(
        padding:
            EdgeInsets.only(top: clockHeight * .02, bottom: clockHeight * .02),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: widthFactor,
          height: clockHeight,
          decoration: BoxDecoration(
            boxShadow: [
              const BoxShadow(
                color: myBackground,
              ),
              BoxShadow(
                color: (odd)
                    ? ((odd && ending) ? shadeC : backgroundLightContrast)
                    : myBackground,
                spreadRadius: -width / 32,
                blurRadius: width / 10,
              ),
            ],
            shape: BoxShape.rectangle,
          ),
          child: Center(
              child: timeRemaining <= 0
                  ? Text(
                      'OUT OF TIME',
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        fontFamily: 'roboto',
                        fontSize: labelFontSize,
                        //fontWeight: FontWeight.w600,
                        color: shadeC,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                          Text(
                            '${((timeRemaining + 1) / 2).floor()}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: clockHeight * .81,
                              fontWeight: FontWeight.w600,
                              color: myWhite,
                            ),
                          ),
                          Icon(Icons.hourglass_top_sharp,
                              size: clockHeight * .4, color: myWhite)
                        ])),
        ));

    double circleWidthMax =
        width / (selectionsMax + (selectionsMax + 1) * spacerPercent);
    double circleSize;
    if (gameType == 'roul') {
      circleSize = math.min(circleWidthMax, (height - buttPad * 0) * .3);
    } else {
      circleSize = math.min(circleWidthMax, (height - buttPad * 2));
    }
    //calcs the amount of excess width space
    double sideSpacerSize = math.max(
            (width -
                circleSize * selectionsMax -
                (selectionsMax - 1) * (circleSize * 0.15)),
            0) /
        2;
    List<Widget> selectCircles = [];
    selectCircles.add(Container(
      width: sideSpacerSize,
    ));
    for (int i = selectionsMax; i > 0; i--) {
      selectCircles.add(Container(
        //padding: EdgeInsets.only(left: 2, top: 0, right: 2, bottom: 0),
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: myBackground,
          border: Border.all(
            color: selectionsCurrent >= i ? shadeD : backgroundLightContrast,
            width: circleSize * 0.12,
          ),
        ),
      ));
    }
    selectCircles.add(Container(
      width: sideSpacerSize,
    ));
    if (gameType == 'roul') {
      colList.add(clock);
    }
    colList.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
  final double bFontSize;
  static const double spacerPercent = 0.1; //percent of diameter
  const BottomButton(
      this.width,
      this.buttPad,
      this.runFunction,
      this.bText,
      this.isVisible,
      this.isEnabled,
      this.buttonID,
      this.released,
      this.bFontSize, {Key? key} ): super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget customButton = Padding(
      padding:
          EdgeInsets.only(left: 0, top: buttPad, right: 0, bottom: buttPad),
      child: AnimatedOpacity(
          opacity: released ? 1 : 0,
          duration: const Duration(milliseconds: 600),
          child: TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.fromWidth(width),
              textStyle: TextStyle(fontSize: bFontSize, color: shadeE),
              side: isEnabled
                  ? const BorderSide(width: 1, color: shadeE)
                  : BorderSide(width: 1, color: backgroundLightContrast),
            ),
            onPressed: isEnabled
                ? () {
                    runFunction(buttonID);
                  }
                : null,
            child: Text(
              bText,
              style: TextStyle(
                fontFamily: 'roboto',
                color: isEnabled ? shadeE : backgroundLightContrast,
              ),
            ),
          )),
    );
    return customButton;
  }
}

class MiddleScreen extends StatelessWidget {
  final BoxConstraints constraints;
  final double middleSize;
  final String phase;
  final CompleteBoard cBoard;

  const MiddleScreen(this.constraints, this.middleSize, this.phase, this.cBoard, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget myWidget;
    if (cBoard.isHexBoard) {
      myWidget = SizedBox(
          height: middleSize,
          child: PolygonGrid(
            cBoard.rows,
            cBoard.columns,
            constraints.maxWidth,
            middleSize,
            cBoard.cornerStart,
            0.03,
            cBoard.gameBoard,
            phase,
          ));
    } else {
      myWidget = SizedBox(
          height: middleSize,
          child: SquareGrid(
            cBoard.rows,
            cBoard.columns,
            constraints.maxWidth,
            middleSize,
            cBoard.cornerStart,
            0.03,
            cBoard.gameBoard,
            phase,
          ));
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
  final String phase;

  const PolygonGrid(this.rows, this.columns, this.osWidth, this.osHeight,
      this.cornerStart, this.spacing, this.gameBoard, this.phase, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build: HexGrid');
    double sWidth; //grid space width
    double sHeight; //grid space height
    double widthSlack;
    double heightSlack;
    //initialize my list of hexagons to include a non-positioned transparent container
    //which will cause the stack to expand to the size of the parent widget
    List<Widget> gonList = [
      AnimatedContainer(
          color: (phase == 'blastOff') ? Colors.transparent : myBackground,
          duration: pieceFade,
          curve: pieceCurve,
          key: const Key('middle'))
    ];
    bool flip = false;
    double radius;
    double littleRadius;
    int startTop = 1;
    int oppoStartTop = 0;
    double spacingSize;

    if (cornerStart) {
      startTop = 0;
      oppoStartTop = 1;
    }

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
          if (phase == 'start' || phase == 'startB') {
            xCoord = osWidth / 2 - littleRadius;
            yCoord = osHeight / 2 - littleRadius;
          } else if (phase == 'blastOff') {
            math.Point theBlastPoint =
                getBlastPoint(osWidth, osHeight, littleRadius);
            xCoord = theBlastPoint.x.toDouble();

            yCoord = theBlastPoint.y.toDouble();
          }
          gonList.add(
            Bulb(radius, littleRadius, spacingSize, i, j, gameBoard[i][j],
                flip, 6, xCoord, yCoord, phase),
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
            if (phase == 'start' || phase == 'startB') {
              xCoord = osWidth / 2 - littleRadius;
              yCoord = osHeight / 2 - littleRadius;
            } else if (phase == 'blastOff') {
              math.Point theBlastPoint =
                  getBlastPoint(osWidth, osHeight, littleRadius);
              xCoord = theBlastPoint.x.toDouble();

              yCoord = theBlastPoint.y.toDouble();
            }

            gonList.add(
              AnimatedPositioned(
                  key: Key('arrow $i $j'),
                  duration: phase == 'blastOff' ? bulbDuration : startDuration,
                  curve: phase == 'blastOff' ? bulbCurve : startCurve,
                  top: yCoord,
                  left: xCoord,
                  child: CustomPaint(
                      painter: FacePainter(Offset(littleRadius, littleRadius),
                          littleRadius, gameBoard[i][j], flip))),
            );
          }
        }
      }
    }
    return Stack(
      clipBehavior: Clip.none,
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
  final String phase;

  const SquareGrid(this.rows, this.columns, this.osWidth, this.osHeight,
      this.cornerStart, this.spacing, this.gameBoard, this.phase, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    print('build: SquareGrid');
    double sWidth; //grid space width
    double sHeight; //grid space height
    double widthSlack;
    double heightSlack;
    List<Widget> gonList = [
      AnimatedContainer(
          color: (phase == 'blastOff') ? Colors.transparent : myBackground,
          duration: pieceFade,
          curve: pieceCurve,
          key: const Key('middle'))
    ];
    bool flip = false;

    double bulbSize;
    double spacingSize;
    int minSqNumWidth =
        5; //caps maximum square size by ensuring at least this many can fit
    //initialize my list of squares to include a non-positioned transparent container
    //which will cause the stack to expand to the size of the parent widget

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
        if (phase == 'start' || phase == 'startB') {
          xCoord = osWidth / 2 - (bulbSize / 2);
          yCoord = osHeight / 2 - (bulbSize / 2);
        } else if (phase == 'blastOff') {
          math.Point theBlastPoint =
              getBlastPoint(osWidth, osHeight, bulbSize / 2);
          xCoord = theBlastPoint.x.toDouble();

          yCoord = theBlastPoint.y.toDouble();
        }
        gonList.add(
          Bulb(
              math.sqrt(2 * math.pow(bulbSize / 2, 2)),
              bulbSize / 2,
              spacingSize,
              i,
              j,
              gameBoard[i][j],
              flip,
              4,
              xCoord,
              yCoord,
              phase),
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
          if (phase == 'start' || phase == 'startB') {
            xCoord = osWidth / 2 - (bulbSize / 2);
            yCoord = osHeight / 2 - (bulbSize / 2);
          } else if (phase == 'blastOff') {
            math.Point theBlastPoint =
                getBlastPoint(osWidth, osHeight, bulbSize / 2);
            xCoord = theBlastPoint.x.toDouble();

            yCoord = theBlastPoint.y.toDouble();
          }
          gonList.add(
            AnimatedPositioned(
                key: Key('arrow $i $j'),
                duration: phase == 'blastOff' ? bulbDuration : startDuration,
                curve: phase == 'blastOff' ? bulbCurve : startCurve,
                top: yCoord,
                left: xCoord,
                child: CustomPaint(
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
  final double xCoord;
  final double yCoord;
  final String phase;

  const Bulb(
      this.radius,
      this.littleRadius,
      this.spacingSize,
      this.row,
      this.col,
      this.nodeType,
      this.flip,
      this.sides,
      this.xCoord,
      this.yCoord,
      this.phase, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    var rMod = Provider.of<RoundModel>(context, listen: true);

    double calcSize = littleRadius * 2 - .8;
    return AnimatedPositioned(
        key: Key('$row $col'),
        duration: phase == 'blastOff' ? bulbDuration : startDuration,
        curve: phase == 'blastOff' ? bulbCurve : startCurve,
        top: yCoord + rMod.topBlastDist[row][col],
        left: xCoord + rMod.leftBlastDist[row][col],
        child: Stack(children: [
          if (rMod.clueState[row][col])
            CustomPaint(
              painter: PolygonPainter(Offset(littleRadius, littleRadius),
                  radius - .5, nodeType, flip, sides),
            ),
          Listener(
              onPointerDown: (e) {
                rMod.tap(row, col, context);
                //if (rMod.lights.checkIfSolved()) {
                //  rMod.gameOver(context);
                //}
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 175),
                width: calcSize,
                height: calcSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  /*color: rMod.lights.lightState[row][col]
                      ? shadeB
                      : rMod.lights.cBoard.gameBoard[row][col].type == 2
                          ? Colors.transparent
                          : shadeG,
                   */
                  gradient: RadialGradient(
                    colors: rMod.lights.lightState[row][col]
                        ? [
                            shadeBgrad,
                            shadeB,
                          ]
                        : nodeType.type == 2
                            ? [
                                Colors.transparent,
                                Colors.transparent,
                              ]
                            : [
                                shadeGgrad,
                                shadeG,
                              ],
                  ),
                  border: Border.all(
                    color: nodeType.type == 2
                        ? Colors.transparent
                        : rMod.bannedState[row][col]
                            ? shadeC
                            : rMod.selectState[row][col]
                                ? shadeD
                                : rMod.lights.lightState[row][col]
                                    ? shadeB
                                    : shadeG,
                    width: radius * 0.09,
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
        ]));
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
    paint.color = shadeE;
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
  static const int sides = 6;
  final double radius;
  final Offset center;
  final NodeType nodeType;
  final bool flip;

  FacePainter(this.center, this.radius, this.nodeType, this.flip);

  @override
  void paint(Canvas canvas, Size size) {
    Paint extraPaint = Paint();
    extraPaint.color = shadeF;
    Path path = createPointerPath(nodeType);
    //extraPaint.style=PaintingStyle.stroke;
    // extraPaint.strokeWidth=2;
    canvas.drawPath(path, extraPaint);
  }

  Path createPointerPath(NodeType nodeType) {
    const double spacing = 0.02; //width of back two points of triangle
    const double pointerDepth = 0.6; //back two points of triangle
    const double lineWidth = 0.14;
    const double startDepth = .7; //starting point behind circle center
    const double extension = 1; //front point dist out of circle
    final path = Path();
    var angle = (math.pi * 2) / sides;
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
  late LightState lights;
  late List<List<bool>> selectState;
  List<Node> bannedList = []; //node list of banned nodes
  late List<List<bool>> bannedState;
  late List<List<bool>>
      clueState; //whether each node is highlighted by a used clue
  bool clueA = false; //whether the first clue is available
  bool clueB = false; //whether the second clue is available
  bool clueARelease = false; //whether clueA has been released
  bool clueBRelease = false; //whether clueB has been released
  List<Node> clueList = []; //solution list only used to generate clues
  int selectCount = 0; //count of selected nodes
  String gameType;
  List<Timer> timerManager =
      []; //I dont know how ot initialize this any other way
  int timeRemaining = 60; //in half seconds
  int maxLevel = 100;
  List<List<double>> leftBlastDist = [[]];
  List<List<double>> topBlastDist = [[]];
  String phase = 'game'; //what phase the game is in: start/startB/game/blastOff
  bool won = false; //whether the round was won or lost
  //BuildContext initialContext;

  RoundModel(BuildContext context, this.gameType, this.thisLevelOrStreak) {
    print('roundModel Built');
    //initialContext = context;
    CompleteRound cr;
    //start up the games based on gameType
    if (gameType == 'roul') {
      phase = 'start';
      //generate simple round for temporary loading screen
      cr = CompleteRound(CompleteBoard()..loadLoadingScreen(), [], []);
      unpackMyCompleteRound(cr);
      //generate round using an async compute
      generateMyCompleteRound(cr);
      //oneTimeProgressionRoundGen(cr);
    } else if (gameType == 'prog') {
      Levels mySavedLevels = Levels();
      maxLevel = mySavedLevels.getMaxLevel();
      print('max level: $maxLevel');
      cr = mySavedLevels.loadLevel(thisLevelOrStreak - 1);
      unpackMyCompleteRound(cr);
      notifyListeners();
      //print to console
      cr.printCompact();
      //for testing
      //cr.printValues();
    }
  }

  @override
  void dispose() {
    //timerManager.forEach((tmr) => tmr.cancel());
    for (var tmr in timerManager){tmr.cancel();}

    //exitButtonAction(initialContext);
    print('round model disposed.');
    super.dispose();
  }

  oneTimeProgressionRoundGen(CompleteRound cr) async {
    for (int i = 1; i < 500; i++) {
      cr = await compute(generator, 1); //had to pass a parameter..
      cr.printCompact();
    }
  }

  generateMyCompleteRound(CompleteRound cr) async {
    cr = await compute(generator, 1); //had to pass a parameter..
    Timer(const Duration(milliseconds: 300), () {
      //minimum time for loading screen
      unpackMyCompleteRound(cr);
      phase = 'startB'; //causes the notifyListeners to trigger rebuild
      notifyListeners();
      Timer(const Duration(milliseconds: 100), () {
        phase = 'game';
        notifyListeners();
        Timer(const Duration(milliseconds: 250), () {
          startTimer();
        });
      });
    });
    //print to console
    cr.printCompact();
  }

  unpackMyCompleteRound(CompleteRound cr) {
    //unpack the CompleteRound into RoundModel vars
    bannedList = cr.bannedList;
    clueList = cr.solution;
    //initialize variables
    lights = LightState(cr.cBoard, cr.solution);
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
    //initialize for animations
    topBlastDist = List.generate(
        lights.cBoard.rows,
        (int i) =>
            List.generate(lights.cBoard.columns, (int j) => 0, growable: false),
        growable: false);
    leftBlastDist = List.generate(
        lights.cBoard.rows,
        (int i) =>
            List.generate(lights.cBoard.columns, (int j) => 0, growable: false),
        growable: false);
    //calc bannedState from bannedList
    //bannedList
    //    .forEach((element) => bannedState[element.row][element.col] = true);
    for (var element in bannedList){
      bannedState[element.row][element.col] = true;
    }
  }

  void startTimer() {
    const oneSec = Duration(milliseconds: 500);
    timerManager.add(Timer.periodic(
      oneSec,
      (Timer timer) {
        //print('time: $timeRemaining');
        timeRemaining--;
        if (timeRemaining <= 0) {
          timer.cancel();
          clueARelease = true;
          clueBRelease = true;
          clueA = true;
          clueB = true;
        }
        notifyListeners();
      },
    ));
  }

  void gameOver(BuildContext context) {
    //timerManager.forEach((tmr) => tmr.cancel());
    for (var tmr in timerManager){tmr.cancel();}
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    sMod.exited = false;
    print('exit false');
    sMod.lastHighScore = 999;
    if (lights.checkIfSolved()) {
      phase = 'blastOff';
      if (gameType == 'prog') {
        print('prog VICTORY!!');
        //reset if there's no more levels, else proceed to next level
        if (thisLevelOrStreak == maxLevel) {
          sMod.overwriteProgressionLevel(1);
        } else {
          sMod.fileProgressionLevel(thisLevelOrStreak + 1);
        }
      } else if (gameType == 'roul' && timeRemaining > 0) {
        print('roul VICTORY!!');
        //roulette win condition
        sMod.updateWinStreak(true);
        sMod.updatePendingLastWinStreak(true);
        won = true;
      } else if (gameType == 'roul') {
        print('roul loss');
        //lose condition
        //if (sMod.checkHighScore()) {
        //  sMod.updateHighScore('testName');
        //}
        sMod.updatePendingLastWinStreak(false);
        sMod.updateWinStreak(false);
      }
    } else {
      if (gameType == 'roul') {
        print('roul exited mid-game');
        sMod.updatePendingLastWinStreak(false);
        sMod.updateWinStreak(false);
      } else {
        print('prog exited mid-game');
      }
    }
  }

  void exitButtonAction(BuildContext context) {
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    gameOver(context);
    if (sMod.winStreak == 0 && sMod.checkHighScore(sMod.pendingLastWinStreak)) {
      Navigator.pop(context);
      sMod.exited = true;
      print('exit true');
      Navigator.pushNamed(context, '/transitionScreen');
    } else {
      Navigator.pop(context);
    }
  }

  void throwTransitionScreen(BuildContext context) {
    if (gameType == 'roul') {
      Navigator.pushReplacementNamed(context, '/transitionScreen');
    } else {
      Navigator.pushReplacementNamed(context, '/levelFlashScreen');
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
    var rng = math.Random();
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
      //print("discarded duplicate");
      return getRandomNodes(myBoard);
    }
  }

  void clearSelections() {
    for (var i = 0; i < selectState.length; i++) {
      for (var j = 0; j < selectState[i].length; j++) {
        if (selectState[i][j]) {
          updateSelectState(i, j, selectState);
          lights.updateNode(i, j);
        }
      }
    }
    notifyListeners();
  }

  void tap(int row, int col, BuildContext context) {
    print('$row _ $col');
    if (!bannedState[row][col] &&
        selectCount > (lights.cBoard.selectionsMax - 1) &&
        !selectState[row][col] &&
        lights.cBoard.gameBoard[row][col].type != 2) {
    } else if (!bannedState[row][col] &&
        lights.cBoard.gameBoard[row][col].type != 2) {
      updateSelectState(row, col, selectState);
      lights.updateNode(row, col);
      //leftBlastDist[row][col] = -20;
      //topBlastDist[row][col] = -20;
      //Timer(Duration(milliseconds: 1000), () {
      //  leftBlastDist[row][col] = 0;
      //  topBlastDist[row][col] = -0;
      //  notifyListeners();
      //});
      notifyListeners();
      if (lights.checkIfSolved()) {
        gameOver(context);
      }
    }
  }

  void triggerClue(String buttonID) {
    if (clueList.isNotEmpty) {
      var rng = math.Random();
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
      cList.add(Node(thisRow, thisCol));
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
    return Node(thisRow, thisCol);
  }

  static Future<CompleteRound> generator(int dummyInt) async {
    const bool testingMsgs = false;
    if (testingMsgs) {
      print('Generating............');
    }
    List<Node> finalSolution;
    List<Node> bannedList = [];
    List<Node> initialSolution;
    List<List<Node>> roughSolutionList;
    int solutionIndex;
    var rngNew = math.Random();
    CompleteBoard thisBoard;
    do {
      //generate a game board
      thisBoard = CompleteBoard();
      thisBoard.reroll();
      //get random initial solution for the board
      initialSolution = getRandomNodes(thisBoard);
      //get all possible solutions
      roughSolutionList = solver(thisBoard, thisBoard.selectionsMax,
          LightState(thisBoard, initialSolution));
      if (testingMsgs) {
        //roughSolutionList.forEach((element) => printNodeList('All Solutions', element));
        for(var sltn in roughSolutionList){
          printNodeList('All Solutions', sltn);
        }
      }
      if (testingMsgs) {
        print(
            'board generated. bad? ${isBadBoard(roughSolutionList, thisBoard.selectionsMax)}');
      }
      //loop until solutions require max selection
    } while (isBadBoard(roughSolutionList, thisBoard.selectionsMax) ||
        (roughSolutionList.isEmpty));
    if (roughSolutionList.length == 1) {
      solutionIndex = 0;
    } else {
      //if multiple solutions, determine banned nodes
      if (testingMsgs) {
        print('multi solutions: ${roughSolutionList.length}');
      }
      solutionIndex = rngNew.nextInt(roughSolutionList.length);
      bannedList =
          getBannedNodes(roughSolutionList, roughSolutionList[solutionIndex]);
    }
    finalSolution = roughSolutionList[solutionIndex];
    if (testingMsgs) {
      printNodeList('final solution:', finalSolution);
      printNodeList('banned:', bannedList);
    }
    //delete arrows from banned nodes for simplicity
    for (int i = 0; i < bannedList.length; i++) {
      if (thisBoard.gameBoard[bannedList[i].row][bannedList[i].col].type == 1) {
        thisBoard.gameBoard[bannedList[i].row][bannedList[i].col]
            .makeTypeZero();
      }
    }
    return CompleteRound(thisBoard, finalSolution, bannedList);
  }
}

//****** IDEAS FOR ADDITIONAL FEATURES ***********

//re: round generation, maybe make it choose new solution nodes if none are arrows and a fair number of arrows exists?
//way to check a saved round for multiple solutions using existing code?
//make it such that multiple solutions are allowed so long as they require same # of bulbs?
//add a level selector?
//on the main menu, make the win streak and level labels only show up if they're not equal zero?
//consider a "easy" and "hard" mode based on adding a selection/ changing max map size?
//make the clear button have a brief light orange background flash?
//add a dark mode switch?
//if possible, compartmentalize and globalize the main game subscreen so use in how-to-play and level selector
//add a timer manager
//store the bulb's light states in the bulb matrix widget to minimize rebuilds
//add animation for reached-max-selections

//** scrambly word changes **
//add the back-button question
//revise menu selection formats, change button font to white, add icons to buttons and timer
//upload to github

//migrate dart to null safety: see: https://dart.dev/null-safety/migration-guide#migration-tool
//migrate to new android embedding, see: https://flutter.dev/go/android-project-migration

//** terminal commands **
//C:\JON\flutter\bin\flutter.bat doctor
//flutter doctor --android-licenses
//C:\JON\flutter\bin\flutter doctor --android-licenses

//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/animation.dart';

import 'package:blinky_bulb/bbgame.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:blinky_bulb/globals.dart';
import 'package:blinky_bulb/transition.dart';

import 'dart:ui';
import 'dart:math';
//import 'package:google_fonts/google_fonts.dart';

class FadeTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(route, context, animation, secondaryAnimation, child) =>
      FadeTransition(opacity: animation, child: child);
}

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ScoreModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blinky Bulb',
        theme: ThemeData(
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.iOS: FadeTransitionBuilder(),
            TargetPlatform.android: FadeTransitionBuilder(),
          }),
          primaryColor: shadeF, //not used anywhere(?)
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'roboto'),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
            primary: shadeA, //button background color
            onPrimary: myWhite, //button text color
            //textStyle:TextStyle(fontSize: 20, fontStyle: FontStyle.italic)
          )),
          textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
            textStyle: TextStyle(fontFamily: 'roboto', color: shadeE),
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(80),
                side: BorderSide(width: 1, color: shadeA)),
            // primary: shadeA,
            onSurface: myWhite, //Affects the text color when disabled
          )),
          //primarySwatch: Colors.blue,
          //scaffoldBackgroundColor: mainBackgroundColor,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) {
            return MenuScreen();
          },
          '/roulette': (context) {
            var sMod = Provider.of<ScoreModel>(context, listen: false);
            return ChangeNotifierProvider(
                //should be lower in tree?
                create: (context) =>
                    RoundModel(context, 'roul', sMod.winStreak),
                child: GameScreen());
          },
          '/progression': (context) {
            var sMod = Provider.of<ScoreModel>(context, listen: false);
            return ChangeNotifierProvider(
                //should be lower in tree?
                create: (context) => RoundModel(context, 'prog',
                    sMod.progressionLevel), //sMod.progressionLevel),
                child: GameScreen());
          },
          '/howToPlay': (context) => HowToScreen(),
          '/highScores': (context) => ScoreScreen(),
          '/transitionScreen': (context) => MyCustomForm(),
          '/levelFlashScreen': (context) {
            var sMod = Provider.of<ScoreModel>(context, listen: false);
            return LevelFlashScreen(sMod.progressionLevel);
          },
        },
      )));
}

class MenuScreen extends StatelessWidget {
  MenuScreen({Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    print('MenuScreen Built');
    //trigger initialization of ScoreModel
    var sMod = Provider.of<ScoreModel>(context, listen: true);
    //sMod.progressionLevel = 8; //for testing
    return SafeArea(
        child: Scaffold(
            backgroundColor: myBackground,
            resizeToAvoidBottomInset: false,
            body: LayoutBuilder(builder: (context, constraints) {
              final int buttonsCount = 4;
              //title measurements
              double titleHeight;
              double titleWidth;
              double titleFontSize;
              //button measurements
              double buttonHeight;
              double buttonWidth;
              double buttonLeftPad;
              double buttonTopPad;
              double buttonFontSize;
              if (constraints.maxHeight > constraints.maxWidth) {
                //title measurements--top 30%
                titleHeight = constraints.maxHeight * .22;
                titleWidth = constraints.maxWidth * .8;
                titleFontSize =
                    min(constraints.maxWidth, constraints.maxHeight * .6) * .16;
                //button measurements--bottom 70% (horz center)
                buttonHeight = (constraints.maxHeight * .7 / buttonsCount) / 2;
                buttonWidth = min(
                    constraints.maxWidth * .8, constraints.maxWidth * .5 + 200);
                buttonTopPad = buttonHeight / 6;
                buttonFontSize = buttonHeight * .45;
                buttonLeftPad = (constraints.maxWidth - buttonWidth) / 2;
              } else {
                //horizontal
                //title measurements--top 30%
                titleHeight = constraints.maxHeight * .2;
                titleWidth = constraints.maxWidth * .8;
                titleFontSize =
                    min(constraints.maxWidth * .6, constraints.maxHeight) * .16;
                //button measurements--bottom 70% (vert center)
                buttonHeight = (constraints.maxHeight * .7) / 4;
                buttonWidth = min(
                    constraints.maxWidth * .92 / (buttonsCount / 2) * .8,
                    (constraints.maxWidth * .5 / (buttonsCount / 2) + 200) *
                        .8);
                buttonTopPad = buttonHeight / 8;
                buttonLeftPad = buttonWidth * .04;
                buttonFontSize = buttonHeight * .4;
              }

              Widget playLabel = Padding(
                  padding: EdgeInsets.only(
                    top: buttonTopPad * 2,
                    bottom: buttonTopPad,
                  ),
                  child: Text('- play -',
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: buttonFontSize * .55,
                          fontWeight: FontWeight.w400,
                          color: popupTextColor)));
              Widget infoLabel = Padding(
                  padding: EdgeInsets.only(
                    top: buttonTopPad * 2,
                    bottom: 0,
                  ),
                  child: Text('- info -',
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: buttonFontSize * .55,
                          fontWeight: FontWeight.w400,
                          color: popupTextColor)));

              Widget progressionButton = ElevatedButton(
                  onPressed: () {
                    print('progression pressed');
                    Navigator.pushNamed(context, '/levelFlashScreen');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(buttonWidth, buttonHeight),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'PROGRESSION',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w700,
                          color: myWhite,
                        ),
                      ),
                      Text(
                        'level: ${sMod.progressionLevel}',
                        style: TextStyle(
                          fontSize: buttonFontSize * .55,
                          fontWeight: FontWeight.w400,
                          color: myBlackText,
                        ),
                      )
                    ],
                  ));

              Widget rouletteButton = Padding(
                  padding: EdgeInsets.only(top: buttonTopPad),
                  child: ElevatedButton(
                      onPressed: () {
                        print('roulette pressed');
                        Navigator.pushNamed(context, '/roulette');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, buttonHeight),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ROULETTE',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w700,
                              color: myWhite,
                            ),
                          ),
                          Text(
                            'win streak: ${sMod.winStreak}',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: buttonFontSize * .55,
                              fontWeight: FontWeight.w400,
                              color: myBlackText,
                            ),
                          )
                        ],
                      )));

              Widget howToButton = Padding(
                  padding: EdgeInsets.only(
                    top: buttonTopPad,
                    left: buttonLeftPad,
                    right: buttonLeftPad,
                    bottom: 0, //buttonTopPad,
                  ),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        minimumSize: Size(buttonWidth, buttonHeight / 1.35),
                        textStyle: TextStyle(
                          fontSize: buttonFontSize * 1.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        print('HowToPlay press');
                        Navigator.pushNamed(context, '/howToPlay');
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.psychology, size: buttonFontSize * 1.0),
                            const Text(' How To Play'),
                          ])));

              Widget scoresButton = Padding(
                  padding: EdgeInsets.only(
                    top: 0,
                    left: buttonLeftPad,
                    right: buttonLeftPad,
                    bottom: 0,
                  ),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80),
                        ),
                        minimumSize: Size(buttonWidth, buttonHeight / 1.35),
                        textStyle: TextStyle(
                          fontSize: buttonFontSize * 1.0,
                          fontWeight: FontWeight.w500,
                          //    fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        print('High Scores pressed');
                        Navigator.pushNamed(context, '/highScores');
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border, size: buttonFontSize * 1.0),
                            const Text(' High Scores'),
                          ])));

              Widget myTitle = Center(
                  child: Container(
                      height: titleHeight,
                      width: titleWidth,
                      child: Text(
                        'BLINKY BULB',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w900,
                          color: shadeB,
                        ),
                      )));

              return OrientationBuilder(builder: (context, orientation) {
                if (orientation == Orientation.portrait) {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        myTitle,
                        playLabel,
                        progressionButton,
                        rouletteButton,
                        infoLabel,
                        howToButton,
                        scoresButton,
                        //Flex()
                      ]));
                } else {
                  return Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        myTitle,
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    playLabel,
                                    progressionButton,
                                    rouletteButton
                                  ]),
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    infoLabel,
                                    howToButton,
                                    scoresButton,
                                  ]),
                              //Flex()
                            ]),
                      ]));
                }
              });
            })));
  }
}

class HowToScreen extends StatelessWidget {
  HowToScreen({Key? key} ): super(key: key);
  @override
  Widget build(BuildContext context) {
    print('ScoreScreen Built');
    var totWidth = getWidth(context);
    var totHeight = getHeight(context);
    var topSpace = totHeight * .02;
    var lettFontSize = min(totWidth, totHeight) * 0.047;
    var buttonFontSize = lettFontSize * .9;
    var howToText = TextStyle(
      fontSize: lettFontSize * 1.02,
      color: popupTextColor,
      fontFamily: 'roboto',
    );
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    sMod.clearData();
    return SafeArea(
        child: Scaffold(
      backgroundColor: myBackground,
      resizeToAvoidBottomInset: false,
      body: Padding(
          padding: EdgeInsets.only(left: 15, right: 15, bottom: topSpace * 9),
          child: Column(children: [
            Padding(
                padding: EdgeInsets.only(top: topSpace * 3, bottom: topSpace),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: lettFontSize * 1.5,
                      fontWeight: FontWeight.w900,
                      color: shadeB,
                    ),
                  ),
                ])),
            Padding(
                padding: EdgeInsets.only(bottom: topSpace),
                child: Text(
                  "it's easy",
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: lettFontSize,
                    color: popupTextColor,
                    fontStyle: FontStyle.italic,
                  ),
                )),
            Flexible(
                child: ListView(children: [
              //Text(''),
              Text(
                'Blinky Bulb is a logic puzzle game, a twist on the classic game Lights Out.',
                style: howToText,
              ),
              Text(''),
              //Spacer(),
              Text(
                'Select a bulb to toggle a pattern of bulbs on or off. To win, select the correct combination of bulbs such that all the bulbs are toggled off. Each round has a limit on the number of bulbs that can be selected.',
                style: howToText,
              ),
              //Spacer(),
              Text(''),
              Text(
                'Solve puzzles with no time limit in PROGRESSION, or challenge yourself by solving procedurally generated puzzles in under 30 seconds in ROULETTE.',
                style: howToText,
              ),
              Text(''),
              Text(
                'PROGRESSION starts out easy and serves as a tutorial, so you may want to begin there.',
                style: howToText,
              ),
              // Spacer(),
            ])),
          ])),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //Navigate back to first screen when tapped.
          Navigator.pop(context);
          //Navigator.pushNamed(context, '/second');
        },
        label: Text(
          'Exit',
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: buttonFontSize,
            //fontWeight: FontWeight.w900,
            color: myWhite,
          ),
        ),
        icon: Icon(Icons.arrow_back, color: myWhite),
        backgroundColor: shadeA,
      ),
    ));
  }
}

class ScoreScreen extends StatelessWidget {
  ScoreScreen({Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    print('ScoreScreen Built');
    var totWidth = getWidth(context);
    var totHeight = getHeight(context);
    var sideSpace = totWidth * .06;
    var topSpace = totHeight * .02;
    var lettWidth = totWidth / 16;
    var lettHeight = lettWidth * 1.66;
    var lettFontSize = min(totWidth, totHeight) * 0.047;

    var buttonFontSize = lettFontSize * .9;
    List<int> myScores = [];
    List<String> myNames = [];
    List<String> myDates = [];

    myScores = sMod.expertScores;
    myNames = sMod.expertNames;
    myDates = sMod.expertDates;
    //print('@@@@@ this win streak: $thisWinStreak');
    var myBoxDecoration;
    var myRegularBoxDecoration = BoxDecoration();

    var mySpecialBoxDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: shadeB,
        ),
        BoxShadow(
          color: myBackground,
          spreadRadius: 0,
          blurRadius: lettHeight / 6,
        ),
      ],
    );
    var headerTextStyle = TextStyle(
      fontSize: lettFontSize * 1.1,
      decoration: TextDecoration.underline,
      color: popupTextColor,
      fontWeight: FontWeight.w800,
      fontFamily: 'roboto',
    );
    var scoreTextStyleInput = TextStyle(
      fontSize: lettFontSize,
      fontStyle: FontStyle.italic,
      color: popupTextColor,
      fontFamily: 'Inconsolata',
      fontFeatures: [FontFeature.tabularFigures()],
    );

    List<Widget> scoreList = [];
    for (var i = 0; i < sMod.maxScores; i++) {
      //print(i);
      if (sMod.lastHighScore == i) {
        myBoxDecoration = mySpecialBoxDecoration;
      } else {
        myBoxDecoration = myRegularBoxDecoration;
      }
      scoreList.add(Container(
          decoration: myBoxDecoration,
          padding: EdgeInsets.only(
            top: topSpace / 2,
            bottom: topSpace / 2,
          ),
          child: Row(children: [
            Padding(
                padding: EdgeInsets.only(left: sideSpace / 2),
                child: Text(
                  '${((i + 1).toString() + '. ').padRight(4, ' ')}${myNames[i].padRight(10, ' ')}',
                  style: scoreTextStyleInput,
                )),
            Spacer(),
            Text(
              '${myDates[i]}',
              style: scoreTextStyleInput,
            ),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(right: sideSpace / 2),
                child: Text(
                  '${(myScores[i] == 0 ? '-' : myScores[i].toString()).padLeft(7, ' ')}',
                  style: scoreTextStyleInput,
                )),
          ])));
    }

    return SafeArea(
        child: Scaffold(
      backgroundColor: myBackground,
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Padding(
            padding: EdgeInsets.only(top: topSpace * 3, bottom: topSpace),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                'HIGH SCORES',
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: lettFontSize * 1.5,
                  fontWeight: FontWeight.w900,
                  color: shadeB,
                ),
              ),
            ])),
        Padding(
            padding: EdgeInsets.only(bottom: topSpace),
            child: Text(
              'ROULETTE',
              style: TextStyle(
                fontFamily: 'roboto',
                fontSize: lettFontSize,
                //fontWeight: FontWeight.w900,
                color: popupTextColor,
              ),
              //style: myStyle(myFontSize + 10, 'highScoreTitle'),
            )),
        Padding(
            padding: EdgeInsets.only(left: sideSpace, right: sideSpace),
            child: Row(children: [
              Text('          '),
              Text(
                'Name',
                style: headerTextStyle,
              ),
              Text(''),
              Spacer(),
              Text(
                'Date',
                style: headerTextStyle,
              ),
              Spacer(),
              Text(
                'Score',
                style: headerTextStyle,
              ),
            ])),
        Flexible(
            child: Padding(
                padding: EdgeInsets.fromLTRB(
                    sideSpace / 2, 0, sideSpace / 2, buttonFontSize * 6),
                child: ListView(children: scoreList))),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          //Navigate back to first screen when tapped.
          Navigator.pop(context);
          //Navigator.pushNamed(context, '/second');
        },
        label: Text(
          'Exit',
          style: TextStyle(
            fontFamily: 'roboto',
            fontSize: buttonFontSize,
            //fontWeight: FontWeight.w900,
            color: myWhite,
          ),
        ),
        icon: Icon(Icons.arrow_back, color: myWhite),
        backgroundColor: shadeA,
      ),
    ));
  }
}

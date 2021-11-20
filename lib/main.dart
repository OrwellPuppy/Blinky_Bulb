//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/animation.dart';

//import 'package:scrambly_word/globals.dart';
import 'package:blinky_bulb/bbgame.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:blinky_bulb/globals.dart';

//import 'dart:ui';
import 'dart:math';
//import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(ChangeNotifierProvider(
      create: (context) => ScoreModel(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Blinky Bulb',
        theme: ThemeData(
          primaryColor: Colors.pink,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(80)),
            primary: Colors.lightBlue, // background color
            //textStyle:TextStyle(fontSize: 20, fontStyle: FontStyle.italic)
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
        },
      )));
}

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('MenuScreen Built');
    //trigger initialization of ScoreModel
    var sMod = Provider.of<ScoreModel>(context, listen: true);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.black,
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
                titleFontSize = constraints.maxWidth * .16;
                //button measurements--bottom 70% (horz center)
                buttonHeight = (constraints.maxHeight * .7 / buttonsCount) / 2;
                buttonWidth = min(
                    constraints.maxWidth * .8, constraints.maxWidth * .5 + 200);
                buttonTopPad = buttonHeight / 6;
                buttonFontSize = buttonHeight * .35;
                buttonLeftPad = (constraints.maxWidth - buttonWidth) / 2;
              } else {
                //horizontal
                //title measurements--top 30%
                titleHeight = constraints.maxHeight * .2;
                titleWidth = constraints.maxWidth * .8;
                titleFontSize = constraints.maxHeight * .2;
                //button measurements--bottom 70% (vert center)
                buttonHeight = (constraints.maxHeight * .7) / 4;
                buttonWidth = min(
                    constraints.maxWidth * .92 / (buttonsCount / 2) * .8,
                    (constraints.maxWidth * .5 / (buttonsCount / 2) + 200) *
                        .8);
                buttonTopPad = buttonHeight / 8;
                buttonLeftPad = buttonWidth * .04;
                buttonFontSize = buttonHeight * .35;
              }

              Widget playLabel = Padding(
                  padding: EdgeInsets.only(
                    top: buttonTopPad * 2,
                    bottom: buttonTopPad,
                  ),
                  child: Text('- play -'));
              Widget infoLabel = Padding(
                  padding: EdgeInsets.only(
                    top: buttonTopPad * 2,
                    bottom: 0,
                  ),
                  child: Text('- info -'));

              Widget progressionButton = new ElevatedButton(
                  onPressed: () {
                    print('progression pressed');
                    Navigator.pushNamed(context, '/progression');
                  },
                  child: SizedBox(
                      width: buttonWidth,
                      height: buttonHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PROGRESSION',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: buttonFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'level: ${sMod.progressionLevel}',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: buttonFontSize * .75,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          )
                        ],
                      )));

              Widget rouletteButton = new Padding(
                  padding: EdgeInsets.only(top: buttonTopPad),
                  child: ElevatedButton(
                      onPressed: () {
                        print('roulette pressed');
                        Navigator.pushNamed(context, '/roulette');
                      },
                      child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ROULETTE',
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'current win streak: ${sMod.winStreak}',
                                style: TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: buttonFontSize * .75,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ))));
              Widget scoresButton = new MyButton(
                  buttonWidth,
                  buttonHeight,
                  'High Scores',
                  buttonFontSize,
                  buttonLeftPad,
                  buttonLeftPad,
                  buttonTopPad,
                  0, () {
                print('High Scores pressed');
                Navigator.pushNamed(context, '/highScores');
              }, false);
              Widget howToButton = new MyButton(
                  buttonWidth,
                  buttonHeight,
                  'How To Play CLEAR DATA',
                  buttonFontSize,
                  buttonLeftPad,
                  buttonLeftPad,
                  buttonTopPad,
                  0, () {
                print('HowToPlay press');
                Navigator.pushNamed(context, '/howToPlay');
              }, false);

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
                          fontWeight: FontWeight.w600,
                          color: Colors.yellow,
                        ),
                      )));

              return new OrientationBuilder(builder: (context, orientation) {
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
  @override
  Widget build(BuildContext context) {
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    sMod.clearData();
    return SafeArea(child: Text('How To screen'));
  }
}

class ScoreScreen extends StatelessWidget {
  ScoreScreen();

  @override
  Widget build(BuildContext context) {
    var sMod = Provider.of<ScoreModel>(context, listen: false);
    print('ScoreScreen Built');
    var totWidth = getWidth(context);
    var sideSpace = totWidth * .06;
    var topSpace = getHeight(context) * .02;
    //var myFontSize = totWidth * .047;
    var lettWidth = totWidth / 16;
    var lettHeight = lettWidth * 1.66;
    //var letterFontSize = lettWidth * 1.3 - 6;
    var buttonFontSize = totWidth * .035;
    List<int> myScores = [];
    List<String> myNames = [];
    List<String> myDates = [];

    myScores = sMod.expertScores;
    myNames = sMod.expertNames;
    myDates = sMod.expertDates;

    var myBoxDecoration;
    var myRegularBoxDecoration = new BoxDecoration();

    var mySpecialBoxDecoration = new BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.orange,
        ),
        BoxShadow(
          color: Colors.black,
          spreadRadius: 0,
          blurRadius: lettHeight / 6,
        ),
      ],
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
                  '${((i + 1).toString() + '. ').padRight(4, ' ')}${myNames[i].padRight(10, ' ')}', //
                  //style: myStyle(myFontSize, 'highScores'),
                )),
            Spacer(),
            Text(
              '${myDates[i]}',
              //style: myStyle(myFontSize, 'highScores'),
            ),
            Spacer(),
            Padding(
                padding: EdgeInsets.only(right: sideSpace / 2),
                child: Text(
                  '${(myScores[i] == 0 ? '-' : myScores[i].toString()).padLeft(7, ' ')}',
                  //style: myStyle(myFontSize, 'highScores'),
                )),
          ])));
    }

    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(children: [
        Padding(
            padding: EdgeInsets.only(top: topSpace * 3, bottom: topSpace),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('HIGH'),
              Text('SCORES'),
            ])),
        Padding(
            padding: EdgeInsets.only(bottom: topSpace),
            child: Text(
              'roulette',
              //style: myStyle(myFontSize + 10, 'highScoreTitle'),
            )),
        Padding(
            padding: EdgeInsets.only(left: sideSpace, right: sideSpace),
            child: Row(children: [
              Text('          '),
              Text(
                'Name',
                //style: myStyle(myFontSize + 4, 'highScoreHeader'),
              ),
              Text(''),
              Spacer(),
              Text(
                'Date',
                //style: myStyle(myFontSize + 4, 'highScoreHeader'),
              ),
              Spacer(),
              Text(
                'Score',
                //style: myStyle(myFontSize + 4, 'highScoreHeader'),
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
          'RETURN TO MENU',
          //style: myStyle(buttonFontSize, 'buttonStyle')),
        ),
        icon: Icon(Icons.arrow_back, color: Colors.brown),
        backgroundColor: Colors.lightBlue,
      ),
    ));
  }
}

//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/animation.dart';

//import 'package:blinky_bulb/bbgame.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:blinky_bulb/globals.dart';

//import 'dart:ui';
import 'dart:math' as math;
import 'dart:async';

class LevelFlashScreen extends StatelessWidget {
  final int progLevel;
  const LevelFlashScreen(this.progLevel, {Key? key} ): super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize =
        math.min(getHeight(context) * .05, getWidth(context) * .1);
    double smallLabelFontSize = fontSize;
    //double topSize = bottomSize;
    //double levelLabelWidth = getWidth(context) / 3;
    double numFontSize = fontSize * 2;
    Timer(const Duration(milliseconds: 900), () {
      Navigator.pushReplacementNamed(context, '/progression');
    });
    return Scaffold(
        backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Spacer(),
          Hero(
              tag: 'level$progLevel',
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: DefaultTextStyle(
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: smallLabelFontSize,
                          fontWeight: FontWeight.w600,
                          color: popupTextColor,
                        ),
                        child: const Text(
                          'level',
                          textAlign: TextAlign.center,
                        ))),
                DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: numFontSize,
                      fontWeight: FontWeight.w600,
                      color: popupTextColor,
                    ),
                    child: Text(
                      //'${rMod.thisLevelOrStreak}',
                      '$progLevel',
                      textAlign: TextAlign.center,
                    ))
              ])),
          const Spacer(),
        ])));
  }
}

class MyCustomForm extends StatefulWidget {
  const MyCustomForm( {Key? key} ): super(key: key);

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm>
    with SingleTickerProviderStateMixin {
  late AnimationController aniController;
  late Animation<double> myAnimation;
  bool isEnabled = false;
  Color? currentButtonColor = Colors.grey[500];
  Color? currentButtonTextColor = Colors.grey[600];

  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    aniController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    myController.text = '';
    super.initState();
    aniController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
    myAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: aniController,
        curve: const Interval(
          0.01,
          1,
          curve: Curves.easeOutQuad,
        ),
      ),
    );
    aniController.addListener(() {
      setState(() {});
    });
    aniController.forward();
    //Timer(Duration(milliseconds: 3500), () {isEnabled=true;});
  }

  @override
  Widget build(BuildContext context) {
    double bWidth = getWidth(context) * .8;

    double textSizer =
    (math.min(getHeight(context), getWidth(context))+(getHeight(context) + getWidth(context))/2)*.0036;

    double myHorzSpacer = getWidth(context) * .01;
    double myWidth = getWidth(context);

    //font size calcs
    double largeFontSize = (textSizer + 10) * 1.8; //1.8-2
    double mediumFontSize = (textSizer + 10) * 1.2;
    double smallFontSize = (textSizer + 10) * 1.2;
    double mySpacer = textSizer;


    double internalPadding = myHorzSpacer * 3;
    double externalPadding = myWidth*.05;

    List<Widget> highScoreContent = [];
    var sMod = Provider.of<ScoreModel>(context, listen: false);

    void scoreButtonEvent() {
      if (isEnabled) {
        //set scoreboard name variable to myController.text
        sMod.updateHighScore(myController.text);
        myController.text = ''; //attempt to fix saving-text issue
        Navigator.pushReplacementNamed(context, '/highScores');
      }
    }

    //possibilities:
    // forfeit/exit/lose + no high score: no msg
    // forfeit/exit + high score: forf + enter name msg
    // lose + high score: lose + name msg
    // win: save or continue msg
    if (sMod.winStreak == 0 && sMod.checkHighScore(sMod.pendingLastWinStreak)) {
      //if round is lost but a high score is set
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 1),
          child: Text(
            'YOU SET A HIGH SCORE!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: shadeB,
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
            child: Text(
              sMod.exited
                  ? 'Forfeited. Final win streak: ${sMod.pendingLastWinStreak}'
                  : 'Out of time. Final win streak: ${sMod.pendingLastWinStreak}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: popupTextColor,
                fontSize: smallFontSize,
              ),
            )),
        Padding(
          padding:
              EdgeInsets.fromLTRB(myHorzSpacer, mySpacer * 1, myHorzSpacer, 0),
          child: Text(
            'Enter name for scoreboard:',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: popupTextColor,
              fontSize: smallFontSize,
            ),
            //    style: myStyle(smallButtonFontSize, 'popupMenu')
          ),
        ),
        Padding(
            padding:
                EdgeInsets.fromLTRB(myHorzSpacer * 2, 4, myHorzSpacer * 2, 0),
            child: TextField(
              style: TextStyle(
                color: popupTextColor,
                //height: 1,
                fontSize: smallFontSize,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(smallFontSize / 2),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: shadeA, width: 2.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: shadeA, width: 2.0),
                ),
                counterStyle: TextStyle(color: popupTextColor),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.0,
                    color: shadeA,
                  ),
                ),
              ),

              controller: myController,
              autocorrect: false,
              cursorColor: popupTextColor, //cursorColor,
              enableSuggestions: false,
              keyboardAppearance: Brightness.dark,
              maxLines: 1,
              onChanged: (myChange) {
                if (myController.text.isNotEmpty) {
                  isEnabled = true;
                  setState(() {
                    currentButtonColor = shadeA;
                    currentButtonTextColor = myWhite;
                  });
                } else {
                  isEnabled = false;
                  setState(() {
                    currentButtonColor = shadeGgrad; //disabledButtonColor;
                    currentButtonTextColor =
                        backgroundContrast; // disabledButtonTextColor;
                  });
                }
              },
              //enable button if not blank
              showCursor: true,
              textAlign: TextAlign.center,
              textCapitalization: TextCapitalization.words,
              maxLength: 10,
            )),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer * 2, mySpacer * 2, myHorzSpacer * 2, mySpacer * 4),
            child: SizedBox(
                height: mediumFontSize * 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(bWidth, mediumFontSize * 1.5),
                    //padding: EdgeInsets.all(smallFontSize / 2),
                    primary: currentButtonColor,
                    onSurface: currentButtonColor,
                    textStyle: TextStyle(
                        fontSize: mediumFontSize,
                        color: currentButtonTextColor),
                  ),
                  onPressed: isEnabled ? scoreButtonEvent : null,
                  child: const Text('Submit'),
                ))),
      ];
    } else if (sMod.winStreak == 0 &&
        !sMod.checkHighScore(sMod.pendingLastWinStreak)) {
      //if round is lost and a high score isn't set
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 1),
          child: Text(
            'YOU LOSE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: popupTextColor,
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text(
            'You solved the puzzle, but not fast enough.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: smallFontSize,
              color: popupTextColor,
            ),
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text('final win streak: ${sMod.pendingLastWinStreak}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallFontSize,
                color: popupTextColor,
              )),
        ),
        TextButton(
          style: TextButton.styleFrom(
              padding: EdgeInsets.fromLTRB(
                  myHorzSpacer, mySpacer * 2, myHorzSpacer, mySpacer * 2),
              minimumSize: Size.fromHeight(mySpacer * 4),
              textStyle: TextStyle(
                  fontSize: mediumFontSize, fontWeight: FontWeight.w700)),
          onPressed: () {
            Navigator.of(context).pop();
            //Navigator.pop(context);
          },
          child: const Text('Exit To Menu'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.fromLTRB(
                  myHorzSpacer, mySpacer * 2, myHorzSpacer, mySpacer * 2),
              elevation: 0,
              minimumSize: Size.fromHeight(mySpacer * 4),
              textStyle: TextStyle(
                  fontSize: mediumFontSize, fontWeight: FontWeight.w700)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/roulette');
          },
          child: const Text('Play Again'),
        ),
      ];
    } else {
      //if round is won
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 1),
          child: Text(
            'YOU WIN!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: shadeB,
              fontSize: largeFontSize * 1.04,
              fontWeight: FontWeight.bold,
            ),
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text('win streak: ${sMod.winStreak}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallFontSize,
                color: popupTextColor,
              )
              //    style: myStyle(widget.buttonFontSize, 'popupMenu')
              ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.fromHeight(mySpacer * 4),
            textStyle: TextStyle(fontSize: mediumFontSize),
            padding: EdgeInsets.fromLTRB(
                0, mySpacer * 2, 0, mySpacer * 2),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Save And Exit'),
        ),
        Padding(
    padding: EdgeInsets.fromLTRB(
    0, mySpacer * 1, 0, mySpacer * 1),
          child:ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size.fromHeight(mySpacer * 4),
            textStyle: TextStyle(fontSize: mediumFontSize),
            padding: EdgeInsets.fromLTRB(
                0, mySpacer * 2, 0, mySpacer * 2),
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/roulette');
            //Navigator.pop(context);
          },
          child: const Text('Play Next Round'),
          )),
      ];
    }

    Future<bool> _onBackPressed() async {
      if (!sMod.checkHighScore(sMod.winStreak)) {
        //Navigator.of(context).pop();
        //Navigator.of(context).pop();
        Navigator.of(context).pop(false);
      }
      return false;
    }

    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            //resizeToAvoidBottomInset: false,
            backgroundColor: const Color.fromRGBO(0, 0, 0, 1),
            body: Center(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        externalPadding, 0, externalPadding, 0),
                    child: Material(
                        color: Colors.transparent,
                        child: FadeTransition(
                            opacity: myAnimation,
                            child: Container(
                                decoration: ShapeDecoration(
                                    color: popUpBackground,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0))),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        internalPadding, 0, internalPadding, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: highScoreContent,
                                    )))))))));
  }
}

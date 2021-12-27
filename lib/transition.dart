//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/animation.dart';

//import 'package:blinky_bulb/bbgame.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:blinky_bulb/globals.dart';

//import 'dart:ui';
import 'dart:math' as math;

class MyCustomForm extends StatefulWidget {
  const MyCustomForm();

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm>
    with SingleTickerProviderStateMixin {
  AnimationController aniController;
  Animation<double> myAnimation;
  bool isEnabled = false;
  Color currentButtonColor = Colors.grey[500];
  Color currentButtonTextColor = Colors.grey[600];

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
    aniController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    myAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: aniController,
        curve: Interval(
          0.5,
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
    double mySpacer = getHeight(context) * .01;
    double textSizer =
        math.min(getHeight(context) * .01, getWidth(context) * .01);
    double myHorzSpacer = getWidth(context) * .01;

    //font size calcs
    double largeFontSize = textSizer * 4 + 6;
    double mediumFontSize = textSizer * 3 + 6;
    double smallFontSize = textSizer * 2 + 6;

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
            "YOU SET A HIGH SCORE!",
            textAlign: TextAlign.center,
            style: TextStyle(
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
                  ? "Forfeited. Final win streak: ${sMod.pendingLastWinStreak}"
                  : "Out of time. Final win streak: ${sMod.pendingLastWinStreak}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallFontSize,
              ),
            )),
        Padding(
          padding:
              EdgeInsets.fromLTRB(myHorzSpacer, mySpacer * 1, myHorzSpacer, 0),
          child: Text(
            "Enter name for scoreboard:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: smallFontSize,
            ),
            //    style: myStyle(smallButtonFontSize, 'popupMenu')
          ),
        ),
        Padding(
            padding:
                EdgeInsets.fromLTRB(myHorzSpacer * 2, 0, myHorzSpacer * 2, 0),
            child: TextField(
              //style: myStyle(widget.buttonFontSize, 'popupMenuEntryText'),
              controller: myController,
              autocorrect: false,
              cursorColor: Colors.grey[600], //cursorColor,
              enableSuggestions: false,
              keyboardAppearance: Brightness.dark,
              maxLines: 1,
              onChanged: (myChange) {
                if (myController.text.length > 0) {
                  isEnabled = true;
                  setState(() {
                    currentButtonColor = Colors.blue; //myButtonColor;
                    currentButtonTextColor = Colors.white; // buttonTextColor;
                  });
                } else {
                  isEnabled = false;
                  setState(() {
                    currentButtonColor =
                        Colors.grey[500]; //disabledButtonColor;
                    currentButtonTextColor =
                        Colors.grey[600]; // disabledButtonTextColor;
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
                myHorzSpacer * 2, mySpacer * 4, myHorzSpacer * 2, mySpacer * 2),
            child: RawMaterialButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                fillColor: currentButtonColor,
                textStyle: TextStyle(color: Colors.lightGreen),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80)),
                splashColor: Colors.lightBlue, //myButtonAccent,
                onPressed: isEnabled ? scoreButtonEvent : null,
                child: Center(
                  child: Text(
                    "submit",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: mediumFontSize,
                      //gMod.buttonFontSize,
                      color: currentButtonTextColor,
                    ), //need to somehow pass buttonfontsize
                  ),
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
            "YOU LOSE",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text(
            "You solved the puzzle, but not fast enough.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: smallFontSize,
            ),
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text("final win streak: ${sMod.pendingLastWinStreak}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallFontSize,
              )

              //    style: myStyle(widget.buttonFontSize, 'popupMenu')
              ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer, mySpacer * 1, myHorzSpacer, mySpacer * 1),
            child: MyButton(
                0, mySpacer * 4, 'exit to menu', mediumFontSize, 0, 0, 0, 0,
                () {
              Navigator.of(context).pop();
              //Navigator.pop(context);
            }, true)),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer, mySpacer * 1, myHorzSpacer, mySpacer * 1),
            child: MyButton(
                0, mySpacer * 4, 'play again', mediumFontSize, 0, 0, 0, 0, () {
              Navigator.pushReplacementNamed(context, '/roulette');
            }, true)),
      ];
    } else {
      //if round is won
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 1),
          child: Text(
            "YOU WIN",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: largeFontSize,
              fontWeight: FontWeight.bold,
            ),
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              myHorzSpacer, mySpacer * 3, myHorzSpacer, mySpacer * 3),
          child: Text("win streak: ${sMod.winStreak}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: smallFontSize,
              )
              //    style: myStyle(widget.buttonFontSize, 'popupMenu')
              ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer, mySpacer * 1, myHorzSpacer, mySpacer * 1),
            child: MyButton(
                0, mySpacer * 4, 'save and exit', mediumFontSize, 0, 0, 0, 0,
                () {
              Navigator.of(context).pop();
            }, true)),
        Padding(
            padding: EdgeInsets.fromLTRB(
                myHorzSpacer, mySpacer * 1, myHorzSpacer, mySpacer * 1),
            child: MyButton(
                0, mySpacer * 4, 'play next round', mediumFontSize, 0, 0, 0, 0,
                () {
              Navigator.pushReplacementNamed(context, '/roulette');
              //Navigator.pop(context);
            }, true)),
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

    return new WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
            backgroundColor: const Color.fromRGBO(0, 0, 0, .5),
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Material(
                        color: Colors.transparent,
                        child: FadeTransition(
                            opacity: myAnimation,
                            child: Container(
                                decoration: ShapeDecoration(
                                    color: Colors
                                        .white70, //customFormBackgroundColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15.0))),
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: highScoreContent,
                                    )))))))));
  }
}

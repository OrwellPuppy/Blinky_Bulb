//import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:flutter/animation.dart';

//import 'package:blinky_bulb/bbgame.dart';
import 'package:blinky_bulb/bbscore.dart';
import 'package:blinky_bulb/globals.dart';

//import 'dart:ui';
//import 'dart:math';

class MyCustomForm extends StatefulWidget {
  final double buttonFontSize = 14; //TODO: calculate this
  final double smallButtonFontSize = 12; //TODO: calculate this

  const MyCustomForm();

  @override
  _MyCustomFormState createState() => _MyCustomFormState();
}

class _MyCustomFormState extends State<MyCustomForm>
    with SingleTickerProviderStateMixin {
  AnimationController aniController;
  Animation<double> myAnimation;
  bool isEnabled = false;
  Color currentButtonColor = Colors.grey;
  Color currentButtonTextColor = Colors.deepOrange;

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
    List<Widget> highScoreContent = [];
    var sMod = Provider.of<ScoreModel>(context, listen: false);

    void scoreButtonEvent() {
      if (isEnabled) {
        sMod.updateHighScore(myController.text);
        myController.text = ''; //attempt to fix saving-text issue
        //set scoreboard name variable to myController.text
        //Navigator.of(context).pop();
        //Navigator.of(context).pop();
        //Navigator.pop(context);
        //Navigator.pushNamed(context, '/highScores');
        Navigator.pushReplacementNamed(context, '/highScores');
      }
    }

    if (sMod.winStreak == 0 && sMod.checkHighScore(sMod.pendingLastWinStreak)) {
      //if round is lost but a high score is set
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(8, mySpacer * 2, 8, mySpacer * 3),
          child: Text(
            sMod.exited
                ? "You've forfeited."
                : "You solved the puzzle, but not fast enough.",
            textAlign: TextAlign.center,
            //style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, mySpacer * 2, 8, mySpacer * 3),
          child: Text(
            "Final win streak: ${sMod.pendingLastWinStreak}",
            textAlign: TextAlign.center,
            //style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, mySpacer * 2, 8, mySpacer * 3),
          child: Text(
            "YOU'VE SET A HIGH SCORE!",
            textAlign: TextAlign.center,
            //style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Text(
            "Enter a name for the scoreboard:",
            textAlign: TextAlign.center,
            //    style: myStyle(widget.smallButtonFontSize, 'popupMenu')
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, mySpacer),
            child: TextField(
              //style: myStyle(widget.buttonFontSize, 'popupMenuEntryText'),
              controller: myController,
              autocorrect: false,
              cursorColor: Colors.yellowAccent, //cursorColor,
              enableSuggestions: false,
              keyboardAppearance: Brightness.dark,
              maxLines: 1,
              onChanged: (myChange) {
                if (myController.text.length > 0) {
                  isEnabled = true;
                  setState(() {
                    currentButtonColor = Colors.blue; //myButtonColor;
                    currentButtonTextColor =
                        Colors.deepPurple; // buttonTextColor;
                  });
                } else {
                  isEnabled = false;
                  setState(() {
                    currentButtonColor = Colors.blueGrey; //disabledButtonColor;
                    currentButtonTextColor =
                        Colors.brown; // disabledButtonTextColor;
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
            padding: EdgeInsets.fromLTRB(8, mySpacer * 4, 8, mySpacer * 2),
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
                    "SUBMIT",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.w600,
                      fontSize: widget.smallButtonFontSize,
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
          padding: EdgeInsets.fromLTRB(8, mySpacer * 2, 8, mySpacer * 3),
          child: Text(
            "You solved the puzzle, but not fast enough.",
            textAlign: TextAlign.center,
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Text(
            "Final win streak: ${sMod.pendingLastWinStreak}",
            //textAlign: TextAlign.center,
            //    style: myStyle(widget.buttonFontSize, 'popupMenu')
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(8, mySpacer * 4, 8, mySpacer),
            child: MyButton(20, 20, 'RETURN TO MENU',
                widget.smallButtonFontSize, 2, 2, 2, 2, () {
              Navigator.of(context).pop();
              //Navigator.pop(context);
            }, true)),
        Padding(
            padding: EdgeInsets.fromLTRB(8, mySpacer * 4, 8, mySpacer),
            child: MyButton(
                20, 20, 'PLAY AGAIN', widget.smallButtonFontSize, 2, 2, 2, 2,
                () {
              Navigator.pushReplacementNamed(context, '/roulette');
            }, true)),
      ];
    } else {
      //if round is won
      highScoreContent = <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(8, mySpacer * 2, 8, mySpacer * 3),
          child: Text(
            "You've solved the puzzle!",
            textAlign: TextAlign.center,
            //    style: myStyle(widget.buttonFontSize, 'popupMenuTitle')
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Text(
            "Current win streak: ${sMod.winStreak}",
            //textAlign: TextAlign.center,
            //    style: myStyle(widget.buttonFontSize, 'popupMenu')
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(8, mySpacer * 4, 8, mySpacer),
            child: MyButton(
                20, 20, 'NEXT ROUND', widget.smallButtonFontSize, 2, 2, 2, 2,
                () {
              Navigator.pushReplacementNamed(context, '/roulette');
              //Navigator.pop(context);
            }, true)),
        Padding(
            padding: EdgeInsets.fromLTRB(8, mySpacer * 4, 8, mySpacer),
            child: MyButton(20, 20, 'SAVE AND RETURN TO MENU',
                widget.smallButtonFontSize, 2, 2, 2, 2, () {
              Navigator.of(context).pop();
            }, true)),
      ];
    }

    Future<bool> _onBackPressed() async {
      if (!sMod.checkHighScore(sMod.winStreak)) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
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

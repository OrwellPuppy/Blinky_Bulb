import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreModel extends ChangeNotifier {
  //score variables to be saved
  List<int> expertScores = [];
  List<String> expertNames = [];
  List<String> expertDates = [];
  int progressionLevel = 1;
  int winStreak = 0;
  //other variables
  final int maxScores = 10;
  int lastHighScore = 999; //the place # of the high score set

  ScoreModel() {
    print('ScoreModel constructed');
    loadData();
  }

  loadData() async {
    final prefs = await SharedPreferences.getInstance();
    expertScores.clear();
    expertNames.clear();
    expertDates.clear();
    for (int i = 0; i < maxScores; i++) {
      expertScores.add(prefs.getInt('expertScore$i') ?? 0);
      expertNames.add(prefs.getString('expertName$i') ?? '-');
      expertDates.add(prefs.getString('expertDate$i') ?? '-');
    }
    progressionLevel = prefs.getString('progressionLevel') ?? 1;
    winStreak = prefs.getString('winStreak') ?? 0;
    //print
    print('loaded Progression Level: $progressionLevel');
    print('loaded Win Streak: $winStreak');
    print('loaded Expert Scores: $expertScores');
    print('loaded Expert Names: $expertNames');
    print('loaded Expert Dates: $expertDates');
  }

  saveData() async {
    // obtain shared preferences
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < maxScores; i++) {
      prefs.setInt('expertScore$i', expertScores[i]);
      prefs.setString('expertName$i', expertNames[i]);
      prefs.setString('expertDate$i', expertDates[i]);
    }
    prefs.setInt('progressionLevel', progressionLevel);
    prefs.setInt('winStreak', winStreak);
    //print
    print('saved Progression Level: $progressionLevel');
    print('saved Progression Level: $winStreak');
    print('saved Expert Scores: $expertScores');
    print('saved Expert Names: $expertNames');
    print('saved Expert Dates: $expertDates');
  }

  clearData() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < maxScores; i++) {
      prefs.remove('expertScore$i');
      prefs.remove('expertName$i');
      prefs.remove('expertDate$i');
    }
    prefs.remove('progressionLevel');
    prefs.remove('winStreak');
    print('DATA CLEARED');
    loadData();
  }

  bool checkHighScore() {
    //reset last high score
    lastHighScore = 999;
    //returns true if a high score is set
    return (winStreak > expertScores[maxScores - 1]);
  }

  void fileProgressionLevel(int myLevel) {
    //saves level if the given level is higher than saved level
    if (myLevel > progressionLevel) {
      progressionLevel = myLevel;
      saveData();
    }
  }

  void updateWinStreak(bool won) {
    if (won) {
      winStreak++;
    } else {
      winStreak = 0;
    }
    saveData();
  }

  void updateHighScore(String newName) {
    var i = maxScores - 1;
    DateTime now = new DateTime.now();
    String date = now.toString().substring(0, 10);

    while (expertScores[i] < winStreak) {
      i--;
      if (i == -1) {
        break;
      }
    }
    i++;
    expertScores.insert(i, winStreak);
    expertNames.insert(i, newName);
    expertDates.insert(i, date);
    lastHighScore = i;
    saveData();
  }
}
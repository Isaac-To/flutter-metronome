import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:swipe/swipe.dart';

MetronomeLogic logic = MetronomeLogic();
Soundpool pool = Soundpool.fromOptions();

void main() {
  runApp(const Loader());
}

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Metronome',
      home: BgColor(),
    );
  }
}

class BgColor extends StatefulWidget {
  const BgColor({Key? key}) : super(key: key);

  @override
  BgColorSwitcher createState() => BgColorSwitcher();
}

class BgColorSwitcher extends State {
  List<Color?> colorList = [
    Colors.white,
    const Color.fromARGB(255, 45, 45, 45),
    Colors.amber[200],
    Colors.lightBlue[200],
  ];
  int colorChoice = 0;
  updateTheme() {
    setState(() {
      colorChoice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorList[colorChoice],
      body: SizedBox.expand(
        child: Container(
          margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 24,
              right: MediaQuery.of(context).size.width / 24,
              top: MediaQuery.of(context).size.height / 24),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.water_drop_outlined),
                onPressed: () {
                  if (colorList.length - 1 == colorChoice) {
                    colorChoice = 0;
                  } else {
                    colorChoice++;
                  }
                  updateTheme();
                },
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 24),
                child: const MetronomeApp(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetronomeApp extends StatefulWidget {
  const MetronomeApp({Key? key}) : super(key: key);

  @override
  ScrnDisplay createState() => ScrnDisplay();
}

class ScrnDisplay extends State {
  String bpm = logic.getBPM().toString();

  updateDisplay() {
    setState(() {
      bpm = logic.getBPM().toString();
    });
  }

  power() async {
    int tickID =
        await rootBundle.load("assets/beat.m4a").then((ByteData soundData) {
      return pool.load(soundData);
    });
    while (logic.getPower()) {
      updateDisplay();
      if (logic.getCurrentBeat() == 1) {
        // Offset of Thirds are plesant
        pool.play(tickID, rate: 1.1);
      } else {
        pool.play(tickID, rate: 0.8);
      }
      await Future.delayed(
        Duration(milliseconds: ((60 / logic.getBPM()) * 1000).toInt()),
        () {},
      );
      logic.updateCurrentBeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 4,
          child: FittedBox(
            fit: BoxFit.fill,
            child: MaterialButton(
              // for toggling play
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bpm,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              onPressed: () {
                logic.toggleOnOff();
                power();
              },
              onLongPress: () {
                if (logic.getPower() == true) {
                  logic.toggleOnOff();
                }
                logic.setBPM(120);
                logic.resetBeat();
                logic.setCount(4);
                updateDisplay();
              },
            ),
          ),
        ),
        ButtonBar(
          buttonMinWidth: MediaQuery.of(context).size.width * 0.90 / 2,
          alignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              child: Text(
                logic.getCurrentBeat().toString(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 16),
              ),
              onPressed: () {
                logic.resetBeat();
                updateDisplay();
              },
            ),
            MaterialButton(
              child: Text(
                logic.getTimeSignature(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 16),
              ),
              onPressed: () {
                if (logic.getCount() < 7) {
                  logic.setCount(logic.getCount() + 1);
                } else {
                  logic.setCount(2);
                }
                updateDisplay();
              },
            ),
          ],
        ),
        Material(
          color: Colors.transparent,
          child: Slider(
            thumbColor: Colors.black,
            activeColor: Colors.black,
            value: logic.getBPM().toDouble(),
            min: 40,
            max: 300,
            onChanged: (value) {
              setState(
                () {
                  logic.setBPM(value.toInt());
                  updateDisplay();
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class MetronomeLogic {
  int bpm = 120;
  int currentBeat = 1;
  int count = 4;
  bool power = false;

  int getBPM() {
    return bpm;
  }

  int getCurrentBeat() {
    return currentBeat;
  }

  int getCount() {
    return count;
  }

  String getTimeSignature() {
    return '$count/4';
  }

  bool getPower() {
    return power;
  }

  void setBPM(int amt) {
    bpm = amt;
  }

  void setCount(int newCount) {
    count = newCount;
  }

  void toggleOnOff() {
    power = !power;
  }

  void updateCurrentBeat() {
    if (currentBeat + 1 > count) {
      currentBeat = 1;
    } else {
      currentBeat++;
    }
  }

  void resetBeat() {
    currentBeat = 1;
  }
}

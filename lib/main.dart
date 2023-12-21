import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class TimerState {
  final int time;
  final bool isIBActive;
  final bool isCIActive;

  TimerState(this.time, this.isIBActive, this.isCIActive);

  bool getIsActive(int toggleIndex) {
    if (toggleIndex == 1) {
      return isIBActive;
    } else {
      return isCIActive;
    }
  }
}

class TimerCubit extends Cubit<TimerState> {
  Timer? _timer;

  TimerCubit() : super(TimerState(0, false, false));

  void startStopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      emit(TimerState(0, state.isIBActive,
          state.isCIActive)); // Set timer to 0 when stopped
    } else {
      int initialTime = 300;
      if (state.isCIActive && state.isIBActive) {
        initialTime = 230;
      } else if (state.isCIActive) {
        initialTime = 254;
      } else if (state.isIBActive) {
        initialTime = 267;
      }
      emit(TimerState(initialTime, state.isIBActive,
          state.isCIActive)); // Start timer with initial time
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (state.time > 0) {
          emit(TimerState(state.time - 1, state.isIBActive, state.isCIActive));
        } else {
          timer.cancel();
          _timer = null;
          emit(TimerState(
              0, false, false)); // Reset timer, but not the toggle buttons
        }
      });
    }
  }

  void toggleButton(int index, int toggleIndex) {
    TimerState currentState = state;
    if (toggleIndex == 1) {
      emit(TimerState(currentState.time, !currentState.isIBActive,
          currentState.isCIActive));
    } else {
      emit(TimerState(currentState.time, currentState.isIBActive,
          !currentState.isCIActive));
    }
  }
}

class CountdownTimer extends StatelessWidget {
  final int secondsRemaining;

  CountdownTimer(this.secondsRemaining, {super.key});

  @override
  Widget build(BuildContext context) {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;

    return Text(
      '$minutes:${seconds < 10 ? '0$seconds' : seconds}',
      style: const TextStyle(
        fontSize: 24.0, // Change the font size as needed
        color: Colors.white, // Change the text color to white
      ),
    );
  }
}

class TimerButtonContent extends StatelessWidget {
  // Define the image path
  static const String imagePath = 'assets/images/lol_flash_icon.png';

  final int index;

  const TimerButtonContent({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, timerState) {
        return InkWell(
          onTap: () {
            BlocProvider.of<TimerCubit>(context).startStopTimer();
          },
          // splashColor: Colors.grey, // Color when tapped
          borderRadius: BorderRadius.circular(15.0), // Set the border radius
          child: Container(
            width: 100.0,
            height: 100.0,
            // margin: const EdgeInsets.only(left: 20.0, right: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!, // Shadow color
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Initial image
                  Image.asset(
                    imagePath,
                    width: 100.0,
                    height: 100.0,
                    fit: BoxFit.cover,
                  ),

                  // Opacity filter with darker blue hue when timer is greater than 0
                  if (timerState.time > 0)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(
                            0.7), // Adjust the opacity and color as needed
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        imagePath,
                        width: 100.0,
                        height: 100.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Visibility widget for timer text
                  Visibility(
                    visible: timerState.time > 0,
                    child: CountdownTimer(timerState.time),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TimerButton extends StatelessWidget {
  final int index;
  final String laneIconPath;
  const TimerButton(
      {super.key, required this.index, required this.laneIconPath});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerCubit(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            laneIconPath,
            width: 80.0,
            height: 80.0,
            fit: BoxFit.cover,
          ),
          TimerButtonContent(
            index: index,
          ),
          ToggleButton(
              index: index,
              toggleIndex: 1,
              imagePath: 'assets/images/lucidity_boots_icon.png'),
          ToggleButton(
            index: index,
            toggleIndex: 2,
            imagePath: 'assets/images/lol_cosmic_insight_icon.png',
          ),
        ],
      ),
    );
  }
}

class ToggleButton extends StatelessWidget {
  final int index;
  final int toggleIndex;
  final String imagePath;

  const ToggleButton(
      {super.key,
      required this.index,
      required this.toggleIndex,
      required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, timerState) {
        const double width = 60.0;
        const double height = 60.0;

        return InkWell(
          onTap: () {
            BlocProvider.of<TimerCubit>(context)
                .toggleButton(index, toggleIndex);
          },
          splashColor: Colors.grey,
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              color: timerState.getIsActive(toggleIndex)
                  ? Colors.grey[400]
                  : Colors.transparent,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Initial image
                  Image.asset(
                    imagePath,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                  ),

                  // Opacity filter when the button is toggled
                  if (!timerState.getIsActive(toggleIndex))
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey.withOpacity(0.9),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        imagePath,
                        width: width,
                        height: height,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: const Text(
          'FlashTracker',
          style: TextStyle(
            fontFamily: 'Futura',
            fontWeight: FontWeight.bold,
          ),
        ),
        // centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Add your logic for the info button here
              // For example, you can show a dialog or navigate to an info screen
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to: FlashTracker'),
                  content: const Text(
                      "Welcome to FlashTracker! \n\nThis app was built to help you track the enemy team's flash cooldowns in League of Legends.  To use it, just tap the Flash icon for the corresponding role when you see them use flash. \n\n In addition, you can tap the Cosmic Insight and Ionian Boots icons for each role if they have either rune/item for a more accurate Flash cooldown timer. \n\nSend feedback to @kosiikos on Twitter! "),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: const Padding(
        padding:
            EdgeInsets.only(top: 25, bottom: 50.0, left: 15.0, right: 15.0),
        child: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TimerButton(
                    index: 0, laneIconPath: 'assets/images/top_icon.png'),
                TimerButton(
                    index: 0, laneIconPath: 'assets/images/jungle_icon.png'),
                TimerButton(
                    index: 0, laneIconPath: 'assets/images/mid_icon.png'),
                TimerButton(
                    index: 0, laneIconPath: 'assets/images/bot_icon.png'),
                TimerButton(
                    index: 0, laneIconPath: 'assets/images/support_icon.png'),
              ]),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimerCubit>(
          create: (context) => TimerCubit(),
        ),
      ],
      child: const MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

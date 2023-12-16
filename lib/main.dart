import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class TimerCubit extends Cubit<int> {
  Timer? _timer;

  TimerCubit() : super(0);

  void startStopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      emit(0); // Reset timer
    } else {
      emit(300); // Start timer with 5 minutes
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (state > 0) {
          emit(state - 1);
        } else {
          timer.cancel();
          _timer = null;
          emit(0); // Reset timer
        }
      });
    }
  }
}

class CountdownTimer extends StatelessWidget {
  final int secondsRemaining;

  CountdownTimer(this.secondsRemaining);

  @override
  Widget build(BuildContext context) {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;

    return Text(
      '$minutes:${seconds < 10 ? '0$seconds' : seconds}',
      style: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class TimerButton extends StatelessWidget {
  final int index;

  TimerButton({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerCubit(),
      child: TimerButtonContent(),
    );
  }
}

class TimerButtonContent extends StatelessWidget {
  // Define the image path
  static const String imagePath = 'assets/images/lol_flash_icon.png';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, int>(
      builder: (context, timerState) {
        return InkWell(
          onTap: () {
            BlocProvider.of<TimerCubit>(context).startStopTimer();
          },
          splashColor: Colors.grey, // Color when tapped
          borderRadius: BorderRadius.circular(15.0), // Set the border radius
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!, // Shadow color
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
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
                  if (timerState > 0)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        const Color.fromARGB(255, 14, 86, 123).withOpacity(
                            0.90), // Adjust the opacity and color as needed
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
                    visible: timerState > 0,
                    child: CountdownTimer(timerState),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.only(top: 100, bottom: 50.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (index) => TimerButton(index: index),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

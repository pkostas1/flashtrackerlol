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
      emit(10); // TODO: change to start timer with 5 minutes
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
          child: Container(
            width: 100.0,
            height: 100.0,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Initial image
                Image.asset(
                  imagePath,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.contain,
                ),

                // Opacity filter for the image when timer is greater than 0
                if (timerState > 0)
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.grey
                          .withOpacity(0.8), // Adjust the opacity as needed
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      imagePath,
                      width: 100.0,
                      height: 100.0,
                      fit: BoxFit.contain,
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
        );
      },
    );
  }
}

class CountdownTimer extends StatelessWidget {
  final int secondsRemaining;

  CountdownTimer(this.secondsRemaining);

  @override
  Widget build(BuildContext context) {
    int minutes = secondsRemaining ~/ 60;
    int seconds = secondsRemaining % 60;

    return Text('$minutes:${seconds < 10 ? '0$seconds' : seconds}');
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashTracker'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            5,
            (index) => TimerButton(index: index),
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

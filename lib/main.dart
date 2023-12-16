import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class TimerCubit extends Cubit<int> {
  Timer? _timer;

  TimerCubit() : super(0);

  void startStopTimer(int duration) {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      emit(0); // Reset timer
    } else {
      emit(duration); // Start timer with 5 minutes
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
      child: TimerButtonContent(index: index),
    );
  }
}

class TimerButtonContent extends StatelessWidget {
  // Define the image path
  static const String imagePath = 'assets/images/lol_flash_icon.png';

  final int index;

  TimerButtonContent({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerCubit, int>(
      builder: (context, timerState) {
        int startingValue = 300; // Default starting value

        // Get the state of the OpaqueButtons in the same row
        List<bool> opaqueButtonStates = List.generate(
          2,
          (index) {
            final opaqueButtonCubit = BlocProvider.of<OpaqueButtonCubit>(
              context,
              listen: false,
            );
            return opaqueButtonCubit.state;
          },
        );
        print(opaqueButtonStates);
        // Determine the starting value based on OpaqueButton states
        if (opaqueButtonStates[0] && opaqueButtonStates[1]) {
          startingValue = 230;
        } else if (opaqueButtonStates[0]) {
          startingValue = 267;
        } else if (opaqueButtonStates[1]) {
          startingValue = 254;
        }

        return InkWell(
          onTap: () {
            BlocProvider.of<TimerCubit>(context).startStopTimer(startingValue);
          },
          splashColor: Colors.grey, // Color when tapped
          borderRadius: BorderRadius.circular(15.0), // Set the border radius
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 3.0,
              ),
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

class OpaqueButton extends StatelessWidget {
  final int index;

  OpaqueButton({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OpaqueButtonCubit(),
      child: OpaqueButtonContent(index: index),
    );
  }
}

class OpaqueButtonCubit extends Cubit<bool> {
  OpaqueButtonCubit() : super(false);

  void toggleButton() {
    emit(!state);
  }
}

class OpaqueButtonContent extends StatelessWidget {
  // Define the image path
  static const String imagePath = 'assets/images/lol_flash_icon.png';

  final int index;

  OpaqueButtonContent({required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OpaqueButtonCubit, bool>(
      builder: (context, isToggled) {
        return InkWell(
          onTap: () {
            BlocProvider.of<OpaqueButtonCubit>(context).toggleButton();
          },
          splashColor: Colors.grey,
          borderRadius: BorderRadius.circular(15.0),
          child: Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[500]!,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              color: isToggled ? Colors.grey[400] : Colors.transparent,
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

                  // Opacity filter when the button is toggled
                  if (isToggled)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Colors.grey.withOpacity(0.8),
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        imagePath,
                        width: 100.0,
                        height: 100.0,
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
              (rowIndex) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TimerButton(index: rowIndex),
                  BlocProvider(
                    create: (context) => OpaqueButtonCubit(),
                    child: OpaqueButton(index: rowIndex),
                  ),
                  BlocProvider(
                    create: (context) => OpaqueButtonCubit(),
                    child: OpaqueButton(index: rowIndex + 5),
                  ),
                ],
              ),
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<TimerCubit>(
          create: (context) => TimerCubit(),
        ),
        BlocProvider<OpaqueButtonCubit>(
          create: (context) => OpaqueButtonCubit(),
        ),
      ],
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}

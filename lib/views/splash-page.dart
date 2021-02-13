import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rpljs/config/index.dart';
import 'package:rpljs/helpers/size-helpers.dart' as sh;
import 'package:rpljs/widgets/logo.dart';

class SplashPage extends StatefulWidget {
  SplashPage({this.timeout, this.transition, this.next});

  final int timeout;
  final int transition;
  final Widget next;
  
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  BuildContext _context;
  AnimationController _controller;
  bool _transitionStarted = false;

  Duration _parseDuration(int value) {
    if (value < 150) {
      return Duration(seconds: value);
    } else {
      return Duration(milliseconds: value);
    }
  }

  Duration _splashDuration;
  Duration _transitionDuration;
  Duration _decorationDuration;
  
  final DecorationTween decorationTween = DecorationTween(
    begin: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(2.5, -1.0),
          end:   Alignment(-1.0, 1.5),
          colors: [
            Constants.colors.darkBlue,
            Constants.colors.darkPurple,
            Constants.colors.purple,
            Constants.colors.greyishPink,
            Constants.colors.darkPink,
          ],
          stops: [
            0, 0.2, 0.5, 0.8, 1.0
          ]
        )
      ),
    end: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(2.0, -0.5),
          end:   Alignment(-0.5, 2.0),
          colors: [
            Constants.colors.blackish,
            Constants.colors.darkPink,
            Constants.colors.pink,
            Constants.colors.lightPink,
            Constants.colors.blue,
            Constants.colors.darkBlue,
            Constants.colors.darkPurple,
            Constants.colors.blackish
          ],
          stops: [
            0, 0.15, 0.25, 0.34, 0.66, 0.75, 0.85, 1.0
          ]
        )
      )
  );

  void _transition({bool isDimiss = false, Offset swipeDelta}) {
    if (_transitionStarted) {
      return;
    }
    _transitionStarted = true;
    if (isDimiss) {
      _transitionDuration = Duration(
        milliseconds: _transitionDuration.inMilliseconds ~/ 2
      );
    }
    Navigator.of(_context).push(_createRoute(swipeDelta: swipeDelta));
  }

  double deltaDimToOffset(double delta, double deltaMax, double offsetMax) {
    final dir = delta < 0 ? 1 : -1;
    return (min(delta.abs(), deltaMax) / deltaMax) * offsetMax * dir;
  }
  Offset deltaToOffset(Offset delta) {
    final size = MediaQuery.of(_context).size;
    final deltaMaxX = size.width / 4;
    final deltaMaxY = size.height / 4;
    return Offset(
      deltaDimToOffset(delta.dx, deltaMaxX, 1.0),
      deltaDimToOffset(delta.dy, deltaMaxY, 1.0)
    );
  }

  Route _createRoute({Offset swipeDelta}) => PageRouteBuilder(
    barrierDismissible: true,
    pageBuilder: (ctx, animation, secondAnimation) => widget.next,
    transitionDuration: _transitionDuration,
    transitionsBuilder: (ctx, animation, secondAnimation, child) {
      final beginOffset = (swipeDelta != null) 
        ? deltaToOffset(swipeDelta)
        : Offset(0, 1.0);
      final slideTween = Tween(
        begin: beginOffset,
        end: Offset.zero
      ).chain(CurveTween(curve: Curves.ease));
      final fadeTween  = Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOut));

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child:  SlideTransition(
          position: animation.drive(slideTween),
          child: child,
        ) 
      );
    },
  );

  void _startTimeout() => Future.delayed(
    _splashDuration,
    _transition
  );

  @override
  void initState() {
    _splashDuration = _parseDuration(widget.timeout);
    _transitionDuration = _parseDuration(widget.transition);
    _decorationDuration = Duration(
      milliseconds: _splashDuration.inMilliseconds +
                    _transitionDuration.inMilliseconds
    );
    _controller = AnimationController(
      vsync: this,
      duration: _decorationDuration,
    )..repeat(reverse: true);

    super.initState();

    _startTimeout();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _context = context;
    final size = MediaQuery.of(context).size;

    return DecoratedBoxTransition(
      position: DecorationPosition.background,
      decoration: decorationTween.animate(_controller),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: size.height / 4,
            width: size.width / 3,
            height: size.height / 3,
            child: Align(
                alignment: Alignment.center,
                child: Logo(logo: Logos.rpljs)
            )
          ),
          Positioned(
            bottom: sh.size(2),
            width: size.width / 5,
            height: size.height / 5,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Logo(logo: Logos.fivebyfive)
            )),
          Positioned(
            top: 0,
            left: 0,
            width: size.width,
            height: size.height,
            child: GestureDetector(
              onTap: () => _transition(isDimiss: true),
              onPanUpdate: (details)  {
                print("${details.delta.dx}, ${details.delta.dy}");
                if (details.delta.distanceSquared > pow(15.0, 2.0)) {
                  _transition(isDimiss: true, swipeDelta: details.delta);
                } 
              },
            )
          ),
        ],
      )
    );
  }
}
import 'dart:math' as _math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'circle_view.dart';

typedef JoystickDirectionCallback = void Function(
    double degrees, double distance);

class JoystickView extends StatelessWidget {
  /// The size of the joystick.
  ///
  /// Defaults to half of the width in the portrait
  /// or half of the height in the landscape mode
  final double? size;

  /// Color of the icons
  ///
  /// Defaults to [Colors.white54]
  final Color iconsColor;

  /// Color of the joystick background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color backgroundColor;

  /// Color of the inner (smaller) circle background
  ///
  /// Defaults to [Colors.blueGrey]
  final Color innerCircleColor;

  /// Opacity of the joystick
  ///
  /// The opacity applies to the whole joystick including icons
  ///
  /// Defaults to [null] which means there will be no [Opacity] widget used
  final double opacity;

  // Indicates what type joystick should return
  //
  // Instead of degrees/distance returns coordinates if true
  //
  // Defaults to [false]
  final bool returnCoordinates;

  /// Callback to be called when user pans the joystick
  ///
  /// Defaults to [null]
  final JoystickDirectionCallback onDirectionChanged;

  /// Indicates how often the [onDirectionChanged] should be called.
  ///
  /// Defaults to [null] which means there will be no lower limit.
  /// Setting it to ie. 1 second will cause the callback to be not called more often
  /// than once per second.
  ///
  /// The exception is the [onDirectionChanged] callback being called
  /// on the [onPanStart] and [onPanEnd] callbacks. It will be called immediately.
  final Duration interval;

  /// Shows top/right/bottom/left arrows on top of Joystick
  ///
  /// Defaults to [true]
  final bool showArrows;

  final Image? buttonImage;

  JoystickView(
      {this.size,
      this.iconsColor = Colors.white54,
      this.backgroundColor = Colors.blueGrey,
      this.innerCircleColor = Colors.blueGrey,
      this.opacity = 1,
      this.returnCoordinates = false,
      required this.onDirectionChanged,
      required this.interval,
      this.showArrows = true,
      this.buttonImage});

  @override
  Widget build(BuildContext context) {
    var actualSize = size ??
        _math.min(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height) *
            0.5;
    var innerCircleSize = actualSize / 2;
    var lastPosition = Offset(innerCircleSize, innerCircleSize);
    var joystickInnerPosition = _calculatePositionOfInnerCircle(
        lastPosition, innerCircleSize, actualSize, Offset(0, 0));

    DateTime? _callbackTimestamp = DateTime.now();

    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          Widget joystick = Stack(
            children: <Widget>[
              CircleView.joystickCircle(
                actualSize,
                backgroundColor,
                  buttonImage!),
              Positioned(
                top: joystickInnerPosition.dy,
                left: joystickInnerPosition.dx,
                child: CircleView.joystickInnerCircle(
                  actualSize / 2,
                  innerCircleColor,
                    buttonImage!),
              ),
              if (showArrows) ...createArrows(),
            ],
          );

          return GestureDetector(
              onPanStart: (details) {
                _callbackTimestamp = _processGesture(actualSize, actualSize / 2,
                    details.localPosition, _callbackTimestamp!);
                setState(() => lastPosition = details.localPosition);
              },
              onPanEnd: (details) {
                _callbackTimestamp = DateTime.now();
                onDirectionChanged(0, 0);
                joystickInnerPosition = _calculatePositionOfInnerCircle(
                    Offset(innerCircleSize, innerCircleSize),
                    innerCircleSize,
                    actualSize,
                    Offset(0, 0));
                setState(() =>
                    lastPosition = Offset(innerCircleSize, innerCircleSize));
              },
              onPanUpdate: (details) {
                _callbackTimestamp = _processGesture(actualSize, actualSize / 2,
                    details.localPosition, _callbackTimestamp!);
                joystickInnerPosition = _calculatePositionOfInnerCircle(
                    lastPosition,
                    innerCircleSize,
                    actualSize,
                    details.localPosition);

                setState(() => lastPosition = details.localPosition);
              },
              child: Opacity(opacity: opacity, child: joystick));
        },
      ),
    );
  }

  List<Widget> createArrows() {
    return [
      Positioned(
        top: 16.0,
        left: 0.0,
        right: 0.0,
        child: Icon(
          Icons.arrow_upward,
          color: iconsColor,
        ),
      ),
      Positioned(
        top: 0.0,
        bottom: 0.0,
        left: 16.0,
        child: Icon(
          Icons.arrow_back,
          color: iconsColor,
        ),
      ),
      Positioned(
        top: 0.0,
        bottom: 0.0,
        right: 16.0,
        child: Icon(
          Icons.arrow_forward,
          color: iconsColor,
        ),
      ),
      Positioned(
        bottom: 16.0,
        left: 0.0,
        right: 0.0,
        child: Icon(
          Icons.arrow_downward,
          color: iconsColor,
        ),
      ),
    ];
  }

  DateTime _processGesture(double size, double ignoreSize, Offset offset,
      DateTime callbackTimestamp) {
    var middle = size / 2.0;

    var angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    var degrees = angle * 180 / _math.pi + 90;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }

    var dx = _math.max(0, _math.min(offset.dx, size));
    var dy = _math.max(0, _math.min(offset.dy, size));

    var distance =
        _math.sqrt(_math.pow(middle - dx, 2) + _math.pow(middle - dy, 2));

    var normalizedDistance = _math.min(distance / (size / 2), 1.0);

    var _callbackTimestamp = callbackTimestamp;
    if (_canCallOnDirectionChanged(callbackTimestamp)) {
      _callbackTimestamp = DateTime.now();
      if (returnCoordinates) {
        onDirectionChanged(offset.dx, offset.dy);
      }
      onDirectionChanged(degrees, normalizedDistance);
    }

    return _callbackTimestamp;
  }

  /// Checks if the [onDirectionChanged] can be called.
  ///
  /// Returns true if enough time has passed since last time it was called
  /// or when there is no [interval] set.
  bool _canCallOnDirectionChanged(DateTime callbackTimestamp) {
    var intervalMilliseconds = interval.inMilliseconds;
    var timestampMilliseconds = callbackTimestamp.millisecondsSinceEpoch;
    var currentTimeMilliseconds = DateTime.now().millisecondsSinceEpoch;

    if (currentTimeMilliseconds - timestampMilliseconds <=
        intervalMilliseconds) {
      return false;
    }

    return true;
  }

  Offset _calculatePositionOfInnerCircle(
      Offset lastPosition, double innerCircleSize, double size, Offset offset) {
    var middle = size / 2.0;

    var angle = _math.atan2(offset.dy - middle, offset.dx - middle);
    var degrees = angle * 180 / _math.pi;
    if (offset.dx < middle && offset.dy < middle) {
      degrees = 360 + degrees;
    }
    var isStartPosition = lastPosition.dx == innerCircleSize &&
        lastPosition.dy == innerCircleSize;
    var lastAngleRadians =
        (isStartPosition) ? 0 : (degrees) * (_math.pi / 180.0);

    var rBig = size / 2;
    var rSmall = innerCircleSize / 2;

    var x = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.cos(lastAngleRadians);
    var y = (lastAngleRadians == -1)
        ? rBig - rSmall
        : (rBig - rSmall) + (rBig - rSmall) * _math.sin(lastAngleRadians);

    var xPosition = lastPosition.dx - rSmall;
    var yPosition = lastPosition.dy - rSmall;

    var angleRadianPlus = lastAngleRadians + _math.pi / 2;
    if (angleRadianPlus < _math.pi / 2) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < _math.pi) {
      if (xPosition > x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else if (angleRadianPlus < 3 * _math.pi / 2) {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition > y) {
        yPosition = y;
      }
    } else {
      if (xPosition < x) {
        xPosition = x;
      }
      if (yPosition < y) {
        yPosition = y;
      }
    }
    return Offset(xPosition, yPosition);
  }
}

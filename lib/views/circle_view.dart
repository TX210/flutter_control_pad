import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CircleView extends StatelessWidget {
  final double? size;

  final Color? color;

  final List<BoxShadow> boxShadow;

  final Border border;

  final double opacity;

  final Image? buttonImage;

  final Icon? buttonIcon;

  final String? buttonText;

  CircleView({
    this.size,
    this.color = Colors.transparent,
    required this.boxShadow,
    required this.border,
    this.opacity = 1,
    this.buttonText,
    this.buttonImage,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: Center(
        child: buttonIcon != null
            ? buttonIcon
            : (buttonImage != null)
            ? buttonImage
            : (buttonText != null) ? Text(buttonText!) : Text(''),
      ),
    );
  }

  factory CircleView.joystickCircle(double size, Color color) => CircleView(
        size: size,
        color: color,
        border: Border.all(
          color: Colors.transparent,
          width: 4.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 8.0,
            blurRadius: 8.0,
          )
        ],
      );

  factory CircleView.joystickInnerCircle(
          double size, Color color, Image? buttonImage) =>
      CircleView(
        size: size,
        color: color,
        buttonImage: buttonImage,
        border: Border.all(
          color: Colors.black26,
          width: 2.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 8.0,
            blurRadius: 8.0,
          )
        ],
      );

  factory CircleView.padBackgroundCircle(
          double size, Color backgroundColour, borderColor, Color shadowColor,
          { double opacity = 1}) =>
      CircleView(
        size: size,
        color: backgroundColour,
        opacity: opacity,
        border: Border.all(
          color: borderColor,
          width: 4.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: shadowColor,
            spreadRadius: 8.0,
            blurRadius: 8.0,
          )
        ],
      );

  factory CircleView.padButtonCircle(
    double size,
    Color? color,
    Image? image,
    Icon? icon,
    String? text,
  ) =>
      CircleView(
        size: size,
        color: color,
        border: Border.all(
          color: Colors.black26,
          width: 2.0,
          style: BorderStyle.solid,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            spreadRadius: 8.0,
            blurRadius: 8.0,
          )
        ],
      );
}

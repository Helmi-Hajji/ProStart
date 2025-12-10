import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

class Utils {
  static void showLoadingDialog(BuildContext context, {String? animationAsset}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Stack(
          children: [
            // Blur the background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 500,
                    height: 500,
                    child: Lottie.asset(
                      animationAsset ?? 'assets/animations/loading_animation.json',
                      repeat: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}

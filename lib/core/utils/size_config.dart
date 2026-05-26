import 'package:flutter/widgets.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockHorizontal;
  static late double blockVertical;
  
  static late double textMultiplier;
  static late double imageSizeMultiplier;
  static late double heightMultiplier;
  static late double widthMultiplier;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    
    // Scale against reference layout: Width 390 (iPhone 13 standard), Height 844
    blockHorizontal = screenWidth / 100;
    blockVertical = screenHeight / 100;

    textMultiplier = blockVertical;
    imageSizeMultiplier = blockHorizontal;
    heightMultiplier = blockVertical;
    widthMultiplier = blockHorizontal;
  }

  // Adaptive Helpers
  static double getRelativeHeight(double pixels) {
    return (pixels / 844) * screenHeight;
  }

  static double getRelativeWidth(double pixels) {
    return (pixels / 390) * screenWidth;
  }

  static double getRelativeFontSize(double pixels) {
    return (pixels / 844) * screenHeight;
  }
}

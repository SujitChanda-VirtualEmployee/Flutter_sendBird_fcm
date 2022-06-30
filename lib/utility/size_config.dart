import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';


class SizeConfig{
  static double? screenWidth;
  static double ?screenHeight;
  static double ?_blockSizeHorizontal =0;
  static double ?_blockSizeVerticle  = 0;

  static double ?textMultiplier;
  static double ?imageSizeMultiplier;
  static double ?heightMultiplier;

  

  void init(BoxConstraints constraints, Orientation orientation){
    if(orientation == Orientation.portrait){
      screenHeight = constraints.maxHeight;
      screenWidth = constraints.maxWidth;
    }else{
      screenHeight = constraints.maxWidth;
      screenWidth = constraints.maxHeight;
    }
    _blockSizeHorizontal = screenWidth!/100;
    _blockSizeVerticle = screenHeight!/100;

    textMultiplier = _blockSizeVerticle;
    imageSizeMultiplier = _blockSizeHorizontal;
    heightMultiplier = _blockSizeVerticle;

    print(_blockSizeHorizontal);
    print(_blockSizeVerticle);
  }
}
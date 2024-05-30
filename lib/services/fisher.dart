import 'package:distributions/distributions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Fisher {
  static Future<double?> inv({
    required double alpha,
    required int df1,
    required int df2,
  }) async {
    double? result;
    try {
      result = await Distributions.inv(
        alpha: alpha,
        df1: df1,
        df2: df2,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to get result: ${e.message}');
    }
    return result;
  }
}

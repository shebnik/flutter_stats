import 'package:distributions/distributions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Student {
  static Future<double?> inv2T({
    required double alpha,
    required int df,
  }) async {
    double? result;
    try {
      result = await Distributions.student(
        alpha: alpha,
        df: df,
      );
    } on PlatformException catch (e) {
      debugPrint('Failed to get result: ${e.message}');
    }
    return result;
  }
}

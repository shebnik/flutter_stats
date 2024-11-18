import 'package:flutter/material.dart';

const appName = 'Flutter Stats';
const List<String> intervalHeaders = [
  'Lower confidence limit',
  'Upper confidence limit',
  'Lower prediction limit',
  'Upper prediction limit',
];
const alpha = 0.005;

const assetsPath = 'assets';
const iconsPath = '$assetsPath/icons';
const excelSVG = '$iconsPath/excel.svg';

const aliases = [
  'SLOC',
  'NOC',
  'NOM',
  'DIT',
  'RFC',
  'CBO',
  'WMC',
];

const email = 'shebnik@outlook.com';

enum QualityTypes {
  high,
  medium,
  low,
  unknown,
}

extension QualityTypesExtension on QualityTypes {
  Color get color {
    switch (this) {
      case QualityTypes.high:
        return Colors.green;
      case QualityTypes.medium:
        return Colors.orange;
      case QualityTypes.low:
        return Colors.red;
      case QualityTypes.unknown:
        return Colors.grey;
    }
  }
}

const intervalsHeaders = [
  '#',
  'Y',
  r'\hat{Y}',
  'Lower confidence',
  'Upper confidence',
  'Lower prediction',
  'Upper prediction',
];

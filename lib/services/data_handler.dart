import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';

class DataHandler {
  factory DataHandler() {
    return _dataHandler;
  }

  DataHandler._internal();
  static final DataHandler _dataHandler = DataHandler._internal();

  final filePicker = FilePicker.platform;

  Future<Uint8List?> _pickFile() async {
    final result = await filePicker.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );

    final platformFile = result?.files.single;

    Uint8List? bytes;
    if (kIsWeb) {
      bytes = platformFile?.bytes;
    } else {
      if (platformFile == null || platformFile.path == null) {
        return null;
      }
      final file = File(platformFile.path!);
      bytes = await file.readAsBytes();
    }

    return bytes;
  }

  Future<List<Project>?> retrieveData() async {
    final bytes = await _pickFile();
    if (bytes == null) {
      throw Exception('No file selected');
    }
    final rows = const CsvToListConverter().convert(
      String.fromCharCodes(bytes),
    );

    final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();

    final nameIndex = headers.indexOf('name');
    final urlIndex = headers.indexOf('url');
    final classesIndex = getMetricIndex(headers, ['classes', 'x', 'x1']);
    final methodsIndex = getMetricIndex(headers, ['methods', 'x2']);
    final dependenciesIndex = getMetricIndex(headers, ['dependencies', 'x3']);
    final locIndex = getMetricIndex(headers, ['code', 'y', 'lines']);

    final projects = <Project>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];

      final name = getValue(row, nameIndex, '');
      final url = getValue(row, urlIndex, '');

      final classes = getDoubleValue(row, classesIndex);
      final methods = getDoubleValue(row, methodsIndex);
      final dependencies = getDoubleValue(row, dependenciesIndex);
      var loc = getDoubleValue(row, locIndex);
      if (loc != null) loc /= 1000;

      final project = Project(
        name: name,
        url: url,
        metrics: Metrics(
          numberOfClasses: classes,
          numberOfMethods: methods,
          numberOfDependencies: dependencies,
          linesOfCode: loc,
        ),
      );

      projects.add(project);
    }

    return projects;
  }

  int getMetricIndex(List<dynamic> headers, List<String> aliases) {
    for (var i = 0; i < headers.length; i++) {
      final lowerHeader = headers[i].toString().toLowerCase();
      for (final alias in aliases) {
        final lowerAlias = alias.toLowerCase();
        if (lowerHeader.contains(lowerAlias)) {
          if (lowerAlias == 'y' && lowerAlias != lowerHeader) continue;
          return i;
        }
      }
    }
    return -1;
  }

  String? getValue(List<dynamic> row, int index, String defaultValue) {
    return index >= 0 ? row[index] as String? : defaultValue;
  }

  double? getDoubleValue(List<dynamic> row, int index) {
    return index >= 0 ? double.tryParse(row[index].toString()) : null;
  }
}

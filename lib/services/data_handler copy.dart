import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';

class DataHandler {
  factory DataHandler() {
    return _dataHandler;
  }

  DataHandler._internal();
  static final DataHandler _dataHandler = DataHandler._internal();

  final filePicker = FilePicker.platform;

  Future<File?> _pickFile() async {
    final result = await filePicker.pickFiles(
      allowedExtensions: ['csv'],
      type: FileType.custom,
    );

    final path = result?.files.single.path;
    if (path != null) {
      return File(path);
    }
    return null;
  }

  Future<List<Project>?> retrieveData() async {
    final file = await _pickFile();
    if (file == null) {
      return null;
    }
    final input = file.openRead();
    final rows = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .toList();

    final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();

    final nameIndex = headers.indexOf('name');
    final urlIndex = headers.indexOf('url');
    final classesIndex = getMetricIndex(headers, ['classes', 'x', 'x1']);
    final methodsIndex = getMetricIndex(headers, ['methods', 'x2']);
    final complexityIndex = getMetricIndex(headers, ['complexity', 'x3']);
    final locIndex = getMetricIndex(headers, ['code', 'y', 'lines']);

    final projects = <Project>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];

      final name = getValue(row, nameIndex, '');
      final url = getValue(row, urlIndex, '');

      final classes = getDoubleValue(row, classesIndex);
      final methods = getDoubleValue(row, methodsIndex);
      final complexity = getDoubleValue(row, complexityIndex);
      var loc = getDoubleValue(row, locIndex);
      if (loc != null) loc /= 1000;

      final project = Project(
        name: name,
        url: url,
        metrics: Metrics(
          numberOfClasses: classes,
          numberOfMethods: methods,
          cyclomaticComplexity: complexity,
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

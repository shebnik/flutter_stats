import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';

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

  Future<List<Metrics>> retrieveData() async {
    final file = await _pickFile();
    if (file == null) {
      throw Exception('File not found');
    }
    final input = file.openRead();
    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter())
        .skip(1)
        .toList();

    try {
      final metrics = fields
          .map(
            (e) => Metrics(
              numberOfClasses: double.parse(e[0].toString()),
              linesOfCode: double.parse(e[1].toString()) / 1000,
            ),
          )
          .toList();
      return metrics;
    } catch (e) {
      throw Exception('Invalid file format');
    }
  }
}

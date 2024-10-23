// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/providers/outliers_provider.dart';
import 'package:flutter_stats/services/logger.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class DataHandler {
  final _logger = AppLogger().logger;
  final filePicker = FilePicker.platform;

  Future<void> loadDataFile(
    BuildContext context, {
    bool useAssetDataset = false,
  }) async {
    final model = context.read<OutliersProvider>();
    try {
      final projects = await retrieveData(useAssetDataset: useAssetDataset);
      if (projects == null) {
        _logger.i('No file selected');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No file selected'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 1),
          ),
        );
      }
      model.setProjects(projects);
    } catch (e, s) {
      _logger.e('Error loading data file', error: e, stackTrace: s);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid file format'),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<Uint8List?> _pickFile({
    bool useAssetDataset = false,
  }) async {
    if (useAssetDataset) {
      final asset = await rootBundle.load('assets/dataset.csv');
      return asset.buffer.asUint8List();
    }
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

  Future<List<Project>?> retrieveData({
    bool useAssetDataset = false,
  }) async {
    final bytes = await _pickFile(useAssetDataset: useAssetDataset);
    if (bytes == null) {
      throw Exception('No file selected');
    }
    final rows = const CsvToListConverter().convert(
      String.fromCharCodes(bytes),
    );

    final headers = rows[0].map((h) => h.toString().toLowerCase()).toList();

    final nameIndex = headers.indexOf('name');
    final urlIndex = headers.indexOf('url');
    final ditIndex = getMetricIndex(headers, ['dit', 'x', 'x1']);
    final cboIndex = getMetricIndex(headers, ['cbo', 'x2']);
    final wmcIndex = getMetricIndex(headers, ['wmc', 'x3']);
    final rfcIndex = getMetricIndex(headers, ['rfc', 'y']);
    final nocIndex = getMetricIndex(headers, ['noc']);

    final projects = <Project>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];

      final name = getValue(row, nameIndex, '');
      final url = getValue(row, urlIndex, '');

      final dit = getDoubleValue(row, ditIndex);
      final cbo = getDoubleValue(row, cboIndex);
      final wmc = getDoubleValue(row, wmcIndex);
      final rfc = getDoubleValue(row, rfcIndex);
      final noc = getDoubleValue(row, nocIndex);

      final project = Project(
        name: name,
        url: url,
        metrics: Metrics(
          dit: dit,
          rfc: rfc,
          cbo: cbo,
          wmc: wmc,
          noc: noc,
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

  Future<void> downloadFile({
    required String fileName,
    required List<Project> projects,
  }) async {
    fileName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    final normalizedProjects = Normalization().normalizeProjects(projects);
    final csv = const ListToCsvConverter().convert([
      [
        'No.',
        'URL',
        'NOC',
        'DIT',
        'CBO',
        'WMC',
        'RFC',
        '',
        'Zy',
        'Zx1',
        'Zx2',
        'Zx3',
      ],
      ...List.generate(projects.length, (i) {
        final project = projects[i];
        final metrics = project.metrics;
        final normalized = normalizedProjects[i].metrics;
        return [
          i + 1,
          project.url,
          if (metrics != null) metrics.noc,
          if (metrics != null) metrics.dit,
          if (metrics != null) metrics.cbo,
          if (metrics != null) metrics.wmc,
          if (metrics != null) metrics.rfc,
          '',
          if (normalized != null) normalized.rfc,
          if (normalized != null) normalized.dit,
          if (normalized != null) normalized.cbo,
          if (normalized != null) normalized.wmc,
        ];
      }),
    ]);

    final bytes = Uint8List.fromList(csv.codeUnits);

    if (kIsWeb) {
      // Web platform implementation
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      try {
        // Show save file dialog
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save CSV file',
          fileName: fileName,
          type: FileType.custom,
          allowedExtensions: ['csv'],
        );

        if (outputFile != null) {
          final file = File(outputFile);
          await file.writeAsBytes(bytes);
        }
      } catch (e) {
        // Handle any errors that occur during file saving
        _logger.e('Error saving file', error: e);
        rethrow;
      }
    }
  }
}

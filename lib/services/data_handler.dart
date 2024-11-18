// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stats/models/dataset/dataset.dart';
import 'package:flutter_stats/models/intervals/intervals.dart';
import 'package:flutter_stats/models/metrics/metrics.dart';
import 'package:flutter_stats/models/project/project.dart';
import 'package:flutter_stats/models/settings/settings.dart';
import 'package:flutter_stats/providers/metrics_navigation_provider.dart';
import 'package:flutter_stats/providers/projects_provider.dart';
import 'package:flutter_stats/providers/regression_model_provider.dart';
import 'package:flutter_stats/providers/settings_provider.dart';
import 'package:flutter_stats/services/database.dart';
import 'package:flutter_stats/services/logging/logger_service.dart';
import 'package:flutter_stats/services/normalization.dart';
import 'package:flutter_stats/services/regression_model.dart';
import 'package:flutter_stats/services/utils.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

class DataHandler {
  DataHandler();

  final _logger = LoggerService.instance;
  final filePicker = FilePicker.platform;

  Future<void> loadDataFile(
    BuildContext context, {
    bool useAssetDataset = false,
    bool retrieveCached = true,
    bool promptUser = true,
  }) async {
    final projectsProvider = context.read<ProjectsProvider>();
    if (!promptUser && projectsProvider.projects.isEmpty) {
      return;
    }

    var settings = context.read<SettingsProvider>().settings;
    final db = context.read<Database>();

    try {
      Uint8List? bytes;

      // First, try to get cached data if requested
      if (retrieveCached) {
        final cachedDataset = db.getDataset();
        if (cachedDataset != null) {
          bytes = cachedDataset.data;
        }
      }

      // If no cached data, retrieve new data
      if (bytes == null && promptUser) {
        bytes = await retrieveData(
          dialogTitle: 'Load Dataset File',
          useAssetDataset: useAssetDataset,
          settings: settings,
        );
        settings = context.read<SettingsProvider>().settings;

        // Save the new data to cache
        if (bytes != null) {
          await db.setDataset(Dataset(data: bytes, name: 'dataset.csv'));
        }
      }

      // Handle no data case
      if (bytes == null) {
        _logger.i('No file selected');
        return;
      }

      // Parse and validate data
      final projects = parseData(
        bytes: bytes,
        settings: settings,
      );

      if (projects == null || projects.isEmpty) {
        Utils.showNotification(
          context,
          message: 'No data found in the file. Consider visiting app settings',
          isError: true,
        );
        return;
      }

      // Update projects
      await projectsProvider.setProjects(
        projects,
        useRelativeNOC: settings.useRelativeNOC,
        divideYByNOC: settings.divideYByNOC,
      );
    } catch (e, s) {
      _logger.e('Error loading data file', error: e, stackTrace: s);
      Utils.showNotification(
        context,
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<void> uploadFile({
    required BuildContext context,
    required MetricsNavigationType type,
  }) async {
    try {
      final settings = context.read<SettingsProvider>().settings;
      final bytes = await retrieveData(
        settings: settings,
        dialogTitle: 'Load ${type.label}',
      );

      if (bytes == null) {
        _logger.i('No file selected');
        return;
      }

      var projects = parseData(
        bytes: bytes,
        settings: settings,
      );

      if (projects == null || projects.isEmpty) {
        Utils.showNotification(
          context,
          message: 'No data found in the file. Consider visiting app settings',
          isError: true,
        );
        return;
      }

      if (settings.useRelativeNOC) {
        projects = projects.map((e) {
          final metrics = e.metrics;
          final denominator =
              metrics.noc != null && metrics.noc! > 0 ? metrics.noc! : 1.0;
          return e.copyWith(
            metrics: metrics.copyWith(
              y: metrics.y / denominator,
              x1: metrics.x1 / denominator,
              x2: metrics.x2 != null ? metrics.x2! / denominator : null,
              x3: metrics.x3 != null ? metrics.x3! / denominator : null,
            ),
          );
        }).toList();
      }
      final regressionModelProvider = context.read<RegressionModelProvider>();
      final model = regressionModelProvider.model;
      var allProjects = <Project>[];
      if (type == MetricsNavigationType.train) {
        allProjects = [...projects, ...model?.testProjects ?? []];
        regressionModelProvider.model = RegressionModel(
          allProjects,
          trainProjects: projects,
          testProjects: model?.testProjects ?? [],
        );
      } else {
        allProjects = [...model?.trainProjects ?? [], ...projects];
        regressionModelProvider.model = RegressionModel(
          allProjects,
          trainProjects: model?.trainProjects ?? [],
          testProjects: projects,
        );
      }
      await context.read<ProjectsProvider>().setProjects(
            allProjects,
            useRelativeNOC: false,
            refit: false,
            divideYByNOC: false,
          );
    } catch (e, s) {
      _logger.e('Error uploading file', error: e, stackTrace: s);
      Utils.showNotification(
        context,
        message: e.toString(),
        isError: true,
      );
    }
  }

  Future<Uint8List?> _pickFile({
    bool useAssetDataset = false,
    String? dialogTitle,
  }) async {
    if (useAssetDataset) {
      final asset = await rootBundle.load('assets/dataset.csv');
      return asset.buffer.asUint8List();
    }
    final result = await filePicker.pickFiles(
      dialogTitle: dialogTitle,
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

  Future<Uint8List?> retrieveData({
    required Settings settings,
    String? dialogTitle,
    bool useAssetDataset = false,
  }) async {
    Uint8List? bytes;
    try {
      bytes = await _pickFile(
        useAssetDataset: useAssetDataset,
        dialogTitle: dialogTitle,
      );
    } catch (e, s) {
      _logger.e('Error picking file', error: e, stackTrace: s);
      throw Exception('Error picking file');
    }
    if (bytes == null) {
      return null;
    }
    return bytes;
  }

  List<Project>? parseData({
    required Uint8List bytes,
    required Settings settings,
  }) {
    try {
      final rows = const CsvToListConverter(
        eol: '\n',
      ).convert(
        String.fromCharCodes(bytes),
      );

      final headers =
          rows[0].map((h) => h.toString().trim().toUpperCase()).toList();
      final csvAlias = settings.csvAlias;

      final nameIndex = headers.indexOf('name');
      final urlIndex = headers.indexOf(csvAlias.url.toUpperCase());
      final x1Index = getMetricIndex(headers, [csvAlias.x1, 'x', 'x1']);
      final x2Index = getMetricIndex(headers, [csvAlias.x2, 'x2']);
      final x3Index = getMetricIndex(headers, [csvAlias.x3, 'x3']);
      final yIndex = getMetricIndex(headers, [csvAlias.y, 'y']);
      final nocIndex = getMetricIndex(headers, [csvAlias.noc, 'noc']);

      final projects = <Project>[];

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];

        final name = getValue(row, nameIndex, '');
        final url = getValue(row, urlIndex, '');

        final x1 = getDoubleValue(row, x1Index);
        final x2 = getDoubleValue(row, x2Index);
        final x3 = getDoubleValue(row, x3Index);
        final noc = getDoubleValue(row, nocIndex);
        var y = getDoubleValue(row, yIndex);
        if (settings.useYInThousands) {
          y = y != null ? y / 1000 : null;
        }

        final project = Project(
          name: name,
          url: url,
          metrics: Metrics(
            y: y ?? 0,
            x1: x1 ?? 0,
            x2: settings.hasX2 ? x2 : null,
            x3: settings.hasX3 ? x3 : null,
            noc: settings.hasNOC ? noc : null,
          ),
        );

        projects.add(project);
      }

      return projects;
    } catch (e, s) {
      _logger.e('Error parsing data file', error: e, stackTrace: s);
      throw Exception('Error parsing data file');
    }
  }

  int getMetricIndex(List<dynamic> headers, List<String> aliases) {
    for (final alias in aliases) {
      final index = headers.indexOf(alias.toUpperCase());
      if (index != -1) {
        return index;
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
    required Settings settings,
  }) async {
    final csvAlias = settings.csvAlias;
    fileName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    final normalizedProjects = Normalization().normalizeProjects(projects);
    final csv = const ListToCsvConverter().convert([
      [
        '#',
        csvAlias.url,
        if (settings.hasNOC) csvAlias.noc,
        csvAlias.y,
        csvAlias.x1,
        if (settings.hasX2) csvAlias.x2,
        if (settings.hasX3) csvAlias.x3,
        '',
        'Zy',
        'Zx1',
        if (settings.hasX2) 'Zx2',
        if (settings.hasX3) 'Zx3',
      ],
      ...List.generate(projects.length, (i) {
        final project = projects[i];
        final metrics = project.metrics;
        final normalized = normalizedProjects[i].metrics;
        return [
          i + 1,
          project.url,
          if (settings.hasNOC) metrics.noc,
          if (settings.hasNOC &&
              settings.useRelativeNOC &&
              settings.divideYByNOC)
            ((metrics.y) * (metrics.noc ?? 1)).roundToDouble()
          else
            metrics.y,
          if (settings.hasNOC && settings.useRelativeNOC)
            (metrics.x1 * (metrics.noc ?? 1)).roundToDouble()
          else
            metrics.x1,
          if (settings.hasX2)
            if (settings.hasNOC && settings.useRelativeNOC)
              ((metrics.x2 ?? 0) * (metrics.noc ?? 1)).roundToDouble()
            else
              metrics.x2,
          if (settings.hasX3)
            if (settings.hasNOC && settings.useRelativeNOC)
              ((metrics.x3 ?? 0) * (metrics.noc ?? 1)).roundToDouble()
            else
              metrics.x3,
          '',
          normalized.y,
          normalized.x1,
          if (settings.hasX2) normalized.x2,
          if (settings.hasX3) normalized.x3,
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

  Future<void> downloadIntervalsAsCSV({
    required List<String> intervalsHeaders,
    required Intervals table,
    required String fileName,
  }) async {
    fileName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    final csv = const ListToCsvConverter().convert([
      intervalsHeaders,
      ...List.generate(table.y.length, (i) {
        return [
          i + 1,
          table.y[i],
          table.yHat[i],
          table.confidenceLower[i],
          table.confidenceUpper[i],
          table.predictionLower[i],
          table.predictionUpper[i],
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

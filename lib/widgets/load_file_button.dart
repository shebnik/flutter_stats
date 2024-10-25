import 'package:flutter/material.dart';
import 'package:flutter_stats/services/data_handler.dart';
import 'package:provider/provider.dart';

class LoadFileButton extends StatelessWidget {
  const LoadFileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      elevation: 0,
      onPressed: () => context.read<DataHandler>().loadDataFile(
            context,
            retrieveCached: false,
          ),
      tooltip: 'Load CSV file',
      child: const Icon(Icons.file_upload_outlined),
    );
  }
}

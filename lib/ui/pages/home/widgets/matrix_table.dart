import 'package:flutter/material.dart';

class MatrixTable extends StatelessWidget {
  const MatrixTable({
    required this.title,
    required this.matrix,
    super.key,
  });
  final String title;
  final List<List<double>> matrix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          _buildMatrixTable(),
        ],
      ),
    );
  }

  Widget _buildMatrixTable() {
    final labels = List<String>.generate(matrix.length, (i) => 'X$i');

    return Table(
      border: TableBorder.all(),
      children: [
        TableRow(
          children: [
            TableCell(
              child: Container(),
            ),
            ...labels.map(
              (label) => TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(label, textAlign: TextAlign.center),
                ),
              ),
            ),
          ],
        ),
        ...matrix.map((row) {
          return TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Y${matrix.indexOf(row)}',
                  ),
                ),
              ),
              ...row.map(
                (cell) => TableCell(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('$cell'),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

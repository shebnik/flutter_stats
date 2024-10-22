// import 'package:flutter/material.dart';
// import 'package:flutter_stats/providers/outliers_provider.dart';
// import 'package:flutter_stats/ui/pages/home/widgets/matrix_table.dart';
// import 'package:provider/provider.dart';

// class CovarianceMatrixView extends StatelessWidget {
//   const CovarianceMatrixView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<OutliersProvider>();

//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Expanded(
//             child: MatrixTable(
//               title: 'Covariance Matrix',
//               matrix: provider.covarianceMatrix,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: MatrixTable(
//               title: 'Covariance Matrix Inverse',
//               matrix: provider.covarianceMatrixInverse,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

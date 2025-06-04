import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool scrollable;
  final double headingRowHeight;
  final double dataRowHeight;
  final double columnSpacing;
  final double horizontalMargin;

  const CustomDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.width,
    this.height,
    this.margin,
    this.scrollable = true,
    this.headingRowHeight = 56,
    this.dataRowHeight = 68,
    this.columnSpacing = 20,
    this.horizontalMargin = 16,
  });

  @override
  Widget build(BuildContext context) {
    final table = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: scrollable ? Axis.horizontal : Axis.vertical,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: scrollable ? constraints.maxWidth : 0,
                      minHeight: height ?? 0,
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: DataTable(
                        columnSpacing: columnSpacing,
                        horizontalMargin: horizontalMargin,
                        headingRowHeight: headingRowHeight,
                        dataRowHeight: dataRowHeight,
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        headingRowColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.grey[50]!,
                        ),
                        dataRowColor: MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) => Colors.white,
                        ),
                        dividerThickness: 0,
                        columns: columns,
                        rows: rows,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    if (height != null) {
      return SizedBox(
        height: height,
        child: table,
      );
    }
    
    return table;
  }
}

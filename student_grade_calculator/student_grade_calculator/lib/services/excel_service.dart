import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../models/student.dart';

class ExcelService {
  /// Parse uploaded Excel file bytes and extract students
  static Future<Map<String, dynamic>> parseExcelFile(
    Uint8List bytes, {
    String subject = 'Subject',
  }) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      final List<Student> students = [];
      final List<String> errors = [];

      // Use first sheet
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      // Detect header row - look for name/marks columns
      int nameCol = -1;
      int marksCol = -1;
      int startRow = 0;

      // Scan first 5 rows for headers
      for (int rowIdx = 0; rowIdx < sheet.rows.length && rowIdx < 5; rowIdx++) {
        final row = sheet.rows[rowIdx];
        for (int colIdx = 0; colIdx < row.length; colIdx++) {
          final cell = row[colIdx];
          if (cell == null) continue;
          final value = cell.value?.toString().toLowerCase().trim() ?? '';
          if (value.contains('name') || value.contains('student')) {
            nameCol = colIdx;
          }
          if (value.contains('mark') ||
              value.contains('score') ||
              value.contains('grade') ||
              value.contains('result')) {
            marksCol = colIdx;
          }
        }
        if (nameCol >= 0 && marksCol >= 0) {
          startRow = rowIdx + 1;
          break;
        }
      }

      // If no headers found, assume first col = name, second col = marks
      if (nameCol < 0 || marksCol < 0) {
        nameCol = 0;
        marksCol = 1;
        // Check if first row is a header (non-numeric in marks col)
        if (sheet.rows.isNotEmpty) {
          final firstRowMarks = sheet.rows[0][marksCol]?.value?.toString() ?? '';
          final parsed = double.tryParse(firstRowMarks);
          startRow = (parsed == null) ? 1 : 0;
        }
      }

      // Parse data rows
      for (int rowIdx = startRow; rowIdx < sheet.rows.length; rowIdx++) {
        final row = sheet.rows[rowIdx];
        if (row.isEmpty) continue;

        final nameCell = nameCol < row.length ? row[nameCol] : null;
        final marksCell = marksCol < row.length ? row[marksCol] : null;

        final name = nameCell?.value?.toString().trim() ?? '';
        final marksStr = marksCell?.value?.toString().trim() ?? '';

        if (name.isEmpty) continue;

        final marks = double.tryParse(marksStr);
        if (marks == null) {
          errors.add('Row ${rowIdx + 1}: Invalid marks "$marksStr" for "$name"');
          continue;
        }

        if (marks < 0 || marks > 100) {
          errors.add(
              'Row ${rowIdx + 1}: Marks out of range ($marks) for "$name". Expected 0-100.');
          continue;
        }

        students.add(Student.fromRaw(
          name: name,
          marks: marks,
          subject: subject,
        ));
      }

      return {
        'students': students,
        'errors': errors,
        'sheetName': sheetName,
        'success': students.isNotEmpty,
      };
    } catch (e) {
      return {
        'students': <Student>[],
        'errors': ['Failed to parse file: ${e.toString()}'],
        'sheetName': '',
        'success': false,
      };
    }
  }

  /// Generate output Excel file with grades
  static Future<Uint8List> generateGradeReport(
    List<Student> students, {
    String subject = 'Subject',
  }) async {
    final excel = Excel.createExcel();
    final sheetName = 'Grade Report';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // --- Header row styling ---
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#1A237E'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Title row
    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('D1'),
    );
    final titleCell = sheet.cell(CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue('Student Grade Report - $subject');
    titleCell.cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#0D47A1'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
      fontSize: 14,
    );

    // Header row
    final headers = ['#', 'Student Name', 'Marks (/100)', 'Grade'];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 1));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Set column widths
    sheet.setColumnWidth(0, 6);
    sheet.setColumnWidth(1, 28);
    sheet.setColumnWidth(2, 16);
    sheet.setColumnWidth(3, 12);

    // Grade color mapping
    final gradeColors = {
      'A': '#E8F5E9', // Light green
      'B': '#E3F2FD', // Light blue
      'C': '#FFF8E1', // Light amber
      'D': '#FFF3E0', // Light orange
      'F': '#FFEBEE', // Light red
    };

    // Data rows
    for (int i = 0; i < students.length; i++) {
      final student = students[i];
      final rowIndex = i + 2;
      final bgColor = gradeColors[student.grade] ?? '#FFFFFF';

      final rowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
        horizontalAlign: HorizontalAlign.Center,
      );
      final nameStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString(bgColor),
      );

      // Row number
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
        ..value = IntCellValue(i + 1)
        ..cellStyle = rowStyle;

      // Name
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
        ..value = TextCellValue(student.name)
        ..cellStyle = nameStyle;

      // Marks
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
        ..value = DoubleCellValue(student.marks)
        ..cellStyle = rowStyle;

      // Grade
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
        ..value = TextCellValue(student.grade)
        ..cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString(bgColor),
          horizontalAlign: HorizontalAlign.Center,
        );
    }

    // Summary section
    final summaryRow = students.length + 4;
    sheet.merge(
      CellIndex.indexByString('A$summaryRow'),
      CellIndex.indexByString('D$summaryRow'),
    );
    sheet.cell(CellIndex.indexByString('A$summaryRow'))
      ..value = TextCellValue('Summary')
      ..cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#37474F'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

    // Grade counts
    final gradeCounts = <String, int>{};
    double totalMarks = 0;
    for (final s in students) {
      gradeCounts[s.grade] = (gradeCounts[s.grade] ?? 0) + 1;
      totalMarks += s.marks;
    }

    final summaryData = [
      ['Total Students', students.length.toString()],
      ['Average Marks', students.isEmpty ? '0' : (totalMarks / students.length).toStringAsFixed(1)],
      ['Grade A (≥80)', '${gradeCounts['A'] ?? 0} students'],
      ['Grade B (70-79)', '${gradeCounts['B'] ?? 0} students'],
      ['Grade C (60-69)', '${gradeCounts['C'] ?? 0} students'],
      ['Grade D (50-59)', '${gradeCounts['D'] ?? 0} students'],
      ['Grade F (<50)', '${gradeCounts['F'] ?? 0} students'],
    ];

    for (int i = 0; i < summaryData.length; i++) {
      final row = summaryRow + 1 + i;
      sheet.cell(CellIndex.indexByString('A$row'))
        ..value = TextCellValue(summaryData[i][0])
        ..cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.fromHexString('#ECEFF1'));
      sheet.merge(
        CellIndex.indexByString('B$row'),
        CellIndex.indexByString('D$row'),
      );
      sheet.cell(CellIndex.indexByString('B$row'))
        ..value = TextCellValue(summaryData[i][1])
        ..cellStyle = CellStyle(backgroundColorHex: ExcelColor.fromHexString('#FAFAFA'));
    }

    return Uint8List.fromList(excel.encode()!);
  }

  /// Save bytes to a file in the downloads/documents directory
  static Future<String> saveFile(Uint8List bytes, String fileName) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        dir = await getExternalStorageDirectory();
      }
    } else if (Platform.isIOS) {
      dir = await getApplicationDocumentsDirectory();
    } else {
      // Desktop / other
      dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir!.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}

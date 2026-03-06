import 'package:flutter/material.dart';

class Student {
  final String name;
  final double marks;
  final String grade;
  final String subject;

  Student({
    required this.name,
    required this.marks,
    required this.grade,
    this.subject = '',
  });

  factory Student.fromRaw({
    required String name,
    required double marks,
    String subject = '',
  }) {
    return Student(
      name: name,
      marks: marks,
      grade: _calculateGrade(marks),
      subject: subject,
    );
  }

  static String _calculateGrade(double marks) {
    if (marks >= 80) return 'A';
    if (marks >= 70) return 'B';
    if (marks >= 60) return 'C';
    if (marks >= 50) return 'D';
    return 'F';
  }

  Color get gradeColor {
    switch (grade) {
      case 'A':
        return const Color(0xFF2E7D32); // Dark green
      case 'B':
        return const Color(0xFF1565C0); // Dark blue
      case 'C':
        return const Color(0xFFF57F17); // Amber
      case 'D':
        return const Color(0xFFE65100); // Deep orange
      default:
        return const Color(0xFFC62828); // Dark red
    }
  }
}

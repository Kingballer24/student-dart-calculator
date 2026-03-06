import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class GradingLegend extends StatelessWidget {
  const GradingLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3F2FD)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: Color(0xFF1A237E), size: 16),
              const Gap(6),
              Text(
                'Grading System',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Gap(10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _GradeChip(grade: 'A', range: '≥ 80', color: Colors.green.shade600, bg: Colors.green.shade50),
              _GradeChip(grade: 'B', range: '70 – 79', color: Colors.blue.shade700, bg: Colors.blue.shade50),
              _GradeChip(grade: 'C', range: '60 – 69', color: Colors.amber.shade700, bg: Colors.amber.shade50),
              _GradeChip(grade: 'D', range: '50 – 59', color: Colors.orange.shade700, bg: Colors.orange.shade50),
              _GradeChip(grade: 'F', range: '< 50', color: Colors.red.shade700, bg: Colors.red.shade50),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String grade;
  final String range;
  final Color color;
  final Color bg;

  const _GradeChip({
    required this.grade,
    required this.range,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            grade,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Gap(6),
          Text(
            range,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../models/student.dart';

class GradeSummaryCard extends StatelessWidget {
  final List<Student> students;

  const GradeSummaryCard({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    final gradeCounts = <String, int>{};
    double totalMarks = 0;
    double highest = double.negativeInfinity;
    double lowest = double.infinity;

    for (final s in students) {
      gradeCounts[s.grade] = (gradeCounts[s.grade] ?? 0) + 1;
      totalMarks += s.marks;
      if (s.marks > highest) highest = s.marks;
      if (s.marks < lowest) lowest = s.marks;
    }

    final avg = totalMarks / students.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A237E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_outlined,
                    color: Color(0xFF1A237E), size: 20),
              ),
              const Gap(10),
              Text(
                'Summary — ${students.length} Students',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const Gap(16),
          // Stats row
          Row(
            children: [
              _StatBox(label: 'Average', value: avg.toStringAsFixed(1), icon: Icons.bar_chart, color: const Color(0xFF1A237E)),
              const Gap(12),
              _StatBox(label: 'Highest', value: highest == double.negativeInfinity ? '-' : highest.toStringAsFixed(1), icon: Icons.arrow_upward, color: Colors.green.shade600),
              const Gap(12),
              _StatBox(label: 'Lowest', value: lowest == double.infinity ? '-' : lowest.toStringAsFixed(1), icon: Icons.arrow_downward, color: Colors.red.shade600),
            ],
          ),
          const Gap(16),
          // Grade distribution
          Row(
            children: [
              for (final grade in ['A', 'B', 'C', 'D', 'F'])
                Expanded(
                  child: _GradeBar(
                    grade: grade,
                    count: gradeCounts[grade] ?? 0,
                    total: students.length,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(color: color.withOpacity(0.8), fontSize: 11)),
                Text(value,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradeBar extends StatelessWidget {
  final String grade;
  final int count;
  final int total;

  const _GradeBar(
      {required this.grade, required this.count, required this.total});

  Color get _color {
    switch (grade) {
      case 'A': return Colors.green.shade600;
      case 'B': return Colors.blue.shade700;
      case 'C': return Colors.amber.shade700;
      case 'D': return Colors.orange.shade700;
      default: return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : count / total;
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Column(
        children: [
          Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _color,
                  fontSize: 15)),
          const Gap(4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: _color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(_color),
            ),
          ),
          const Gap(4),
          Text('Grade $grade',
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

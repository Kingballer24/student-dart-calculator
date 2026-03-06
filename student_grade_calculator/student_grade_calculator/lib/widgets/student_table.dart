import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentTable extends StatefulWidget {
  final List<Student> students;

  const StudentTable({super.key, required this.students});

  @override
  State<StudentTable> createState() => _StudentTableState();
}

class _StudentTableState extends State<StudentTable> {
  String _sortBy = 'name'; // 'name', 'marks', 'grade'
  bool _ascending = true;
  String _filterGrade = 'All';

  List<Student> get _sortedFiltered {
    var list = widget.students.where((s) {
      if (_filterGrade == 'All') return true;
      return s.grade == _filterGrade;
    }).toList();

    list.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case 'marks':
          cmp = a.marks.compareTo(b.marks);
          break;
        case 'grade':
          cmp = a.grade.compareTo(b.grade);
          break;
        default:
          cmp = a.name.compareTo(b.name);
      }
      return _ascending ? cmp : -cmp;
    });
    return list;
  }

  void _toggleSort(String col) {
    setState(() {
      if (_sortBy == col) {
        _ascending = !_ascending;
      } else {
        _sortBy = col;
        _ascending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final students = _sortedFiltered;

    return Container(
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
          // Table header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.table_chart_outlined,
                          color: Color(0xFF1A237E), size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text('Student Results',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A237E),
                        )),
                  ],
                ),
                // Grade filter
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterGrade,
                    items: ['All', 'A', 'B', 'C', 'D', 'F']
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text('Grade: $g',
                                  style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _filterGrade = v ?? 'All'),
                    borderRadius: BorderRadius.circular(10),
                    style: const TextStyle(
                        color: Color(0xFF1A237E), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          Container(
            color: const Color(0xFF1A237E).withOpacity(0.05),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                const SizedBox(
                    width: 40,
                    child: Text('#',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Color(0xFF5C6BC0)))),
                Expanded(
                  flex: 3,
                  child: _SortHeader(
                    label: 'Student Name',
                    col: 'name',
                    current: _sortBy,
                    asc: _ascending,
                    onTap: _toggleSort,
                  ),
                ),
                Expanded(
                  child: _SortHeader(
                    label: 'Marks',
                    col: 'marks',
                    current: _sortBy,
                    asc: _ascending,
                    onTap: _toggleSort,
                    center: true,
                  ),
                ),
                Expanded(
                  child: _SortHeader(
                    label: 'Grade',
                    col: 'grade',
                    current: _sortBy,
                    asc: _ascending,
                    onTap: _toggleSort,
                    center: true,
                  ),
                ),
              ],
            ),
          ),

          // Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: students.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
            itemBuilder: (context, index) {
              final student = students[index];
              return _StudentRow(
                index: index,
                student: student,
              );
            },
          ),

          if (students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('No students match the filter.',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SortHeader extends StatelessWidget {
  final String label;
  final String col;
  final String current;
  final bool asc;
  final void Function(String) onTap;
  final bool center;

  const _SortHeader({
    required this.label,
    required this.col,
    required this.current,
    required this.asc,
    required this.onTap,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == col;
    return GestureDetector(
      onTap: () => onTap(col),
      child: Row(
        mainAxisAlignment:
            center ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isActive
                  ? const Color(0xFF1A237E)
                  : const Color(0xFF5C6BC0),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 2),
            Icon(
              asc ? Icons.arrow_upward : Icons.arrow_downward,
              size: 12,
              color: const Color(0xFF1A237E),
            ),
          ],
        ],
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  final int index;
  final Student student;

  const _StudentRow({required this.index, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: index.isEven ? Colors.white : const Color(0xFFFAFAFF),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${index + 1}',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              student.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                student.marks % 1 == 0
                    ? student.marks.toInt().toString()
                    : student.marks.toStringAsFixed(1),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: student.gradeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: student.gradeColor.withOpacity(0.4)),
                ),
                child: Text(
                  student.grade,
                  style: TextStyle(
                    color: student.gradeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

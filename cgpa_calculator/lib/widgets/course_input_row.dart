import 'package:flutter/material.dart';
import '../utils/grade_map.dart';

class CourseInputRow extends StatelessWidget {
  final TextEditingController courseController;
  final TextEditingController creditController;
  final String? selectedGrade;
  final Function(String?) onGradeChanged;

  const CourseInputRow({
    super.key,
    required this.courseController,
    required this.creditController,
    required this.selectedGrade,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2, // make course wider
            child: TextField(
              controller: courseController,
              decoration: const InputDecoration(
                labelText: "Course",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1, // make credit narrower
            child: TextField(
              controller: creditController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Credit",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2, // keep grade somewhere in the middle or as before
            child: DropdownButtonFormField<String>(
              value: selectedGrade,
              items:
                  gradeToPoint.keys.map((grade) {
                    return DropdownMenuItem(value: grade, child: Text(grade));
                  }).toList(),
              onChanged: onGradeChanged,
              decoration: InputDecoration(
                labelText: "Grade",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.indigo[50],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

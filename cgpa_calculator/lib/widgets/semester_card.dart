import 'package:flutter/material.dart';
import 'course_input_row.dart';

class SemesterCard extends StatelessWidget {
  final int semesterIndex;
  final List<TextEditingController> courseControllers;
  final List<TextEditingController> creditControllers;
  final List<String?> selectedGrades;
  final double? semesterCGPA;
  final VoidCallback onAddCourse;
  final Function(int, int, String?) onGradeChanged;

  const SemesterCard({
    super.key,
    required this.semesterIndex,
    required this.courseControllers,
    required this.creditControllers,
    required this.selectedGrades,
    required this.semesterCGPA,
    required this.onAddCourse,
    required this.onGradeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Semester ${semesterIndex + 1}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(courseControllers.length, (index) {
              return CourseInputRow(
                courseController: courseControllers[index],
                creditController: creditControllers[index],
                selectedGrade: selectedGrades[index],
                onGradeChanged:
                    (val) => onGradeChanged(semesterIndex, index, val),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onAddCourse,
                icon: const Icon(Icons.add),
                label: const Text("Add Course"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (semesterCGPA != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  "Semester CGPA: ${semesterCGPA!.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color.fromRGBO(114, 74, 0, 1.0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

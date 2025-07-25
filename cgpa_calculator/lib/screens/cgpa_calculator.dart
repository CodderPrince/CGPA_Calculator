import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../utils/grade_map.dart';
import '../widgets/semester_card.dart';

class CGPACalculator extends StatefulWidget {
  const CGPACalculator({super.key});

  @override
  State<CGPACalculator> createState() => _CGPACalculatorState();
}

class _CGPACalculatorState extends State<CGPACalculator> {
  List<List<TextEditingController>> courseControllers = [[]];
  List<List<TextEditingController>> creditControllers = [[]];
  List<List<String?>> selectedGrades = [[]];
  List<double?> semesterCGPAs = [];

  @override
  void initState() {
    super.initState();
    courseControllers = [
      [TextEditingController()],
    ];
    creditControllers = [
      [TextEditingController()],
    ];
    selectedGrades = [
      [null],
    ];
    semesterCGPAs = [null];
    attachListeners();
  }

  void attachListeners() {
    for (int s = 0; s < courseControllers.length; s++) {
      for (int i = 0; i < courseControllers[s].length; i++) {
        creditControllers[s][i].addListener(calculateCGPA);
        courseControllers[s][i].addListener(calculateCGPA);
      }
    }
  }

  void addSemester() {
    setState(() {
      courseControllers.add([TextEditingController()]);
      creditControllers.add([TextEditingController()]);
      selectedGrades.add([null]);
      semesterCGPAs.add(null);
      attachListeners(); //
    });
  }

  void addCourse(int semesterIndex) {
    setState(() {
      courseControllers[semesterIndex].add(TextEditingController());
      creditControllers[semesterIndex].add(TextEditingController());
      selectedGrades[semesterIndex].add(null);
      attachListeners();
    });
  }

  void onGradeChanged(int semIndex, int courseIndex, String? value) {
    setState(() {
      selectedGrades[semIndex][courseIndex] = value;
    });
    calculateCGPA();
  }

  void calculateCGPA() {
    for (int s = 0; s < courseControllers.length; s++) {
      double semesterPoints = 0;
      double semesterCredits = 0;
      bool hasValidCourse = false;
      bool incompleteRowExists = false;

      for (int i = 0; i < courseControllers[s].length; i++) {
        final course = courseControllers[s][i].text.trim();
        final creditText = creditControllers[s][i].text.trim();
        final grade = selectedGrades[s][i];

        if (course.isEmpty && creditText.isEmpty && grade == null) {
          continue;
        }

        if (course.isEmpty || creditText.isEmpty || grade == null) {
          incompleteRowExists = true;
          continue;
        }

        final credit = double.tryParse(creditText) ?? 0;
        final gradePoint = gradeToPoint[grade] ?? 0;
        semesterCredits += credit;
        semesterPoints += credit * gradePoint;
        hasValidCourse = true;
      }

      if (!hasValidCourse) {
        semesterCGPAs[s] = null;
      } else if (incompleteRowExists) {
      } else {
        semesterCGPAs[s] = semesterPoints / semesterCredits;
      }

      if (semesterCGPAs[s] != null) {}
    }

    setState(() {});
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: pw.EdgeInsets.all(24),
          buildBackground: (pw.Context context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Container(
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  begin: pw.Alignment.topCenter,
                  end: pw.Alignment.bottomCenter,
                  colors: [
                    PdfColors.white,
                    PdfColor.fromHex('#FFFDE7'), // yellow.shade50
                  ],
                ),
              ),
            ),
          ),
        ),
        build: (pw.Context context) {
          List<pw.Widget> content = [];

          double totalGradePoints = 0;
          double totalCredits = 0;

          for (int s = 0; s < courseControllers.length; s++) {
            content.add(
              pw.Container(
                padding: pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Text(
                  'Semester ${s + 1}',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
              ),
            );

            final List<List<String>> semesterData = [];

            double semesterPoints = 0;
            double semesterCredits = 0;
            bool hasValidCourse = false;
            bool incompleteRowExists = false;

            for (int i = 0; i < courseControllers[s].length; i++) {
              final course = courseControllers[s][i].text.trim();
              final creditText = creditControllers[s][i].text.trim();
              final grade = selectedGrades[s][i];

              if (course.isEmpty && creditText.isEmpty && grade == null) {
                continue;
              }

              if (course.isEmpty || creditText.isEmpty || grade == null) {
                incompleteRowExists = true;
                continue;
              }

              final credit = double.tryParse(creditText);
              if (credit == null) continue;

              final gradePoint = gradeToPoint[grade] ?? 0;

              semesterCredits += credit;
              semesterPoints += credit * gradePoint;
              hasValidCourse = true;

              semesterData.add([course, creditText, grade]);
            }

            content.add(
              pw.Table.fromTextArray(
                headers: ['Course', 'Credit', 'Grade'],
                data: semesterData,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 18,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.indigo,
                ),
                cellStyle: pw.TextStyle(
                  color: PdfColors.black,
                  fontSize: 16,
                  //fontWeight: pw.FontWeight.bold,
                ),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                },
                border: pw.TableBorder.all(
                  color: PdfColors.green200,
                  width: 0.5,
                ),
              ),
            );

            content.add(pw.SizedBox(height: 8));

            String semesterCGPAText;

            if (!hasValidCourse) {
              semesterCGPAText = 'N/A';
            } else if (incompleteRowExists) {
              semesterCGPAText =
              semesterCGPAs[s] != null ? semesterCGPAs[s]!.toStringAsFixed(2) : 'N/A';
            } else {
              semesterCGPAText = (semesterPoints / semesterCredits).toStringAsFixed(2);
              semesterCGPAs[s] = semesterPoints / semesterCredits;
            }

            content.add(
              pw.Text(
                'Semester CGPA: $semesterCGPAText',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurpleAccent,
                ),
              ),
            );

            content.add(pw.Divider(thickness: 1.5, color: PdfColors.green200));
            content.add(pw.SizedBox(height: 12));

            if (semesterCGPAText != 'N/A') {
              totalGradePoints += semesterPoints;
              totalCredits += semesterCredits;
            }
          }

          final overallCGPA =
          totalCredits == 0 ? 'N/A' : (totalGradePoints / totalCredits).toStringAsFixed(2);

          content.add(
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 12),
              child: pw.Text(
                'Overall CGPA: $overallCGPA',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
            ),
          );

          return content;
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }



  @override
  void dispose() {
    for (var controllers in [...courseControllers, ...creditControllers]) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf,
              size: 35,
              color: Color.fromRGBO(157, 1, 1, 1.0),
              semanticLabel: 'Generate PDF',
              weight: 12,
            ),
            onPressed: () {
              calculateCGPA();
              generatePDF();
            },
          ),
        ],
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cast_for_education, color: Colors.teal, size: 28),
            SizedBox(width: 8),
            ShaderMask(
              shaderCallback:
                  (bounds) => LinearGradient(
                    colors: [Colors.blue, Colors.purple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Text(
                "CGPA Calculator",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...List.generate(courseControllers.length, (semesterIndex) {
              return SemesterCard(
                semesterIndex: semesterIndex,
                courseControllers: courseControllers[semesterIndex],
                creditControllers: creditControllers[semesterIndex],
                selectedGrades: selectedGrades[semesterIndex],
                semesterCGPA: semesterCGPAs[semesterIndex],
                onAddCourse: () => addCourse(semesterIndex),
                onGradeChanged: onGradeChanged,
              );
            }),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: addSemester,
              icon: const Icon(Icons.add_box),
              label: const Text(
                "Add Semester",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            // ElevatedButton.icon(
            //   onPressed: calculateCGPA,
            //   icon: const Icon(Icons.calculate),
            //   label: const Text("Calculate CGPAs"),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.teal,
            //     foregroundColor: Colors.white,
            //     padding: const EdgeInsets.symmetric(vertical: 14),
            //     textStyle: const TextStyle(fontSize: 16),
            //   ),
            // ),
            const SizedBox(height: 20),
            if (semesterCGPAs.any((cgpa) => cgpa != null))
              Center(
                child: Text(
                  "Overall CGPA: ${(() {
                    double totalPoints = 0;
                    double totalCredits = 0;
                    for (int s = 0; s < courseControllers.length; s++) {
                      for (int i = 0; i < courseControllers[s].length; i++) {
                        final creditText = creditControllers[s][i].text.trim();
                        final grade = selectedGrades[s][i];
                        if (creditText.isEmpty || grade == null) continue;

                        final credit = double.tryParse(creditText);
                        if (credit == null) continue;

                        final gradePoint = gradeToPoint[grade] ?? 0;
                        totalCredits += credit;
                        totalPoints += credit * gradePoint;
                      }
                    }
                    return totalCredits == 0 ? 'N/A' : (totalPoints / totalCredits).toStringAsFixed(2);
                  })()}",
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

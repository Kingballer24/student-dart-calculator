# 🎓 Student Grade Calculator — Flutter App

A beautiful Flutter application that reads an Excel file of student names and marks,
displays their grades with a summary dashboard, and exports a formatted grade report.

---

## 📱 Features

- **Upload Excel (.xlsx / .xls)** — auto-detects Name and Marks columns
- **Live Results Dashboard** — shows all students with color-coded grades
- **Summary Statistics** — average, highest, lowest marks + grade distribution bar
- **Sortable & Filterable Table** — sort by name, marks, or grade; filter by grade
- **Export Grade Report** — generates a beautifully formatted Excel file saved to Downloads
- **Input Validation** — handles missing data, out-of-range marks, and parse errors

---

## 🎨 Grading System

| Grade | Mark Range |
|-------|------------|
| **A** | ≥ 80       |
| **B** | 70 – 79    |
| **C** | 60 – 69    |
| **D** | 50 – 59    |
| **F** | < 50       |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.10.0
- Dart SDK ≥ 3.0.0
- Android Studio / Xcode (for mobile) or Chrome (for web)

### Install & Run

```bash
# 1. Navigate to the project
cd student_grade_calculator

# 2. Install dependencies
flutter pub get

# 3. Run on Android
flutter run

# 4. Run on Web (no file save, but upload + view works)
flutter run -d chrome

# 5. Build APK
flutter build apk --release
```

---

## 📂 Excel File Format

Your input file should have two columns. The app auto-detects them:

| Student Name   | Marks |
|---------------|-------|
| Alice Johnson  | 92    |
| Bob Smith      | 75    |

- Column headers should contain "name"/"student" and "mark"/"score"
- If no headers, first column = name, second column = marks
- Marks should be between 0 and 100

A **sample file** (`sample_students.xlsx`) is included for testing.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point & theme
├── models/
│   └── student.dart             # Student data model + grade logic
├── screens/
│   └── home_screen.dart         # Main UI screen
├── services/
│   └── excel_service.dart       # Excel read/write + file saving
└── widgets/
    ├── upload_zone.dart          # File upload button
    ├── grading_legend.dart       # Grade system display
    ├── grade_summary_card.dart   # Stats + distribution chart
    └── student_table.dart        # Sortable/filterable results table
```

---

## 📦 Dependencies

| Package            | Purpose                          |
|--------------------|----------------------------------|
| `file_picker`      | Pick Excel files from device     |
| `excel`            | Read & write .xlsx files         |
| `path_provider`    | Get Downloads directory path     |
| `google_fonts`     | Inter font family                |
| `flutter_animate`  | Smooth UI animations             |
| `gap`              | Spacing utility                  |

---

## 🛠️ Customisation

- **Add more grades**: Edit `_calculateGrade()` in `lib/models/student.dart`
- **Change output format**: Modify `generateGradeReport()` in `lib/services/excel_service.dart`
- **Add charts**: The `recharts`-style data is already prepared in `GradeSummaryCard`

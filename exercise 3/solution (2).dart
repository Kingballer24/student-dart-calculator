class Person {
  final String name;
  final int age;

  Person(this.name, this.age);
}

void main() {
  final people = [
    Person("Alice", 25),
    Person("Bob", 30),
    Person("Charlie", 35),
    Person("Anna", 22),
    Person("Ben", 28),
  ];

  // Step 1: Filter people whose name starts with 'A' or 'B'
  final filtered = people
      .where((p) => p.name.startsWith('A') || p.name.startsWith('B'))
      .toList();

  // Step 2 & 3: Extract ages and calculate average
  final ages = filtered.map((p) => p.age).toList();
  final average = ages.reduce((a, b) => a + b) / ages.length;

  // Step 4: Format and print
  print(average.toStringAsFixed(1));
}

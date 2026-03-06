// Exercise 1: Build Your Own Higher-Order Function
// processList takes a list of integers and a predicate (Int) -> Boolean,
// and returns a new list containing only the elements that satisfy the predicate.

List<int> processList(List<int> numbers, bool Function(int) predicate) {
  List<int> result = [];
  for (int number in numbers) {
    if (predicate(number)) {
      result.add(number);
    }
  }
  return result;
}

void main() {
  // Test: filter even numbers
  List<int> nums = [1, 2, 3, 4, 5, 6];
  List<int> even = processList(nums, (it) => it % 2 == 0);
  print('Even numbers: $even'); // [2, 4, 6]

  // Extra tests
  List<int> greaterThanThree = processList(nums, (it) => it > 3);
  print('Greater than 3: $greaterThanThree'); // [4, 5, 6]

  List<int> odd = processList(nums, (it) => it % 2 != 0);
  print('Odd numbers: $odd'); // [1, 3, 5]
}

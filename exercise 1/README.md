# Exercise 1: Build Your Own Higher-Order Function

## Solution: `process_list.dart`

### What it does
`processList` is a higher-order function that:
- Takes a `List<int>` and a predicate function `(int) -> bool`
- Returns a new list with only the elements that satisfy the predicate

### How to run
```bash
dart run process_list.dart
```

### Expected Output
```
Even numbers: [2, 4, 6]
Greater than 3: [4, 5, 6]
Odd numbers: [1, 3, 5]
```

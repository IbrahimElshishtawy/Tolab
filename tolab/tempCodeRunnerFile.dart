import 'dart:io';

void main() {

  // Question 1: task one 

  stdout.write("Enter product name: ");
  String name = stdin.readLineSync()!;

  stdout.write("Enter product price: ");
  double price = double.parse(stdin.readLineSync()!);

  stdout.write("Enter product quantity: ");
  int quantity = int.parse(stdin.readLineSync()!);

  stdout.write("Is the product available? (yes/no): ");
  String availableInput = stdin.readLineSync()!;
  bool isAvailable = availableInput.toLowerCase() == 'yes';

  stdout.write("Enter product manufacture year: ");
  int year = int.parse(stdin.readLineSync()!);

  print("\n---Resuilt Product---");
  print("Name: $name");
  print("Price: \$${price.toStringAsFixed(2)}");
  print("Quantity: $quantity");
  print("Available: ${isAvailable ? 'Yes' : 'No'}");
  print("Year: $year");

//-------------------------------------------------------------


  // Explanation of var vs dynamic
  String varDynamicExplanation = '''Difference between `var` and `dynamic` in Dart:
 var:
 The type is set automatically by Dart at compile time.
 Once the type is set, it cannot change.
 Safer and faster.
dynamic:
The type is flexible and can change at runtime.
Useful when the type is not known in advance''';


  String finalConstExplanation = '''Difference between `final` and `const` in Dart:
final:
Can be set only once.
Value is assigned at runtime.
Good for values that won't change after being set.
const:
Must be known at compile time.
Used for fixed values''';

  var x = 10;      
  dynamic y = 5;   
  y = "Hi";  
  //       ------------------------
  final n = "Ibrahim";   
  const pi = 3.14; 
  
  print(varDynamicExplanation);
  print("Value of x: $x");
  print("Value of y: $y");

  print(finalConstExplanation);
  print("Final name: $n");
  print("Constant pi: $pi");
//-------------------------------------------------------------


  List<String> fruits = ["Apple", "Banana", "Orange"];
  print("\nOriginal List: $fruits");


  fruits.add("Mango");
  print("After adding: $fruits");

 
  fruits.remove("Banana");
  print("After removing: $fruits");


  fruits[0] = "Pineapple";
  print("After editing: $fruits");


//-------------------------------------------------------------

  List<int> numbers = [];
  numbers.add(7);
  numbers.add(3);
  numbers.add(9);
  numbers.add(1);
  numbers.add(5);
  
  print(numbers);
 
  numbers.removeAt(0);
  print(numbers);
  
  numbers.removeLast();
  print(numbers);
  print("Remaining numbers: $numbers");

  List<String> students = [];
  students.addAll(["ibrahim", "khaled", "Elshish8tawy"]);
     
    print(students);
   
  students.removeAt(1);
  print(students);


  print(students.length);


  print("Contains 'Ali'? ${students.contains('Ali')}");
  print("Contains 'Lina'? ${students.contains('Lina')}");

//------------------------------------------------------

    
  List<int> nums = [10, 20, 30, 40, 50];

  print("\nUsing for loop:");
  for (int i = 0; i < nums.length; i++) {
    print(nums[i]);
  }

  print("\nUsing forEach:");
  nums.forEach((num) {
    print("Current value is: $num");
  });
}

import '../models/deck.dart';
import '../theme/app_theme.dart';

List<Deck> buildSampleDecks() => [
  Deck(
    id: 'data-structures',
    title: 'Data Structures',
    iconName: 'tree',
    color: AppColors.deckPalette[3],
    cards: [
      const Flashcard(
        question: 'Which data structure follows LIFO order?',
        answer: 'Stack',
      ),
      const Flashcard(
        question: 'Which data structure follows FIFO order?',
        answer: 'Queue',
      ),
      const Flashcard(
        question: 'Time complexity of binary search?',
        answer: 'O(log n)',
      ),
      const Flashcard(
        question: 'Average lookup time in a hash table?',
        answer: 'O(1)',
      ),
      const Flashcard(
        question: 'Worst-case time complexity of quicksort?',
        answer: 'O(n²)',
      ),
      const Flashcard(
        question: 'Which graph traversal uses a queue?',
        answer: 'Breadth-first search',
      ),
      const Flashcard(
        question: 'A complete binary tree where every parent is ≥ its children',
        answer: 'Max heap',
      ),
    ],
  ),
  Deck(
    id: 'oop',
    title: 'Object-Oriented Programming',
    iconName: 'puzzle',
    color: AppColors.deckPalette[2],
    cards: [
      const Flashcard(
        question: 'Bundling data and the methods that use it into one unit',
        answer: 'Encapsulation',
      ),
      const Flashcard(
        question: 'One interface, many implementations',
        answer: 'Polymorphism',
      ),
      const Flashcard(
        question: 'A class acquiring the properties of another class',
        answer: 'Inheritance',
      ),
      const Flashcard(
        question: 'Showing only essential details and hiding the rest',
        answer: 'Abstraction',
      ),
      const Flashcard(
        question: 'Same method name, different parameters, same class',
        answer: 'Method overloading',
      ),
      const Flashcard(
        question: 'A subclass redefining a method from its parent',
        answer: 'Method overriding',
      ),
    ],
  ),
  Deck(
    id: 'networking',
    title: 'Computer Networks',
    iconName: 'network',
    color: AppColors.deckPalette[0],
    cards: [
      const Flashcard(
        question: 'How many layers does the OSI model have?',
        answer: '7',
      ),
      const Flashcard(question: 'Default port for HTTPS?', answer: '443'),
      const Flashcard(
        question: 'Which protocol turns domain names into IP addresses?',
        answer: 'DNS',
      ),
      const Flashcard(
        question: 'Which transport protocol is connection-oriented?',
        answer: 'TCP',
      ),
      const Flashcard(
        question: 'How many bits are in an IPv4 address?',
        answer: '32',
      ),
      const Flashcard(
        question: 'Which OSI layer do routers work at?',
        answer: 'Network layer',
      ),
    ],
  ),
  Deck(
    id: 'dbms',
    title: 'Databases',
    iconName: 'storage',
    color: AppColors.deckPalette[1],
    cards: [
      const Flashcard(
        question: 'A column that uniquely identifies each row',
        answer: 'Primary key',
      ),
      const Flashcard(
        question: 'A column that references a primary key in another table',
        answer: 'Foreign key',
      ),
      const Flashcard(
        question: 'What does the A in ACID stand for?',
        answer: 'Atomicity',
      ),
      const Flashcard(
        question: 'SQL command that removes a whole table',
        answer: 'DROP TABLE',
      ),
      const Flashcard(
        question: 'Organizing tables to reduce redundancy',
        answer: 'Normalization',
      ),
      const Flashcard(
        question: 'JOIN that returns only matching rows from both tables',
        answer: 'INNER JOIN',
      ),
    ],
  ),
  Deck(
    id: 'general',
    title: 'General Knowledge',
    iconName: 'globe',
    color: AppColors.deckPalette[4],
    cards: [
      const Flashcard(
        question: 'What is the capital of Japan?',
        answer: 'Tokyo',
      ),
      const Flashcard(
        question: 'Which planet is known as the Red Planet?',
        answer: 'Mars',
      ),
      const Flashcard(question: 'What is 12 × 12?', answer: '144'),
      const Flashcard(
        question: 'Who wrote "Romeo and Juliet"?',
        answer: 'William Shakespeare',
      ),
      const Flashcard(
        question: 'What is the largest ocean on Earth?',
        answer: 'Pacific Ocean',
      ),
    ],
  ),
];

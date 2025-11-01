import 'package:isar/isar.dart';

part 'word.g.dart';

@collection
class Word {
  Id id = Isar.autoIncrement;
  late String engWord;
  late String trWord;
  late String wordType;
  String? story;
  List<int>? imageBytes;
  bool isLearned = false;

  Word({
    required this.engWord,
    required this.trWord,
    required this.wordType,
    this.story,
    this.imageBytes,
    this.isLearned = false,
  });

  @override
  String toString() {
    return 'Word{engWord: $engWord, trWord: $trWord, wordType: $wordType, story: $story, imageBytes: $imageBytes, isLearned: $isLearned}';
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_words_app/models/word.dart';
import 'package:flutter_words_app/services/isar_service.dart';

class WordList extends StatefulWidget {
  final IsarService isarService;
  final Function(Word) onEditWord;

  const WordList({
    super.key,
    required this.isarService,
    required this.onEditWord,
  });

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  late Future<List<Word>> _getAllWords;
  List<Word> _words = [];
  List<Word> _filteredWords = [];
  List<String> wordTypes = [
    'hepsi',
    'isim',
    'fiil',
    'sıfat',
    'zarf',
    'zamir',
    'edat',
    'bağlaç',
    'ünlem',
  ];

  String _selectedWordType = 'hepsi';
  bool _showLearnedWords = false;

  _applyFilters() {
    _filteredWords = List.from(_words);
    if (_selectedWordType != 'hepsi') {
      _filteredWords = _filteredWords
          .where((e) => e.wordType == _selectedWordType)
          .toList();
    }

    if (_showLearnedWords) {
      _filteredWords = _filteredWords
          .where((e) => e.isLearned != _showLearnedWords)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _getAllWords = _getWordsFromIsar();
  }

  Widget _buildFilterCard() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.filter_alt_rounded),
                SizedBox(width: 10),
                Text("Filtrele"),
                SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Kelime Türü",
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedWordType,
                    items: wordTypes
                        .map((e) => DropdownMenuItem(child: Text(e), value: e))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedWordType = value!;
                        _applyFilters();
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _showLearnedWords
                    ? Text("Öğrenilenleri Gizle")
                    : Text("Öğrenilenleri Göster"),
                Switch(
                  value: _showLearnedWords,
                  onChanged: (value) {
                    setState(() {
                      _showLearnedWords = !_showLearnedWords;
                      _applyFilters();
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Word>> _getWordsFromIsar() async {
    var dbFromWords = await widget.isarService.getAllWords();
    _words = dbFromWords;
    return dbFromWords;
  }

  void _deleteWord(Word word) async {
    await widget.isarService.deleteWord(word.id);
    _words.removeWhere((e) => e.id == word.id);
    debugPrint("Kelimelerin sayısı: ${_words.length}");
  }

  // void _refreshWords() {
  //   setState(() {
  //     _getAllWords = _getWordsFromIsar();
  //   });
  // }

  void _toggleUpdateWord(Word word) async {
    await widget.isarService.toggleWordLearned(word.id);
    final index = _words.indexWhere((e) => e.id == word.id);
    var updatedWord = _words[index];
    updatedWord.isLearned = !updatedWord.isLearned;
    setState(() {
      _words[index] = updatedWord;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildFilterCard(),
        Expanded(
          child: FutureBuilder(
            future: _getAllWords,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Bir hata oluştu: ${snapshot.error.toString()}"),
                );
              } else if (snapshot.hasData) {
                return snapshot.data!.length == 0
                    ? Center(child: Text("Kelime ekleyin"))
                    : _buildListView(snapshot.data!);
              } else {
                return SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }

  _buildListView(List<Word>? data) {
    _applyFilters();
    debugPrint("Kelimelerin sayısı: ${_filteredWords.length}");
    return ListView.builder(
      itemBuilder: (context, index) {
        var word = _filteredWords[index];
        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          background: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(
              Icons.delete_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
          ),
          onDismissed: (direction) => _deleteWord(word),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Kelimeyi sil"),
                  content: Text(
                    "${word.engWord} kelimesini silmek istediğinize emin misiniz?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text("İptal"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text("Sil"),
                    ),
                  ],
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
            child: GestureDetector(
              onTap: () => widget.onEditWord(word),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 8.0,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(word.engWord),
                        subtitle: Text(word.trWord),
                        leading: Chip(label: Text(word.wordType)),
                        trailing: Switch(
                          value: word.isLearned,
                          onChanged: (value) => _toggleUpdateWord(word),
                        ),
                      ),
                      if (word.story != null && word.story!.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 20),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb,
                                    color: word.isLearned
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text("Hatırlatıcı Not"),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  word.story ?? "",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (word.imageBytes != null)
                        Image.memory(
                          Uint8List.fromList(word.imageBytes!),
                          height: 120,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: _filteredWords.length,
    );
  }
}

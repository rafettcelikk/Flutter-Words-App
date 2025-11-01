import 'package:flutter/material.dart';
import 'package:flutter_words_app/models/word.dart';
import 'package:flutter_words_app/screens/add_word_screen.dart';
import 'package:flutter_words_app/screens/word_list_screen.dart';
import 'package:flutter_words_app/services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isarService = IsarService();
  try {
    await isarService.init();

    // await isarService.clearDatabase();

    final words = await isarService.getAllWords();
    debugPrint(words.toString());
  } catch (e) {
    debugPrint("Uygulama başlatılırken hata oluştu: $e");
  }
  runApp(MyApp(isarService: isarService));
}

class MyApp extends StatelessWidget {
  final IsarService isarService;
  const MyApp({super.key, required this.isarService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kelimeler Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MainPage(isarService: isarService),
    );
  }
}

class MainPage extends StatefulWidget {
  final IsarService isarService;
  const MainPage({super.key, required this.isarService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedScreen = 0;
  Word? _wordToEdit;

  void _editWord(Word word) {
    setState(() {
      _selectedScreen = 1;
      _wordToEdit = word;
    });
  }

  @override
  void dispose() {
    widget.isarService.closeDatabase();
    super.dispose();
  }

  List<Widget> getScreen() {
    return [
      WordList(isarService: widget.isarService, onEditWord: _editWord),
      AddWord(
        isarService: widget.isarService,
        wordToEdit: _wordToEdit,
        onSave: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: _wordToEdit == null
                  ? Text("Kelime başarıyla eklendi!")
                  : Text("Kelime başarıyla güncellendi!"),
              duration: Duration(seconds: 2),
            ),
          );
          setState(() {
            _selectedScreen = 0;
            _wordToEdit = null;
          });
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Kelimeler Uygulaması"),
        backgroundColor: Colors.amber.shade200,
      ),
      body: getScreen()[_selectedScreen],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedScreen,
        destinations: [
          NavigationDestination(icon: Icon(Icons.list), label: "Kelimeler"),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: _wordToEdit == null ? "Ekle" : "Düzenle",
          ),
        ],
        onDestinationSelected: (int value) {
          setState(() {
            _selectedScreen = value;
            _wordToEdit = null;
          });
        },
      ),
    );
  }
}

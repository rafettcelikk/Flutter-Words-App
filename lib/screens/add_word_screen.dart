import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_words_app/models/word.dart';
import 'package:flutter_words_app/services/isar_service.dart';
import 'package:image_picker/image_picker.dart';

class AddWord extends StatefulWidget {
  final IsarService isarService;
  final VoidCallback onSave;
  final Word? wordToEdit;
  const AddWord({
    super.key,
    required this.isarService,
    required this.onSave,
    this.wordToEdit,
  });

  @override
  State<AddWord> createState() => _AddWordState();
}

class _AddWordState extends State<AddWord> {
  final _formKey = GlobalKey<FormState>();
  final _engController = TextEditingController();
  final _trController = TextEditingController();
  final _storyController = TextEditingController();
  String _selectedWordType = 'isim';
  bool _isLearned = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  List<String> wordTypes = [
    'isim',
    'fiil',
    'sıfat',
    'zarf',
    'zamir',
    'edat',
    'bağlaç',
    'ünlem',
  ];

  @override
  void dispose() {
    super.dispose();
    _engController.dispose();
    _trController.dispose();
    _storyController.dispose();
  }

  Future<void> _selectPhoto() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.wordToEdit != null) {
      var updatedWord = widget.wordToEdit!;
      _engController.text = updatedWord.engWord;
      _trController.text = updatedWord.trWord;
      _storyController.text = updatedWord.story!;
      _selectedWordType = updatedWord.wordType;
      _isLearned = updatedWord.isLearned;
    }
  }

  void _saveWord() async {
    if (_formKey.currentState!.validate()) {
      var _engWord = _engController.text;
      var _trWord = _trController.text;
      var _story = _storyController.text;
      var _word = Word(
        engWord: _engWord,
        trWord: _trWord,
        wordType: _selectedWordType,
        story: _story,
        isLearned: _isLearned,
      );
      if (widget.wordToEdit == null) {
        _word.imageBytes = _selectedImage != null
            ? await _selectedImage!.readAsBytes()
            : null;
        await widget.isarService.saveWord(_word);
      } else {
        _word.id = widget.wordToEdit!.id;
        _word.imageBytes = _selectedImage != null
            ? await _selectedImage!.readAsBytes()
            : widget.wordToEdit!.imageBytes;
        await widget.isarService.updateWord(_word);
      }
      widget.onSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Lütfen İngilizce kelimeyi girin";
                }
                return null;
              },
              controller: _engController,
              decoration: InputDecoration(
                labelText: "İngilizce Kelime",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Lütfen Türkçe kelimeyi girin";
                }
                return null;
              },
              controller: _trController,
              decoration: InputDecoration(
                labelText: "Türkçe Kelime",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedWordType,
              decoration: InputDecoration(
                labelText: "Kelime Türü",
                border: OutlineInputBorder(),
              ),
              items: wordTypes.map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedWordType = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _storyController,
              decoration: InputDecoration(
                labelText: "Hikaye",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text("Öğrenildi"),
                Switch(
                  value: _isLearned,
                  onChanged: (value) {
                    setState(() {
                      _isLearned = !_isLearned;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _selectPhoto,
              label: Text("Fotoğraf Ekle"),
              icon: Icon(Icons.photo),
            ),
            SizedBox(height: 16),
            if (_selectedImage != null ||
                widget.wordToEdit?.imageBytes == null) ...[
              if (_selectedImage != null)
                Image.file(_selectedImage!, height: 150, fit: BoxFit.cover)
              else if (widget.wordToEdit?.imageBytes != null)
                Image.memory(
                  Uint8List.fromList(widget.wordToEdit!.imageBytes!),
                  height: 150,
                  fit: BoxFit.cover,
                ),
            ],
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveWord,
              child: widget.wordToEdit == null
                  ? Text("Kelime Ekle")
                  : Text("Kelime Güncelle"),
            ),
          ],
        ),
      ),
    );
  }
}

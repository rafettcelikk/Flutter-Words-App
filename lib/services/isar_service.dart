import 'package:flutter/material.dart';
import 'package:flutter_words_app/models/word.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  late Isar isar;

  Future<void> init() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      isar = await Isar.open(
        [WordSchema],
        directory: directory.path,
        inspector: true, // Inspector için
      );
      debugPrint("Isar başarıyla başlatıldı. Dizin: ${directory.path}");
    } catch (e) {
      debugPrint("Isar başlatılırken hata oluştu: $e");
    }
  }

  Future<void> saveWord(Word word) async {
    try {
      await isar.writeTxn(() async {
        final id = await isar.words.put(word);
        debugPrint("İngilizce kelime kaydedildi: ${word.engWord}, ID: $id");
      });
    } catch (e) {
      debugPrint("Kelime kaydedilirken hata oluştu: $e");
    }
  }

  Future<List<Word>> getAllWords() async {
    try {
      final words = await isar.words.where().findAll();
      debugPrint("Tüm kelimeler alındı. Toplam: ${words.length}");
      return words;
    } catch (e) {
      debugPrint("Kelime alınırken hata oluştu: $e");
      return [];
    }
  }

  Future<void> deleteWord(int id) async {
    try {
      await isar.writeTxn(() async {
        await isar.words.delete(id);
        debugPrint("Kelime silindi. ID: $id");
      });
    } catch (e) {
      debugPrint("Kelime silinirken hata oluştu: $e");
    }
  }

  Future<void> updateWord(Word word) async {
    try {
      await isar.writeTxn(() async {
        final id = await isar.words.put(word);
        debugPrint("${word.engWord} güncellendi. ID: $id");
      });
    } catch (e) {
      debugPrint("Kelime güncellenirken hata oluştu: $e");
    }
  }

  Future<void> toggleWordLearned(int id) async {
    try {
      await isar.writeTxn(() async {
        final word = await isar.words.get(id);
        if (word != null) {
          word.isLearned = !word.isLearned;
          await isar.words.put(word);
          debugPrint("${word.engWord} öğrenildi durumu: ${word.isLearned}");
        } else {
          debugPrint("ID'si $id olan kelime bulunamadı.");
        }
      });
    } catch (e) {
      debugPrint("Öğrenildi durumu güncellenirken hata oluştu: $e");
    }
  }

  Future<void> clearDatabase() async {
    try {
      await isar.writeTxn(() async {
        await isar.clear(); // tüm collection’ları temizler
      });
      debugPrint("Veritabanı başarıyla temizlendi.");
    } catch (e) {
      debugPrint("Veritabanı temizlenirken hata oluştu: $e");
    }
  }

  Future<void> closeDatabase() async {
    try {
      await isar.close();
      debugPrint("Isar kapatıldı.");
    } catch (e) {
      debugPrint("Isar kapatılırken hata oluştu: $e");
    }
  }
}

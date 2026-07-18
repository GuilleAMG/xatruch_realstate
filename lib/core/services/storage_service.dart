// Servicio de almacenamiento.
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ──── Subida de multimedia Firebase Storage ─────────────────────────────────────────────

  Future<String> uploadFile(File file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error al subir archivo: $e');
      rethrow;
    }
  }

  Future<List<String>> uploadPropertyMedia(
    List<File> files,
    String propertyId,
  ) async {
    final List<String> downloadUrls = [];
    for (int i = 0; i < files.length; i++) {
      final extension = files[i].path.split('.').last;
      final storagePath =
          'propiedades/$propertyId/${DateTime.now().millisecondsSinceEpoch}_$i.$extension';
      final url = await uploadFile(files[i], storagePath);
      downloadUrls.add(url);
    }
    return downloadUrls;
  }

  Future<String> uploadChatMedia(File file, String chatId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final storagePath = 'chats/$chatId/${timestamp}_media.$extension';
    return await uploadFile(file, storagePath);
  }
}

final storageService = StorageService();
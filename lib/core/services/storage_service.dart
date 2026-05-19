// Servicio de almacenamiento: sube archivos multimedia a Firebase Storage
// para propiedades y chats, y retorna las URLs de descarga.
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─────────────────────────────────────────────
  //  Firebase Storage (Subida de multimedia)
  // ─────────────────────────────────────────────

  /// Sube un archivo individual a Firebase Storage y retorna la URL de descarga.
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

  /// Sube múltiples archivos multimedia de una propiedad y retorna sus URLs de descarga.
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

  /// Sube un archivo multimedia para un chat y retorna la URL de descarga.
  Future<String> uploadChatMedia(File file, String chatId) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.path.split('.').last;
    final storagePath = 'chats/$chatId/${timestamp}_media.$extension';
    return await uploadFile(file, storagePath);
  }
}

final storageService = StorageService();

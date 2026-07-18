// Servicio de reportes.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:xatruch_realstate/features/support/data/report.dart';
import 'package:xatruch_realstate/core/services/auth_service.dart';

class ReportService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> submitReport({
    required String reportedId,
    String? reportedUserId,
    required String reportType,
    required String reason,
    required String description,
  }) async {
    try {
      final user = authService.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final report = Report(
        id: '', 
        reporterId: user.uid,
        reportedId: reportedId,
        reportedUserId: reportedUserId,
        reportType: reportType,
        reason: reason,
        description: description,
        createdAt: DateTime.now(),
      );

      await _db.collection('reportes').add(report.toMap());
      return true;
    } catch (e) {
      debugPrint('Error al enviar reporte: $e');
      return false;
    }
  }
}

final reportService = ReportService();
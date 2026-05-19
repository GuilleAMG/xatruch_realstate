// Modelo de datos de reporte: define la clase Report con los campos
// necesarios para reportar contenido o usuarios.
class Report {
  Report({
    required this.id,
    required this.reporterId,
    required this.reportedId,
    this.reportedUserId,
    required this.reportType,
    required this.reason,
    required this.description,
    required this.createdAt,
    this.status = 'pending',
  });

  factory Report.fromMap(Map<String, dynamic> map, String docId) {
    return Report(
      id: docId,
      reporterId: (map['reporterId'] as String?) ?? '',
      reportedId: (map['reportedId'] as String?) ?? '',
      reportedUserId: map['reportedUserId'] as String?,
      reportType: (map['reportType'] as String?) ?? '',
      reason: (map['reason'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      status: (map['status'] as String?) ?? 'pending',
    );
  }

  final String id;
  final String reporterId;
  final String reportedId;
  final String? reportedUserId;
  final String reportType; // 'property', 'message', 'user'
  final String reason;
  final String description;
  final DateTime createdAt;
  final String status; // 'pending', 'reviewed', 'resolved'

  Map<String, dynamic> toMap() {
    return {
      'reporterId': reporterId,
      'reportedId': reportedId,
      'reportedUserId': reportedUserId,
      'reportType': reportType,
      'reason': reason,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}

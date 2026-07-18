// Diálogo de reportes.
import 'package:flutter/material.dart';
import 'package:xatruch_realstate/core/services/report_service.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.reportedId,
    this.reportedUserId,
    required this.reportType,
  });

  final String reportedId;
  final String? reportedUserId;
  final String reportType;

  static Future<void> show(
    BuildContext context, {
    required String reportedId,
    String? reportedUserId,
    required String reportType,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReportDialog(
          reportedId: reportedId,
          reportedUserId: reportedUserId,
          reportType: reportType,
        ),
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? _selectedReason;
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Fraude o Estafa',
    'Contenido Inapropiado u Ofensivo',
    'Spam',
    'Información Falsa',
    'Otro',
  ];

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, selecciona un motivo.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_selectedReason == 'Otro' &&
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor, describe el motivo del reporte.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final success = await reportService.submitReport(
      reportedId: widget.reportedId,
      reportedUserId: widget.reportedUserId,
      reportType: widget.reportType,
      reason: _selectedReason!,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Reporte enviado. Nuestro equipo lo revisará pronto.'
              : 'Error al enviar el reporte. Inténtalo de nuevo.',
        ),
        backgroundColor: success
            ? Colors.green
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reportar',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ayúdanos a mantener una comunidad segura. Selecciona el motivo del reporte:',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _reasons
                .map(
                  (reason) => ChoiceChip(
                    label: Text(reason),
                    selected: _selectedReason == reason,
                    selectedColor: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: _selectedReason == reason
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: _selectedReason == reason
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: _selectedReason == reason
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedReason = reason;
                        });
                      }
                    },
                  ),
                )
                .toList(),
          ),
          if (_selectedReason == 'Otro') ...[
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Describe el problema',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onError,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('ENVIAR REPORTE'),
            ),
          ),
        ],
      ),
    );
  }
}
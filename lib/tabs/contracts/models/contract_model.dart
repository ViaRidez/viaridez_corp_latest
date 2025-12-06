import 'dart:typed_data';

class ContractModel {
  final String clientName;
  final Uint8List pdfData;
  final int fileSize;
  final DateTime fetchedAt;

  ContractModel({
    required this.clientName,
    required this.pdfData,
    required this.fileSize,
    required this.fetchedAt,
  });

  /// Get file size in human readable format
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Check if PDF data is valid
  bool get isValidPdf {
    if (pdfData.isEmpty) return false;

    // Check PDF header signature
    final header = String.fromCharCodes(pdfData.take(4));
    return header == '%PDF';
  }

  @override
  String toString() {
    return 'ContractModel(clientName: $clientName, fileSize: $fileSizeFormatted, fetchedAt: $fetchedAt)';
  }
}

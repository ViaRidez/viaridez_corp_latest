class TripSummary {
  final String tripType;
  final int count;
  final double totalPrice;

  TripSummary({
    required this.tripType,
    required this.count,
    required this.totalPrice,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      tripType: json['tripType'] ?? '',
      count: json['count'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tripType': tripType,
    'count': count,
    'totalPrice': totalPrice,
  };
}

class InvoicingModel {
  final String clientName;
  final List<int> startDate;
  final List<int> endDate;
  final List<TripSummary> tripSummaries;
  final double grandTotal;

  InvoicingModel({
    required this.clientName,
    required this.startDate,
    required this.endDate,
    required this.tripSummaries,
    required this.grandTotal,
  });

  factory InvoicingModel.fromJson(Map<String, dynamic> json) {
    return InvoicingModel(
      clientName: json['clientName'] ?? '',
      startDate: List<int>.from(json['startDate'] ?? []),
      endDate: List<int>.from(json['endDate'] ?? []),
      tripSummaries: (json['tripSummaries'] as List<dynamic>?)
          ?.map((item) => TripSummary.fromJson(item))
          .toList() ??
          [],
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'startDate': startDate,
    'endDate': endDate,
    'tripSummaries': tripSummaries.map((e) => e.toJson()).toList(),
    'grandTotal': grandTotal,
  };

  DateTime get startDateTime => startDate.length >= 3
      ? DateTime(startDate[0], startDate[1], startDate[2])
      : DateTime.now();

  DateTime get endDateTime => endDate.length >= 3
      ? DateTime(endDate[0], endDate[1], endDate[2])
      : DateTime.now();

  String get formattedStartDate => startDate.length >= 3
      ? "${startDate[0]}-${startDate[1].toString().padLeft(2, '0')}-${startDate[2].toString().padLeft(2, '0')}"
      : '';

  String get formattedEndDate => endDate.length >= 3
      ? "${endDate[0]}-${endDate[1].toString().padLeft(2, '0')}-${endDate[2].toString().padLeft(2, '0')}"
      : '';
}

/// Model for the response returned by /trip/generate-and-save.
/// Contains invoice persistence details such as [invoiceNumber] and [status].
class SavedInvoiceModel {
  final int id;
  final String invoiceNumber;
  final String clientName;
  final List<int> startDate;
  final List<int> endDate;
  final List<int> generatedAt;
  final double grandTotal;
  final String status;
  final String paymentMethod;
  final String paymentType;
  final bool paymentComplete;
  final double amountPaid;
  final String paymentGateway;

  SavedInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.clientName,
    required this.startDate,
    required this.endDate,
    required this.generatedAt,
    required this.grandTotal,
    required this.status,
    required this.paymentMethod,
    required this.paymentType,
    required this.paymentComplete,
    required this.amountPaid,
    required this.paymentGateway,
  });

  factory SavedInvoiceModel.fromJson(Map<String, dynamic> json) {
    return SavedInvoiceModel(
      id: json['id'] ?? 0,
      invoiceNumber: json['invoiceNumber'] ?? '',
      clientName: json['clientName'] ?? '',
      startDate: List<int>.from(json['startDate'] ?? []),
      endDate: List<int>.from(json['endDate'] ?? []),
      generatedAt: List<int>.from(json['generatedAt'] ?? []),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      // API key has a typo ("payMentMethod") — handle both spellings defensively.
      paymentMethod:
      (json['payMentMethod'] ?? json['paymentMethod'] ?? '') as String,
      paymentType: json['paymentType'] ?? '',
      paymentComplete: json['paymentComplete'] ?? false,
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      paymentGateway: json['paymentGateway'] ?? '',
    );
  }

  // ── Formatted helpers ──────────────────────────────────────────────────────

  String _pad(int v) => v.toString().padLeft(2, '0');

  String get formattedStartDate => startDate.length >= 3
      ? "${startDate[0]}-${_pad(startDate[1])}-${_pad(startDate[2])}"
      : '';

  String get formattedEndDate => endDate.length >= 3
      ? "${endDate[0]}-${_pad(endDate[1])}-${_pad(endDate[2])}"
      : '';

  /// Human-readable timestamp of when the invoice was generated.
  String get formattedGeneratedAt {
    if (generatedAt.length < 6) return '';
    final y = generatedAt[0];
    final mo = _pad(generatedAt[1]);
    final d = _pad(generatedAt[2]);
    final h = _pad(generatedAt[3]);
    final mi = _pad(generatedAt[4]);
    return "$y-$mo-$d $h:$mi";
  }
}
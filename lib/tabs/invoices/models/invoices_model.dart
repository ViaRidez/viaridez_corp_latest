class InvoiceModel {
  final int id;
  final String? booking;
  final int tripId;
  final String? passengerName;
  final String? passengerEmail;
  final String? phoneNumber;
  final String? pickupStop;
  final String? dropStop;
  final int seatsBooked;
  final double? pricePerSeat;
  final double? totalPrice;
  final String? tripRoute;
  final String? tripStartTime; // stored as formatted string after parsing
  final String? tripEndTime;   // stored as formatted string after parsing
  final String? generatedAt;
  final String clientName;
  final List<int> startDate;
  final List<int> endDate;
  final double grandTotal;
  final String? airportTransfer;
  final String paymentMethod;
  final String paymentType;
  final bool onlinePayment;
  final bool cashPayment;
  final bool paymentComplete;
  final String? shuttleBookingGroupId;
  final String? invoiceNumber;
  final String? status;
  final String? bookingDetails;
  final double amountPaid;
  final String paymentGateway;
  final String? orderId;
  final String? paymentSignature;
  final String? bookingGroupId;

  InvoiceModel({
    required this.id,
    this.booking,
    required this.tripId,
    this.passengerName,
    this.passengerEmail,
    this.phoneNumber,
    this.pickupStop,
    this.dropStop,
    required this.seatsBooked,
    this.pricePerSeat,
    this.totalPrice,
    this.tripRoute,
    this.tripStartTime,
    this.tripEndTime,
    this.generatedAt,
    required this.clientName,
    required this.startDate,
    required this.endDate,
    required this.grandTotal,
    this.airportTransfer,
    required this.paymentMethod,
    required this.paymentType,
    required this.onlinePayment,
    required this.cashPayment,
    required this.paymentComplete,
    this.shuttleBookingGroupId,
    this.invoiceNumber,
    this.status,
    this.bookingDetails,
    required this.amountPaid,
    required this.paymentGateway,
    this.orderId,
    this.paymentSignature,
    this.bookingGroupId,
  });

  // ── Datetime array → String converter ────────────────────────────────────
  //
  // The API returns datetime values as integer arrays in two shapes:
  //   • [year, month, day, hour, minute]               – trip start/end times
  //   • [year, month, day, hour, minute, sec, nanos]   – generatedAt
  //
  // This helper handles both shapes (and plain strings for future-proofing).
  static String? _parseDateTimeArray(dynamic raw) {
    if (raw == null) return null;

    // Already a string (forward-compatible).
    if (raw is String) return raw.isEmpty ? null : raw;

    // Must be a List with at least 5 elements to form a useful datetime.
    if (raw is! List || raw.length < 5) return null;

    String pad(dynamic v) => (v as int).toString().padLeft(2, '0');

    final y  = raw[0];
    final mo = pad(raw[1]);
    final d  = pad(raw[2]);
    final h  = pad(raw[3]);
    final mi = pad(raw[4]);

    // Include seconds when present (generatedAt has at least 6 elements).
    if (raw.length >= 6) {
      final s = pad(raw[5]);
      return '$y-$mo-$d $h:$mi:$s';
    }

    return '$y-$mo-$d $h:$mi';
  }

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? 0,
      booking: json['booking'],
      tripId: json['tripId'] ?? 0,
      passengerName: json['passengerName'],
      passengerEmail: json['passengerEmail'],
      phoneNumber: json['phoneNumber'],
      pickupStop: json['pickupStop'],
      dropStop: json['dropStop'],
      seatsBooked: json['seatsBooked'] ?? 0,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      tripRoute: json['tripRoute'],

      // ── Fixed: these fields arrive as int arrays, not strings ────────────
      tripStartTime: _parseDateTimeArray(json['tripStartTime']),
      tripEndTime: _parseDateTimeArray(json['tripEndTime']),
      generatedAt: _parseDateTimeArray(json['generatedAt']),

      clientName: json['clientName'] ?? '',
      startDate: List<int>.from(json['startDate'] ?? []),
      endDate: List<int>.from(json['endDate'] ?? []),
      grandTotal: (json['grandTotal'] as num? ?? 0).toDouble(),

      // API has a known typo: 'airpotTransfer'
      airportTransfer: json['airpotTransfer'] ?? json['airportTransfer'],

      // API has a known typo: 'payMentMethod'
      paymentMethod: json['payMentMethod'] ?? json['paymentMethod'] ?? 'Pending',
      paymentType: json['paymentType'] ?? 'Not Paid',
      onlinePayment: json['onlinePayment'] ?? false,
      cashPayment: json['cashPayment'] ?? false,
      paymentComplete: json['paymentComplete'] ?? false,
      shuttleBookingGroupId: json['shuttleBookingGroupId'],
      invoiceNumber: json['invoiceNumber'],
      status: json['status'],
      bookingDetails: json['bookingDetails'],

      // amountPaid and paymentGateway are nullable in some records.
      amountPaid: (json['amountPaid'] as num? ?? 0).toDouble(),
      paymentGateway: json['paymentGateway'] ?? 'N/A',
      orderId: json['orderId'],
      paymentSignature: json['paymentSignature'],
      bookingGroupId: json['bookingGroupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking': booking,
      'tripId': tripId,
      'passengerName': passengerName,
      'passengerEmail': passengerEmail,
      'phoneNumber': phoneNumber,
      'pickupStop': pickupStop,
      'dropStop': dropStop,
      'seatsBooked': seatsBooked,
      'pricePerSeat': pricePerSeat,
      'totalPrice': totalPrice,
      'tripRoute': tripRoute,
      'tripStartTime': tripStartTime,
      'tripEndTime': tripEndTime,
      'generatedAt': generatedAt,
      'clientName': clientName,
      'startDate': startDate,
      'endDate': endDate,
      'grandTotal': grandTotal,
      'airpotTransfer': airportTransfer,
      'payMentMethod': paymentMethod,
      'paymentType': paymentType,
      'onlinePayment': onlinePayment,
      'cashPayment': cashPayment,
      'paymentComplete': paymentComplete,
      'shuttleBookingGroupId': shuttleBookingGroupId,
      'invoiceNumber': invoiceNumber,
      'status': status,
      'bookingDetails': bookingDetails,
      'amountPaid': amountPaid,
      'paymentGateway': paymentGateway,
      'orderId': orderId,
      'paymentSignature': paymentSignature,
      'bookingGroupId': bookingGroupId,
    };
  }

  // ── Formatted date helpers ────────────────────────────────────────────────

  String _fmtDateParts(List<int> parts) {
    if (parts.length < 3) return 'N/A';
    return '${parts[0]}-${parts[1].toString().padLeft(2, '0')}-${parts[2].toString().padLeft(2, '0')}';
  }

  String get formattedStartDate => _fmtDateParts(startDate);
  String get formattedEndDate => _fmtDateParts(endDate);

  String get formattedGrandTotal => grandTotal.toStringAsFixed(3);
  String get formattedAmountPaid => amountPaid.toStringAsFixed(3);

  double get balanceAmount => grandTotal - amountPaid;
  String get formattedBalance => balanceAmount.toStringAsFixed(3);

  // ── Payment status helpers ────────────────────────────────────────────────

  bool get isPaid => paymentComplete;
  bool get isPartiallyPaid => amountPaid > 0 && amountPaid < grandTotal;
  bool get isPending => amountPaid == 0;
}
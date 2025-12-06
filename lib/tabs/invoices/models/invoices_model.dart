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
  final String? tripStartTime;
  final String? tripEndTime;
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

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    // Parse generatedAt array to string
    String? parsedGeneratedAt;
    if (json['generatedAt'] != null && json['generatedAt'] is List) {
      final dateArray = json['generatedAt'] as List;
      if (dateArray.length >= 6) {
        // Format: [year, month, day, hour, minute, second, nanosecond]
        parsedGeneratedAt =
            '${dateArray[0]}-${dateArray[1].toString().padLeft(2, '0')}-${dateArray[2].toString().padLeft(2, '0')} ${dateArray[3].toString().padLeft(2, '0')}:${dateArray[4].toString().padLeft(2, '0')}:${dateArray[5].toString().padLeft(2, '0')}';
      }
    } else {
      parsedGeneratedAt = json['generatedAt']?.toString();
    }

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
      pricePerSeat: json['pricePerSeat']?.toDouble(),
      totalPrice: json['totalPrice']?.toDouble(),
      tripRoute: json['tripRoute'],
      tripStartTime: json['tripStartTime'],
      tripEndTime: json['tripEndTime'],
      generatedAt: parsedGeneratedAt,
      clientName: json['clientName'] ?? '',
      startDate: List<int>.from(json['startDate'] ?? []),
      endDate: List<int>.from(json['endDate'] ?? []),
      grandTotal: (json['grandTotal'] ?? 0.0).toDouble(),
      airportTransfer:
          json['airpotTransfer'], // Note: API has typo 'airpotTransfer'
      paymentMethod: json['payMentMethod'] ?? 'Pending',
      paymentType: json['paymentType'] ?? 'Not Paid',
      onlinePayment: json['onlinePayment'] ?? false,
      cashPayment: json['cashPayment'] ?? false,
      paymentComplete: json['paymentComplete'] ?? false,
      shuttleBookingGroupId: json['shuttleBookingGroupId'],
      invoiceNumber: json['invoiceNumber'],
      status: json['status'],
      bookingDetails: json['bookingDetails'],
      amountPaid: (json['amountPaid'] ?? 0.0).toDouble(),
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

  // Helper methods for formatted dates
  String get formattedStartDate {
    if (startDate.length >= 3) {
      return '${startDate[0]}-${startDate[1].toString().padLeft(2, '0')}-${startDate[2].toString().padLeft(2, '0')}';
    }
    return 'N/A';
  }

  String get formattedEndDate {
    if (endDate.length >= 3) {
      return '${endDate[0]}-${endDate[1].toString().padLeft(2, '0')}-${endDate[2].toString().padLeft(2, '0')}';
    }
    return 'N/A';
  }

  String get formattedGrandTotal {
    return grandTotal.toStringAsFixed(3);
  }

  String get formattedAmountPaid {
    return amountPaid.toStringAsFixed(3);
  }

  double get balanceAmount {
    return grandTotal - amountPaid;
  }

  String get formattedBalance {
    return balanceAmount.toStringAsFixed(3);
  }

  // Payment status helpers
  bool get isPaid => paymentComplete;
  bool get isPartiallyPaid => amountPaid > 0 && amountPaid < grandTotal;
  bool get isPending => amountPaid == 0;
}

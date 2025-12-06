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

  Map<String, dynamic> toJson() {
    return {
      'tripType': tripType,
      'count': count,
      'totalPrice': totalPrice,
    };
  }
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

  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'startDate': startDate,
      'endDate': endDate,
      'tripSummaries': tripSummaries.map((item) => item.toJson()).toList(),
      'grandTotal': grandTotal,
    };
  }

  // Helper methods to get formatted dates
  DateTime get startDateTime {
    if (startDate.length >= 3) {
      return DateTime(startDate[0], startDate[1], startDate[2]);
    }
    return DateTime.now();
  }

  DateTime get endDateTime {
    if (endDate.length >= 3) {
      return DateTime(endDate[0], endDate[1], endDate[2]);
    }
    return DateTime.now();
  }

  String get formattedStartDate {
    return "${startDate[0]}-${startDate[1].toString().padLeft(2, '0')}-${startDate[2].toString().padLeft(2, '0')}";
  }

  String get formattedEndDate {
    return "${endDate[0]}-${endDate[1].toString().padLeft(2, '0')}-${endDate[2].toString().padLeft(2, '0')}";
  }
}
class Currency {
  final String code;
  final String symbol;
  final String name;
  final double exchangeRate;

  Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.exchangeRate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchangeRate: (json['exchangeRate'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'symbol': symbol,
      'name': name,
      'exchangeRate': exchangeRate,
    };
  }
}

class Client {
  final int clientId;
  final String clientName;
  final String clientType;
  final String accountManager;
  final String phoneNumber;
  final String address;
  final String state;
  final String city;

  Client({
    required this.clientId,
    required this.clientName,
    required this.clientType,
    required this.accountManager,
    required this.phoneNumber,
    required this.address,
    required this.state,
    required this.city,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      clientId: json['clientId'] ?? 0,
      clientName: json['clientName'] ?? '',
      clientType: json['clientType'] ?? '',
      accountManager: json['accountManager'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'clientType': clientType,
      'accountManager': accountManager,
      'phoneNumber': phoneNumber,
      'address': address,
      'state': state,
      'city': city,
    };
  }
}

class RoutePrice {
  final int? routeId;
  final String? startLocation;
  final String? endLocation;
  final double effectiveDistanceKm;
  final double? customDistanceKm;
  final double totalAdjustedCost;
  final double finalPrice;

  // Additional pricing details (hidden from UI but available for calculations)
  final double communicationCost;
  final double deviceDepreciationCost;
  final double fleetDepreciationCost;
  final double registrationCost;
  final double insuranceCost;
  final double manpowerCost;
  final double itCost;
  final double fuelCostPerLtr;
  final double repairMaintenanceCostPerKm;
  final double tyreCostPerKm;
  final int operatingDaysPerMonth;
  final int tripsPerDay;
  final double deadMileagePercentage;
  final double taxPercentage;
  final double driverUtilization;
  final double vehicleUtilization;
  final double profitMargin;

  RoutePrice({
    this.routeId,
    this.startLocation,
    this.endLocation,
    required this.effectiveDistanceKm,
    this.customDistanceKm,
    required this.totalAdjustedCost,
    required this.finalPrice,
    required this.communicationCost,
    required this.deviceDepreciationCost,
    required this.fleetDepreciationCost,
    required this.registrationCost,
    required this.insuranceCost,
    required this.manpowerCost,
    required this.itCost,
    required this.fuelCostPerLtr,
    required this.repairMaintenanceCostPerKm,
    required this.tyreCostPerKm,
    required this.operatingDaysPerMonth,
    required this.tripsPerDay,
    required this.deadMileagePercentage,
    required this.taxPercentage,
    required this.driverUtilization,
    required this.vehicleUtilization,
    required this.profitMargin,
  });

  factory RoutePrice.fromJson(Map<String, dynamic> json) {
    return RoutePrice(
      routeId: json['routeId'],
      startLocation: json['startLocation'],
      endLocation: json['endLocation'],
      effectiveDistanceKm: (json['effectiveDistanceKm'] ?? 0).toDouble(),
      customDistanceKm: json['customDistanceKm']?.toDouble(),
      totalAdjustedCost: (json['totalAdjustedCost'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      communicationCost: (json['communicationCost'] ?? 0).toDouble(),
      deviceDepreciationCost: (json['deviceDepreciationCost'] ?? 0).toDouble(),
      fleetDepreciationCost: (json['fleetDepreciationCost'] ?? 0).toDouble(),
      registrationCost: (json['registrationCost'] ?? 0).toDouble(),
      insuranceCost: (json['insuranceCost'] ?? 0).toDouble(),
      manpowerCost: (json['manpowerCost'] ?? 0).toDouble(),
      itCost: (json['itCost'] ?? 0).toDouble(),
      fuelCostPerLtr: (json['fuelCostPerLtr'] ?? 0).toDouble(),
      repairMaintenanceCostPerKm:
          (json['repairMaintenanceCostPerKm'] ?? 0).toDouble(),
      tyreCostPerKm: (json['tyreCostPerKm'] ?? 0).toDouble(),
      operatingDaysPerMonth: json['operatingDaysPerMonth'] ?? 0,
      tripsPerDay: json['tripsPerDay'] ?? 0,
      deadMileagePercentage: (json['deadMileagePercentage'] ?? 0).toDouble(),
      taxPercentage: (json['taxPercentage'] ?? 0).toDouble(),
      driverUtilization: (json['driverUtilization'] ?? 0).toDouble(),
      vehicleUtilization: (json['vehicleUtilization'] ?? 0).toDouble(),
      profitMargin: (json['profitMargin'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'startLocation': startLocation,
      'endLocation': endLocation,
      'effectiveDistanceKm': effectiveDistanceKm,
      'customDistanceKm': customDistanceKm,
      'totalAdjustedCost': totalAdjustedCost,
      'finalPrice': finalPrice,
      'communicationCost': communicationCost,
      'deviceDepreciationCost': deviceDepreciationCost,
      'fleetDepreciationCost': fleetDepreciationCost,
      'registrationCost': registrationCost,
      'insuranceCost': insuranceCost,
      'manpowerCost': manpowerCost,
      'itCost': itCost,
      'fuelCostPerLtr': fuelCostPerLtr,
      'repairMaintenanceCostPerKm': repairMaintenanceCostPerKm,
      'tyreCostPerKm': tyreCostPerKm,
      'operatingDaysPerMonth': operatingDaysPerMonth,
      'tripsPerDay': tripsPerDay,
      'deadMileagePercentage': deadMileagePercentage,
      'taxPercentage': taxPercentage,
      'driverUtilization': driverUtilization,
      'vehicleUtilization': vehicleUtilization,
      'profitMargin': profitMargin,
    };
  }

  // Helper getters for UI display
  String get routeDisplay {
    if (startLocation == null || endLocation == null) {
      return 'General Route';
    }
    return '${_getShortLocation(startLocation!)} → ${_getShortLocation(endLocation!)}';
  }

  String _getShortLocation(String fullLocation) {
    // Extract the first part before the comma for display
    final parts = fullLocation.split(',');
    return parts.isNotEmpty ? parts[0].trim() : fullLocation;
  }

  String get distanceDisplay {
    return '${effectiveDistanceKm.toStringAsFixed(1)} km';
  }

  String get priceDisplay {
    return finalPrice.toStringAsFixed(2);
  }
}

class Quotation {
  final String reportName;
  final String createdAt;
  final Currency currency;
  final Client client;
  final List<RoutePrice> routePrices;
  final double totalPrice;

  Quotation({
    required this.reportName,
    required this.createdAt,
    required this.currency,
    required this.client,
    required this.routePrices,
    required this.totalPrice,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
      reportName: json['reportName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      currency: Currency.fromJson(json['currency'] ?? {}),
      client: Client.fromJson(json['client'] ?? {}),
      routePrices: (json['routePrices'] as List<dynamic>? ?? [])
          .map((route) => RoutePrice.fromJson(route))
          .toList(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportName': reportName,
      'createdAt': createdAt,
      'currency': currency.toJson(),
      'client': client.toJson(),
      'routePrices': routePrices.map((route) => route.toJson()).toList(),
      'totalPrice': totalPrice,
    };
  }

  // Helper getters for UI display
  String get formattedCreatedAt {
    try {
      final dateTime = DateTime.parse(createdAt.replaceAll(' ', 'T'));
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return createdAt;
    }
  }

  String get formattedTotalPrice {
    return '${currency.symbol} ${totalPrice.toStringAsFixed(2)}';
  }

  int get routeCount {
    return routePrices.where((route) => route.routeId != null).length;
  }

  List<RoutePrice> get validRoutes {
    return routePrices.where((route) => route.routeId != null).toList();
  }
}

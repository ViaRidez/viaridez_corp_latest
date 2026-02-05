import 'package:dio/dio.dart';
import 'package:viaridez_corp/config/app_config.dart';
import '../models/invoices_model.dart';
import '../../../auth/api/secure_tokens.dart';

class InvoicesService {
  static final Dio _dio = Dio();

  // Get invoices for a specific client using client name from secure storage
  static Future<List<InvoiceModel>> getClientInvoices() async {
    try {
      // Fetch client name from secure storage
      final clientName = await getClientName();

      if (clientName == null || clientName.isEmpty) {
        throw Exception('Client name not found in secure storage');
      }

      print(
          'InvoicesService: Making API call to ${AppConfig.apiBaseUrl}/trip/client/invoice/$clientName');

      final response =
          await _dio.get('${AppConfig.apiBaseUrl}/trip/client/invoice/$clientName');

      print(
          'InvoicesService: Received response with status code: ${response.statusCode}');
      print(
          'InvoicesService: Response data type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Handle different response types
        if (response.data is String) {
          // API returns a string message when no invoices found
          print('InvoicesService: No invoices found - ${response.data}');
          return [];
        }

        if (response.data is Map<String, dynamic>) {
          // API returns a map with data field
          final mapData = response.data as Map<String, dynamic>;
          if (mapData.containsKey('data') && mapData['data'] is List) {
            final List<dynamic> invoicesJson = mapData['data'];
            return invoicesJson
                .map((json) => InvoiceModel.fromJson(json))
                .toList();
          }
          // No data field or empty
          return [];
        }

        if (response.data is List) {
          final List<dynamic> invoicesJson = response.data;
          print(
              'InvoicesService: Parsing ${invoicesJson.length} invoice records for client: $clientName');

          if (invoicesJson.isEmpty) {
            return [];
          }

          final invoices =
              invoicesJson.map((json) => InvoiceModel.fromJson(json)).toList();

          print(
              'InvoicesService: Successfully parsed ${invoices.length} invoices');
          return invoices;
        }

        // Unknown response format
        return [];
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('InvoicesService: DioException occurred: ${e.toString()}');
      if (e.response != null) {
        print('InvoicesService: Response data: ${e.response?.data}');
        print('InvoicesService: Response status: ${e.response?.statusCode}');
      }
      throw Exception(
          'Failed to load invoices: ${e.response?.statusMessage ?? e.toString()}');
    } catch (e) {
      print('InvoicesService: Exception occurred: $e');
      throw Exception('Failed to load invoices: $e');
    }
  }

  // Get invoices by date range
  static Future<List<InvoiceModel>> getInvoicesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final allInvoices = await getClientInvoices();
      return allInvoices.where((invoice) {
        if (invoice.startDate.length < 3 || invoice.endDate.length < 3) {
          return false;
        }

        final invoiceStart = DateTime(
          invoice.startDate[0],
          invoice.startDate[1],
          invoice.startDate[2],
        );
        final invoiceEnd = DateTime(
          invoice.endDate[0],
          invoice.endDate[1],
          invoice.endDate[2],
        );

        // Check if invoice date range overlaps with requested range
        return invoiceStart.isBefore(endDate) && invoiceEnd.isAfter(startDate);
      }).toList();
    } catch (e) {
      throw Exception('Failed to load invoices by date range: $e');
    }
  }

  // Get invoices by payment status
  static Future<List<InvoiceModel>> getInvoicesByPaymentStatus({
    bool? isPaid,
    bool? isPartiallyPaid,
    bool? isPending,
  }) async {
    try {
      final allInvoices = await getClientInvoices();
      return allInvoices.where((invoice) {
        if (isPaid == true && invoice.isPaid) return true;
        if (isPartiallyPaid == true && invoice.isPartiallyPaid) return true;
        if (isPending == true && invoice.isPending) return true;
        return false;
      }).toList();
    } catch (e) {
      throw Exception('Failed to load invoices by payment status: $e');
    }
  }

  // Get invoice by ID
  static Future<InvoiceModel?> getInvoiceById(int id) async {
    try {
      final allInvoices = await getClientInvoices();
      return allInvoices.firstWhere(
        (invoice) => invoice.id == id,
        orElse: () => throw Exception('Invoice not found'),
      );
    } catch (e) {
      throw Exception('Failed to load invoice by ID: $e');
    }
  }
}

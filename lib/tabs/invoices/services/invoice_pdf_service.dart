import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/invoices_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class InvoicePdfService {
  /// Generates a PDF document for the given invoice
  static Future<Uint8List> generateInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document();

    // Define colors matching your app's style
    final primaryColor = PdfColor.fromInt(0xFF1a237e);
    final secondaryColor = PdfColor.fromInt(0xFF0288d1);
    final successColor = PdfColor.fromInt(0xFF4caf50);
    final errorColor = PdfColor.fromInt(0xFFf44336);
    final mutedColor = PdfColor.fromInt(0xFF9e9e9e);

    // Determine status color
    final statusColor = invoice.isPaid ? successColor : errorColor;
    final statusText = invoice.isPaid ? 'PAID' : 'PENDING';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          _buildHeader(invoice, primaryColor, secondaryColor),
          pw.SizedBox(height: 30),

          // Status Badge
          pw.Center(
            child: pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: pw.BoxDecoration(
                color: statusColor.flatten(),
                borderRadius: pw.BorderRadius.circular(20),
              ),
              child: pw.Text(
                statusText,
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
          pw.SizedBox(height: 30),

          // Client Information Section
          _buildSection(
            'CLIENT INFORMATION',
            [
              _buildInfoRow('Client Name:', invoice.clientName),
              _buildInfoRow('Invoice Number:', invoice.invoiceNumber ?? 'N/A'),
              _buildInfoRow('Status:', invoice.status ?? 'N/A'),
              if (invoice.booking != null)
                _buildInfoRow('Booking ID:', invoice.booking!),
            ],
            primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Trip Information Section
          _buildSection(
            'TRIP INFORMATION',
            [
              _buildInfoRow('Trip ID:', invoice.tripId.toString()),
              if (invoice.tripRoute != null)
                _buildInfoRow('Route:', invoice.tripRoute!),
              if (invoice.pickupStop != null)
                _buildInfoRow('Pickup:', invoice.pickupStop!),
              if (invoice.dropStop != null)
                _buildInfoRow('Drop:', invoice.dropStop!),
              _buildInfoRow('Seats Booked:', invoice.seatsBooked.toString()),
              if (invoice.pricePerSeat != null)
                _buildInfoRow('Price/Seat:',
                    '${invoice.pricePerSeat!.toStringAsFixed(3)} KWD'),
            ],
            primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Passenger Information Section (if available)
          if (invoice.passengerName != null ||
              invoice.passengerEmail != null ||
              invoice.phoneNumber != null)
            _buildSection(
              'PASSENGER INFORMATION',
              [
                if (invoice.passengerName != null)
                  _buildInfoRow('Name:', invoice.passengerName!),
                if (invoice.passengerEmail != null)
                  _buildInfoRow('Email:', invoice.passengerEmail!),
                if (invoice.phoneNumber != null)
                  _buildInfoRow('Phone:', invoice.phoneNumber!),
              ],
              primaryColor,
            ),

          if (invoice.passengerName != null ||
              invoice.passengerEmail != null ||
              invoice.phoneNumber != null)
            pw.SizedBox(height: 20),

          // Date Information Section
          _buildSection(
            'DATE INFORMATION',
            [
              _buildInfoRow('Start Date:', invoice.formattedStartDate),
              _buildInfoRow('End Date:', invoice.formattedEndDate),
              if (invoice.tripStartTime != null)
                _buildInfoRow('Trip Start Time:', invoice.tripStartTime!),
              if (invoice.tripEndTime != null)
                _buildInfoRow('Trip End Time:', invoice.tripEndTime!),
              if (invoice.generatedAt != null)
                _buildInfoRow('Generated At:', invoice.generatedAt!),
            ],
            primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Financial Summary Table
          _buildFinancialSummary(
              invoice, primaryColor, successColor, errorColor),
          pw.SizedBox(height: 20),

          // Payment Details Section
          _buildSection(
            'PAYMENT DETAILS',
            [
              _buildInfoRow('Payment Method:', invoice.paymentMethod),
              _buildInfoRow('Payment Gateway:', invoice.paymentGateway),
              _buildInfoRow('Payment Type:', invoice.paymentType),
              _buildInfoRow(
                  'Online Payment:', invoice.onlinePayment ? 'Yes' : 'No'),
              _buildInfoRow(
                  'Cash Payment:', invoice.cashPayment ? 'Yes' : 'No'),
              _buildInfoRow(
                  'Payment Complete:', invoice.paymentComplete ? 'Yes' : 'No'),
              if (invoice.orderId != null)
                _buildInfoRow('Order ID:', invoice.orderId!),
            ],
            primaryColor,
          ),
          pw.SizedBox(height: 20),

          // Additional Information Section (if available)
          if (invoice.airportTransfer != null ||
              invoice.shuttleBookingGroupId != null ||
              invoice.bookingGroupId != null ||
              invoice.bookingDetails != null)
            _buildSection(
              'ADDITIONAL INFORMATION',
              [
                if (invoice.airportTransfer != null)
                  _buildInfoRow('Airport Transfer:', invoice.airportTransfer!),
                if (invoice.shuttleBookingGroupId != null)
                  _buildInfoRow(
                      'Shuttle Group ID:', invoice.shuttleBookingGroupId!),
                if (invoice.bookingGroupId != null)
                  _buildInfoRow('Booking Group ID:', invoice.bookingGroupId!),
                if (invoice.bookingDetails != null)
                  _buildInfoRow('Booking Details:', invoice.bookingDetails!),
              ],
              primaryColor,
            ),

          pw.SizedBox(height: 40),

          // Footer
          pw.Divider(color: mutedColor),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Thank you for your business!',
              style: pw.TextStyle(
                fontSize: 12,
                color: mutedColor,
                fontStyle: pw.FontStyle.italic,
              ),
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text(
              'Generated on ${DateTime.now().toString().split('.')[0]}',
              style: pw.TextStyle(
                fontSize: 10,
                color: mutedColor,
              ),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Builds the PDF header with logo and company info
  static pw.Widget _buildHeader(
      InvoiceModel invoice, PdfColor primaryColor, PdfColor secondaryColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: pw.Alignment.topLeft,
          end: pw.Alignment.bottomRight,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'VIARIDEZ',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'INVOICE',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Invoice #${invoice.id}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                invoice.clientName,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a section with title and content
  static pw.Widget _buildSection(
      String title, List<pw.Widget> content, PdfColor primaryColor) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor.flatten()),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: primaryColor.flatten(),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(children: content),
          ),
        ],
      ),
    );
  }

  /// Builds an information row with label and value
  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the financial summary table
  static pw.Widget _buildFinancialSummary(InvoiceModel invoice,
      PdfColor primaryColor, PdfColor successColor, PdfColor errorColor) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor.flatten()),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: primaryColor.flatten(),
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Text(
              'FINANCIAL SUMMARY',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              children: [
                if (invoice.totalPrice != null)
                  _buildFinancialRow(
                    'Trip Total:',
                    '${invoice.totalPrice!.toStringAsFixed(3)} KWD',
                    PdfColors.black,
                  ),
                if (invoice.totalPrice != null)
                  pw.Divider(color: PdfColors.grey400),
                _buildFinancialRow(
                  'Grand Total:',
                  '${invoice.formattedGrandTotal} KWD',
                  primaryColor,
                  isBold: true,
                  fontSize: 14,
                ),
                pw.Divider(color: PdfColors.grey400),
                _buildFinancialRow(
                  'Amount Paid:',
                  '${invoice.formattedAmountPaid} KWD',
                  successColor,
                  isBold: true,
                  fontSize: 13,
                ),
                _buildFinancialRow(
                  'Balance Due:',
                  '${invoice.formattedBalance} KWD',
                  invoice.isPaid ? successColor : errorColor,
                  isBold: true,
                  fontSize: 13,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a financial row with custom styling
  static pw.Widget _buildFinancialRow(
    String label,
    String value,
    PdfColor color, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: color,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: fontSize,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Downloads the PDF file
  /// For web: triggers browser download
  /// For mobile/desktop: saves to device storage
  static Future<void> downloadPdf(Uint8List pdfBytes, String filename) async {
    if (kIsWeb) {
      // Web platform - trigger browser download
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      // Mobile/Desktop platforms - use path_provider and open_file
      // Note: You'll need to import these packages in the actual implementation
      // For now, this is a placeholder for mobile/desktop implementation
      throw UnimplementedError(
          'Mobile/Desktop download not implemented. Use path_provider and open_file packages.');
    }
  }

  /// Generates and downloads invoice PDF
  static Future<void> generateAndDownloadInvoice(InvoiceModel invoice) async {
    try {
      // Generate PDF
      final pdfBytes = await generateInvoicePdf(invoice);

      // Create filename
      final filename =
          'Invoice_${invoice.id}_${invoice.clientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Download PDF
      await downloadPdf(pdfBytes, filename);
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../utils/styles.dart';
import '../../../utils/trip_type_style.dart';
import '../providers/invoicing_provider.dart';
import '../models/invoicing_model.dart';

class InvoicingView extends StatefulWidget {
  const InvoicingView({super.key});

  @override
  State<InvoicingView> createState() => _InvoicingViewState();
}

class _InvoicingViewState extends State<InvoicingView> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  String? _dateError;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    _startDateController.text = _formatDate(startDate);
    _endDateController.text = _formatDate(endDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoicingProvider>().loadClientName();
    });
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final sd = DateTime.tryParse(_startDateController.text);
    final ed = DateTime.tryParse(_endDateController.text);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller == _endDateController
          ? (ed ?? sd ?? DateTime.now())
          : (sd ?? DateTime.now()),
      firstDate: controller == _endDateController
          ? (sd ?? DateTime(2020))
          : DateTime(2020),
      lastDate: controller == _startDateController
          ? (ed ?? DateTime(2100))
          : DateTime(2100),
    );
    if (picked != null) {
      controller.text = _formatDate(picked);
      setState(() => _dateError = null);
      if (controller == _startDateController) {
        final currEd = DateTime.tryParse(_endDateController.text);
        if (currEd != null && currEd.isBefore(picked)) {
          _endDateController.text = _formatDate(picked);
        }
      }
    }
  }

  void _generateInvoice() {
    final sd = DateTime.tryParse(_startDateController.text);
    final ed = DateTime.tryParse(_endDateController.text);

    if (sd == null || ed == null) {
      setState(() => _dateError = 'Please select valid dates');
      return;
    }
    if (ed.isBefore(sd)) {
      setState(() => _dateError = "End date can't be before start date");
      return;
    }

    final provider = context.read<InvoicingProvider>();
    if (provider.clientName == null || provider.clientName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Client name not available. Please try again.')),
      );
      return;
    }

    provider.generateInvoice(
      clientName: provider.clientName,
      startDate: _startDateController.text,
      endDate: _endDateController.text,
    );
  }

  void _saveInvoice() {
    context.read<InvoicingProvider>().saveInvoice(
      startDate: _startDateController.text,
      endDate: _endDateController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.lightBackground,
      body: Consumer<InvoicingProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Input Form Card ──────────────────────────────────────
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: Styles.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Styles.primaryColor.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Invoicing",
                              style: TextStyles.pageTitle.copyWith(
                                fontSize: 28,
                                color: Styles.primaryColor,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 16),
                              height: 3,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Styles.primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(child: _buildMonthDropdown()),
                                const SizedBox(width: 12),
                                SizedBox(
                                    width: 140, child: _buildYearDropdown()),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildPresetChip(
                                    'This Month', _applyPresetThisMonth),
                                _buildPresetChip(
                                    'Last Month', _applyPresetLastMonth),
                                _buildPresetChip(
                                    'Last 30 Days', _applyPresetLast30Days),
                                _buildPresetChip('YTD', _applyPresetYTD),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Date pickers
                        Row(
                          children: [
                            Expanded(child: _buildDateField(_startDateController, 'Start Date', Icons.calendar_today_rounded, Icons.edit_calendar_rounded)),
                            const SizedBox(width: 20),
                            Expanded(child: _buildDateField(_endDateController, 'End Date', Icons.calendar_today_rounded, Icons.event_available_rounded)),
                          ],
                        ),
                        if (_dateError != null) ...[
                          const SizedBox(height: 8),
                          Text(_dateError!, style: TextStyles.errorText),
                        ],
                        const SizedBox(height: 28),
                        // Generate button
                        _buildGradientButton(
                          onPressed:
                          provider.isLoading ? null : _generateInvoice,
                          isLoading: provider.isLoading,
                          icon: Icons.auto_awesome_rounded,
                          label: 'Generate Invoice',
                          colors: [Styles.primaryColor, Styles.secondaryColor],
                          shadowColor: Styles.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Invoice Conflict Warning ─────────────────────────────
                if (provider.invoiceAlreadyExists)
                  _buildConflictWarning(provider),

                // ── Generate Error ───────────────────────────────────────
                if (provider.hasError)
                  _buildErrorBanner(
                      provider.errorMessage!, provider.clearError),

                // ── Invoice Summary ──────────────────────────────────────
                if (provider.hasData) ...[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.white, Styles.successLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Styles.successColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Styles.successColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Styles.successColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.summarize_rounded,
                                  color: Styles.successColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Invoice Summary',
                                      style: TextStyles.sectionTitle),
                                  Text(
                                    'Detailed breakdown in KWD',
                                    style: TextStyles.bodyText
                                        .copyWith(color: Styles.mutedText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSummaryRow(
                              'Client:', provider.invoiceData!.clientName),
                          _buildSummaryRow(
                            'Period:',
                            '${provider.invoiceData!.formattedStartDate} to ${provider.invoiceData!.formattedEndDate}',
                          ),
                          _buildSummaryRow(
                              'Total Trips:', provider.totalTripsCount.toString()),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Styles.successLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: Styles.successColor.withOpacity(0.3),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Styles.successColor.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildSummaryRow(
                              'Grand Total:',
                              '${provider.formattedGrandTotal} KWD',
                              isTotal: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ── Save Invoice Button ────────────────────────
                          // Hidden once the invoice has been saved successfully.
                          if (!provider.hasSavedInvoice)
                            _buildGradientButton(
                              onPressed: (provider.isSaving || provider.hasSavedInvoice)
                                  ? null
                                  : _saveInvoice,
                              isLoading: provider.isSaving,
                              icon: Icons.save_alt_rounded,
                              label: 'Save Invoice',
                              colors: [
                                const Color(0xFF1565C0),
                                const Color(0xFF1976D2),
                              ],
                              shadowColor: const Color(0xFF1565C0),
                            ),

                          // ── Save Error / Conflict ──────────────────────
                          if (provider.hasSaveError) ...[
                            const SizedBox(height: 12),
                            provider.invoiceAlreadyExists
                                ? _buildConflictWarning(provider)
                                : _buildErrorBanner(
                                provider.saveErrorMessage!,
                                provider.clearSaveError),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Saved Invoice Confirmation Card ──────────────────
                  if (provider.hasSavedInvoice)
                    _buildSavedInvoiceCard(provider.savedInvoice!),

                  const SizedBox(height: 24),

                  // ── Trip Details ─────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.white, Styles.lightBackground],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Styles.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Styles.primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.list_alt_rounded,
                                    color: Styles.primaryColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Trip Details',
                                      style: TextStyles.sectionTitle),
                                  Text(
                                    'Itemized trip breakdown',
                                    style: TextStyles.bodyText
                                        .copyWith(color: Styles.mutedText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildTripCardsGrid(provider.invoiceData!),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Loading State ────────────────────────────────────────
                if (provider.isLoading && !provider.hasData)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Styles.white, Styles.lightBackground],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Styles.primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(60.0),
                      child: Center(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Styles.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: Styles.primaryColor,
                                backgroundColor: Styles.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text('Generating invoice...',
                                style: TextStyles.sectionTitle
                                    .copyWith(fontSize: 18)),
                            const SizedBox(height: 8),
                            Text(
                              'Please wait while we process your data',
                              style: TextStyles.bodyText
                                  .copyWith(color: Styles.mutedText),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Saved Invoice Confirmation Card ──────────────────────────────────────

  Widget _buildSavedInvoiceCard(SavedInvoiceModel saved) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1976D2).withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF1565C0),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Invoice Saved', style: TextStyles.sectionTitle),
                    Text(
                      'Record persisted successfully',
                      style: TextStyles.bodyText
                          .copyWith(color: Styles.mutedText),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Invoice Number highlight box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF1565C0).withOpacity(0.25),
                    width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: Color(0xFF1565C0), size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice Number',
                          style: TextStyles.dataLabel.copyWith(
                            fontSize: 12,
                            color: const Color(0xFF1565C0).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          saved.invoiceNumber,
                          style: TextStyles.cardTitle.copyWith(
                            fontSize: 17,
                            color: const Color(0xFF1565C0),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Copy button
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: saved.invoiceNumber));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice number copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded,
                        color: Color(0xFF1565C0), size: 20),
                    tooltip: 'Copy invoice number',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details grid
            _buildSavedDetailRow(
                Icons.person_rounded, 'Client', saved.clientName),
            _buildSavedDetailRow(Icons.date_range_rounded, 'Period',
                '${saved.formattedStartDate} → ${saved.formattedEndDate}'),
            _buildSavedDetailRow(Icons.access_time_rounded, 'Generated At',
                saved.formattedGeneratedAt),
            _buildSavedDetailRow(
                Icons.payments_rounded,
                'Grand Total',
                '${saved.grandTotal.toStringAsFixed(3)} KWD'),
            _buildSavedDetailRow(
                Icons.info_outline_rounded, 'Status', saved.status),
            _buildSavedDetailRow(
                Icons.payment_rounded, 'Payment', saved.paymentType),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1565C0).withOpacity(0.6)),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyles.dataLabel.copyWith(
              fontSize: 14,
              color: Styles.textColorMed,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyles.dataValue.copyWith(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Conflict Warning Card ─────────────────────────────────────────────────

  Widget _buildConflictWarning(InvoicingProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF9A825).withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF9A825).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9A825).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice Already Exists',
                        style: TextStyles.cardTitle.copyWith(
                          color: const Color(0xFFE65100),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duplicate range detected',
                        style: TextStyles.bodyText.copyWith(
                          color: const Color(0xFFBF360C).withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: Color(0xFFE65100), size: 20),
                  onPressed: provider.clearError,
                  tooltip: 'Dismiss',
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Message
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9A825).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: const Color(0xFFF9A825).withOpacity(0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFFE65100), size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'An invoice already exists for this date range or an '
                          'overlapping period. Please choose a different date '
                          'range and try again.',
                      style: TextStyles.bodyText.copyWith(
                        color: const Color(0xFFBF360C),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Suggestion chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip(
                  icon: Icons.arrow_back_rounded,
                  label: 'Previous Month',
                  onTap: () {
                    provider.clearError;
                    _applyPresetLastMonth();
                  },
                ),
                _buildSuggestionChip(
                  icon: Icons.calendar_view_month_rounded,
                  label: 'This Month',
                  onTap: () {
                    provider.clearError;
                    _applyPresetThisMonth();
                  },
                ),
                _buildSuggestionChip(
                  icon: Icons.date_range_rounded,
                  label: 'Last 30 Days',
                  onTap: () {
                    provider.clearError;
                    _applyPresetLast30Days();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFF9A825).withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border:
          Border.all(color: const Color(0xFFF9A825).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFE65100)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyles.chipText
                  .copyWith(color: const Color(0xFFE65100), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable widgets ─────────────────────────────────────────────────────

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required IconData icon,
    required String label,
    required List<Color> colors,
    required Color shadowColor,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: onPressed == null
            ? LinearGradient(colors: [Colors.grey[400]!, Colors.grey[300]!])
            : LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed == null
            ? []
            : [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        child: isLoading
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
              strokeWidth: 2.5, color: Colors.white),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(width: 12),
            Text(label,
                style:
                TextStyles.primaryButtonText.copyWith(fontSize: 17)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField(
      TextEditingController controller,
      String label,
      IconData prefixIcon,
      IconData suffixIcon,
      ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyles.inputTextStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyles.inputLabelStyle,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Styles.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(prefixIcon, color: Styles.primaryColor, size: 18),
          ),
          suffixIcon:
          Icon(suffixIcon, color: Styles.textColorMed, size: 18),
        ),
        readOnly: true,
        onTap: () => _selectDate(context, controller),
      ),
    );
  }

  Widget _buildErrorBanner(String message, VoidCallback onDismiss) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Styles.errorLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Styles.errorColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Styles.errorColor),
            const SizedBox(width: 12),
            Expanded(
                child:
                Text(message, style: TextStyles.errorText)),
            IconButton(
              icon: Icon(Icons.close_rounded, color: Styles.errorColor),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? TextStyles.cardTitle
                : TextStyles.dataLabel
                .copyWith(fontSize: 15, color: Styles.textColorMed),
          ),
          Text(
            value,
            style: isTotal
                ? TextStyles.cardTitle
                .copyWith(fontSize: 18, color: Styles.successColor)
                : TextStyles.dataValue.copyWith(fontSize: 15),
          ),
        ],
      ),
    );
  }

  // ── Month / Year dropdowns ───────────────────────────────────────────────

  Widget _buildMonthDropdown() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Styles.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<int>(
        value: _selectedMonth,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Month',
          labelStyle: TextStyles.inputLabelStyle,
          border: InputBorder.none,
        ),
        items: List.generate(
            12,
                (i) => DropdownMenuItem(
              value: i + 1,
              child: Text(months[i], style: TextStyles.inputTextStyle),
            )),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _selectedMonth = v);
          _applyMonthYear();
        },
      ),
    );
  }

  Widget _buildYearDropdown() {
    final current = DateTime.now().year;
    final years = List.generate(7, (i) => current - 4 + i);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        color: Styles.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<int>(
        value: _selectedYear,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'Year',
          labelStyle: TextStyles.inputLabelStyle,
          border: InputBorder.none,
        ),
        items: years
            .map((y) => DropdownMenuItem(
          value: y,
          child: Text('$y', style: TextStyles.inputTextStyle),
        ))
            .toList(),
        onChanged: (v) {
          if (v == null) return;
          setState(() => _selectedYear = v);
          _applyMonthYear();
        },
      ),
    );
  }

  void _applyMonthYear() {
    final first = DateTime(_selectedYear, _selectedMonth, 1);
    final last = DateTime(_selectedYear, _selectedMonth + 1, 0);
    setState(() {
      _startDateController.text = _formatDate(first);
      _endDateController.text = _formatDate(last);
      _dateError = null;
    });
  }

  // ── Preset chips ─────────────────────────────────────────────────────────

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Styles.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Styles.primaryColor.withOpacity(0.2)),
        ),
        child: Text(label,
            style: TextStyles.chipText.copyWith(color: Styles.primaryColor)),
      ),
    );
  }

  void _applyPresetThisMonth() {
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _applyMonthYear();
  }

  void _applyPresetLastMonth() {
    final now = DateTime.now();
    final lastDay =
    DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
    _selectedMonth = lastDay.month;
    _selectedYear = lastDay.year;
    _applyMonthYear();
  }

  void _applyPresetLast30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    setState(() {
      _selectedMonth = end.month;
      _selectedYear = end.year;
      _startDateController.text = _formatDate(start);
      _endDateController.text = _formatDate(end);
      _dateError = null;
    });
  }

  void _applyPresetYTD() {
    final now = DateTime.now();
    setState(() {
      _selectedMonth = now.month;
      _selectedYear = now.year;
      _startDateController.text = _formatDate(DateTime(now.year, 1, 1));
      _endDateController.text = _formatDate(now);
      _dateError = null;
    });
  }

  // ── Trip cards grid ──────────────────────────────────────────────────────

  Widget _buildTripCardsGrid(InvoicingModel invoice) {
    final trips = invoice.tripSummaries;
    if (trips.isEmpty) {
      return Text('No trips found for this period.',
          style: TextStyles.bodyText.copyWith(color: Styles.mutedText));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 1200
            ? 4
            : w >= 900
            ? 3
            : w >= 600
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            final display = TripTypeStyle.getDisplay(trip.tripType);
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Styles.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: display.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(display.icon,
                            color: display.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(display.displayName,
                            style: TextStyles.cardTitle,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTripChip(
                          Icons.confirmation_number_rounded,
                          '${trip.count}',
                          display.color),
                      const SizedBox(width: 8),
                      _buildTripChip(
                          Icons.payments_rounded,
                          '${trip.totalPrice.toStringAsFixed(3)} KWD',
                          display.color),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTripChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text,
              style: TextStyles.chipText.copyWith(color: color)),
        ],
      ),
    );
  }
}
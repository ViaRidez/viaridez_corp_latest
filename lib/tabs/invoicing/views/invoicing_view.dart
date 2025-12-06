import 'package:flutter/material.dart';
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
    // Set default dates (last 30 days)
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    _startDateController.text = _formatDate(startDate);
    _endDateController.text = _formatDate(endDate);

    // Load client name through provider
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

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

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
        final newSd = picked;
        final currEd = DateTime.tryParse(_endDateController.text);
        if (currEd != null && currEd.isBefore(newSd)) {
          _endDateController.text = _formatDate(newSd);
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
      setState(() => _dateError = 'End date can\'t be before start date');
      return;
    }

    final provider = context.read<InvoicingProvider>();
    final clientName = provider.clientName;

    if (clientName != null && clientName.isNotEmpty) {
      provider.generateInvoice(
        clientName: clientName,
        startDate: _startDateController.text,
        endDate: _endDateController.text,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Client name not available. Please try again.')),
      );
    }
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
                // Input Form Card
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
                            //   Consumer<InvoicingProvider>(
                            //     builder: (context, provider, child) {
                            //       if (provider.clientName != null) {
                            //         return Row(
                            //           children: [
                            //             Container(
                            //               padding: const EdgeInsets.symmetric(
                            //                   horizontal: 10, vertical: 6),
                            //               decoration: BoxDecoration(
                            //                 color: Styles.secondaryColor
                            //                     .withOpacity(0.1),
                            //                 borderRadius: BorderRadius.circular(20),
                            //               ),
                            //               child: Row(
                            //                 mainAxisSize: MainAxisSize.min,
                            //                 children: [
                            //                   Icon(Icons.business_rounded,
                            //                       color: Styles.secondaryColor,
                            //                       size: 16),
                            //                   const SizedBox(width: 6),
                            //                   Text(provider.clientName!,
                            //                       style: TextStyles.chipText.copyWith(
                            //                           color: Styles.secondaryColor)),
                            //                 ],
                            //               ),
                            //             ),
                            //           ],
                            //         );
                            //       }
                            //       return const SizedBox.shrink();
                            //     },
                            //   ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
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
                                  controller: _startDateController,
                                  style: TextStyles.inputTextStyle,
                                  decoration: InputDecoration(
                                    labelText: 'Start Date',
                                    labelStyle: TextStyles.inputLabelStyle,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(18),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Styles.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Styles.primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    suffixIcon: Icon(
                                        Icons.edit_calendar_rounded,
                                        color: Styles.textColorMed,
                                        size: 18),
                                  ),
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                      context, _startDateController),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Container(
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
                                  controller: _endDateController,
                                  style: TextStyles.inputTextStyle,
                                  decoration: InputDecoration(
                                    labelText: 'End Date',
                                    labelStyle: TextStyles.inputLabelStyle,
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.all(18),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Styles.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Styles.primaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    suffixIcon: Icon(
                                        Icons.event_available_rounded,
                                        color: Styles.textColorMed,
                                        size: 18),
                                  ),
                                  readOnly: true,
                                  onTap: () =>
                                      _selectDate(context, _endDateController),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_dateError != null) ...[
                          const SizedBox(height: 8),
                          Text(_dateError!, style: TextStyles.errorText),
                        ],
                        const SizedBox(height: 28),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Styles.primaryColor,
                                Styles.secondaryColor
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Styles.primaryColor.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed:
                                provider.isLoading ? null : _generateInvoice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Generate Invoice',
                                        style: TextStyles.primaryButtonText
                                            .copyWith(
                                          fontSize: 17,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Error Display
                if (provider.hasError)
                  Container(
                    decoration: BoxDecoration(
                      color: Styles.errorLight,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Styles.errorColor.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Styles.errorColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyles.errorText,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded,
                                color: Styles.errorColor),
                            onPressed: provider.clearError,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Invoice Summary
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
                                      color:
                                          Styles.successColor.withOpacity(0.2),
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
                                  Text(
                                    'Invoice Summary',
                                    style: TextStyles.sectionTitle,
                                  ),
                                  Text(
                                    'Detailed breakdown in KWD',
                                    style: TextStyles.bodyText.copyWith(
                                      color: Styles.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSummaryRow(
                              'Client:', provider.invoiceData!.clientName),
                          _buildSummaryRow('Period:',
                              '${provider.invoiceData!.formattedStartDate} to ${provider.invoiceData!.formattedEndDate}'),
                          _buildSummaryRow('Total Trips:',
                              provider.totalTripsCount.toString()),
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
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSummaryRow(
                                    'Grand Total:',
                                    '${provider.formattedGrandTotal} KWD',
                                    isTotal: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Trip Details
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
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Styles.primaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.list_alt_rounded,
                                  color: Styles.primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Trip Details',
                                    style: TextStyles.sectionTitle,
                                  ),
                                  Text(
                                    'Itemized trip breakdown',
                                    style: TextStyles.bodyText.copyWith(
                                      color: Styles.mutedText,
                                    ),
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

                // Loading State
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
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Styles.primaryColor.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                color: Styles.primaryColor,
                                backgroundColor: Styles.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Generating invoice...',
                              style: TextStyles.sectionTitle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please wait while we process your data',
                              style: TextStyles.bodyText.copyWith(
                                color: Styles.mutedText,
                              ),
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

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? TextStyles.cardTitle
                : TextStyles.dataLabel.copyWith(
                    fontSize: 15,
                    color: Styles.textColorMed,
                  ),
          ),
          Text(
            value,
            style: isTotal
                ? TextStyles.cardTitle.copyWith(
                    fontSize: 18,
                    color: Styles.successColor,
                  )
                : TextStyles.dataValue.copyWith(
                    fontSize: 15,
                  ),
          ),
        ],
      ),
    );
  }

  // Month/Year helpers
  Widget _buildMonthDropdown() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
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
          setState(() {
            _selectedMonth = v;
          });
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
          setState(() {
            _selectedYear = v;
          });
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

  // Preset chips
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
    final firstThisMonth = DateTime(now.year, now.month, 1);
    final lastMonthLastDay = firstThisMonth.subtract(const Duration(days: 1));
    _selectedMonth = lastMonthLastDay.month;
    _selectedYear = lastMonthLastDay.year;
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
    final first = DateTime(now.year, 1, 1);
    final last = now;
    setState(() {
      _selectedMonth = now.month;
      _selectedYear = now.year;
      _startDateController.text = _formatDate(first);
      _endDateController.text = _formatDate(last);
      _dateError = null;
    });
  }

  // New: Grid of trip detail cards (using TripTypeStyle)
  Widget _buildTripCardsGrid(InvoicingModel invoice) {
    final trips = invoice.tripSummaries;
    if (trips.isEmpty) {
      return Text(
        'No trips found for this period.',
        style: TextStyles.bodyText.copyWith(color: Styles.mutedText),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        final w = constraints.maxWidth;
        if (w >= 1200)
          crossAxisCount = 4;
        else if (w >= 900)
          crossAxisCount = 3;
        else if (w >= 600) crossAxisCount = 2;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
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
                        child:
                            Icon(display.icon, color: display.color, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          display.displayName,
                          style: TextStyles.cardTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: display.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.confirmation_number_rounded,
                                size: 16, color: display.color),
                            const SizedBox(width: 6),
                            Text('${trip.count}',
                                style: TextStyles.chipText
                                    .copyWith(color: display.color)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: display.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.payments_rounded,
                                size: 16, color: display.color),
                            const SizedBox(width: 6),
                            Text('${trip.totalPrice.toStringAsFixed(3)} KWD',
                                style: TextStyles.chipText
                                    .copyWith(color: display.color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

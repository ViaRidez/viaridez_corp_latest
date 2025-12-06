import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:viaridez_corp/utils/styles.dart';
import '../providers/invoices_provider.dart';
import '../models/invoices_model.dart';
import '../services/invoice_pdf_service.dart';

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch invoices when view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvoicesProvider>().fetchAllInvoices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.lightBackground,
      body: Consumer<InvoicesProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(provider),

                const SizedBox(height: 20),

                // Statistics Cards
                if (provider.hasData) _buildStatisticsCards(provider),

                const SizedBox(height: 20),

                // Filters Card
                _buildFiltersCard(provider),

                const SizedBox(height: 20),

                // Error Display
                if (provider.hasError) _buildErrorCard(provider),

                // Loading State
                if (provider.isLoading && !provider.hasData)
                  _buildLoadingCard(),

                // Invoices List
                if (provider.hasData) _buildInvoicesList(provider),

                // Empty State
                if (!provider.isLoading &&
                    !provider.hasData &&
                    !provider.hasError)
                  _buildEmptyState(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(InvoicesProvider provider) {
    return AnimatedContainer(
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
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Invoices",
                    style: TextStyles.pageTitle.copyWith(
                      fontSize: 28,
                      color: Styles.primaryColor,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    height: 3,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: Styles.primaryColor),
              onPressed: provider.isLoading
                  ? null
                  : () {
                      provider.refreshInvoices();
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(InvoicesProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded,
                  color: Styles.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'Statistics Overview',
                style: TextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildStatCard(
                'Total Invoices',
                provider.totalInvoices.toString(),
                Icons.receipt_long_rounded,
                Styles.primaryColor,
              ),
              _buildStatCard(
                'Total Amount',
                '${provider.totalAmount.toStringAsFixed(3)} KWD',
                Icons.monetization_on_rounded,
                Styles.secondaryColor,
              ),
              _buildStatCard(
                'Amount Paid',
                '${provider.totalPaid.toStringAsFixed(3)} KWD',
                Icons.check_circle_rounded,
                Styles.successColor,
              ),
              _buildStatCard(
                'Outstanding',
                '${provider.totalOutstanding.toStringAsFixed(3)} KWD',
                Icons.pending_rounded,
                Styles.errorColor,
              ),
              _buildStatCard(
                'Paid',
                provider.paidCount.toString(),
                Icons.done_all_rounded,
                Styles.successColor,
              ),
              _buildStatCard(
                'Pending',
                provider.pendingCount.toString(),
                Icons.hourglass_empty_rounded,
                Styles.errorColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.05),
            color.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyles.dataLabel.copyWith(
              fontSize: 12,
              color: Styles.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyles.cardTitle.copyWith(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard(InvoicesProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list_rounded,
                    color: Styles.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyles.sectionTitle.copyWith(fontSize: 18),
                  ),
                ),
                TextButton.icon(
                  icon: Icon(Icons.clear_all_rounded, color: Styles.errorColor),
                  label: Text('Clear All',
                      style: TextStyles.chipText
                          .copyWith(color: Styles.errorColor)),
                  onPressed: () {
                    provider.clearFilters();
                    _searchController.clear();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Styles.errorLight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Payment Status Filter
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    value: provider.paymentFilter,
                    decoration: InputDecoration(
                      labelText: 'Payment Status',
                      labelStyle: TextStyles.inputLabelStyle,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Styles.primaryColor.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Styles.primaryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Styles.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Styles.lightBackground,
                      prefixIcon: Icon(Icons.payment_rounded,
                          color: Styles.primaryColor),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Status')),
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.setPaymentFilter(value);
                      }
                    },
                  ),
                ),
                // Search
                SizedBox(
                  width: 350,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: TextStyles.inputLabelStyle,
                      hintText: 'Search by client, invoice number...',
                      hintStyle: TextStyles.hintText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Styles.primaryColor.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Styles.primaryColor.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Styles.primaryColor, width: 2),
                      ),
                      filled: true,
                      fillColor: Styles.lightBackground,
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Styles.primaryColor),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: Styles.errorColor),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                    ),
                    onChanged: (value) {
                      provider.setSearchQuery(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(InvoicesProvider provider) {
    return Container(
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
              child: Text(
                provider.errorMessage!,
                style: TextStyles.errorText,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: Styles.errorColor),
              onPressed: provider.clearError,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return AnimatedContainer(
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
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading invoices...',
                style: TextStyles.sectionTitle.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoicesList(InvoicesProvider provider) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    color: Styles.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Invoices List',
                  style: TextStyles.sectionTitle,
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Styles.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.invoices.length} invoice${provider.invoices.length != 1 ? 's' : ''}',
                    style: TextStyles.chipText.copyWith(
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.invoices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final invoice = provider.invoices[index];
                return _buildInvoiceCard(invoice);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(InvoiceModel invoice) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (invoice.isPaid) {
      statusColor = Styles.successColor;
      statusText = 'Paid';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = Styles.errorColor;
      statusText = 'Pending';
      statusIcon = Icons.pending_actions_rounded;
    }

    return InkWell(
      onTap: () => _showInvoiceDetailsDialog(invoice),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Styles.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Styles.primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Styles.primaryColor.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Styles.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Styles.primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invoice #${invoice.id}',
                          style: TextStyles.cardTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Styles.tertiaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${invoice.formattedStartDate} - ${invoice.formattedEndDate}',
                          style: TextStyles.dataLabel.copyWith(
                            color: Styles.mutedText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyles.chipText.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Styles.mutedText.withOpacity(0.2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildCompactInfo(
                      Icons.calendar_month_rounded,
                      'Period',
                      '${invoice.formattedStartDate} - ${invoice.formattedEndDate}',
                      Styles.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCompactInfo(
                      Icons.payments_rounded,
                      'Total Amount',
                      '${invoice.formattedGrandTotal} KWD',
                      Styles.tertiaryColor,
                    ),
                  ),
                  Expanded(
                    child: _buildCompactInfo(
                      Icons.check_circle_rounded,
                      'Amount Paid',
                      '${invoice.formattedAmountPaid} KWD',
                      Styles.successColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCompactInfo(
                      Icons.pending_actions_rounded,
                      'Balance Due',
                      '${invoice.formattedBalance} KWD',
                      invoice.isPaid ? Styles.successColor : Styles.errorColor,
                    ),
                  ),
                  Expanded(
                    child: _buildCompactInfo(
                      Icons.payment_rounded,
                      'Payment',
                      invoice.paymentMethod,
                      Styles.mutedText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap for details',
                    style: TextStyles.dataLabel.copyWith(
                      color: Styles.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Styles.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfo(
      IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.dataLabel.copyWith(
                  fontSize: 11,
                  color: Styles.mutedText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyles.dataValue.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showInvoiceDetailsDialog(InvoiceModel invoice) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (invoice.isPaid) {
      statusColor = Styles.successColor;
      statusText = 'Paid';
      statusIcon = Icons.check_circle_rounded;
    } else {
      statusColor = Styles.errorColor;
      statusText = 'Pending';
      statusIcon = Icons.pending_actions_rounded;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxWidth: 800),
          decoration: BoxDecoration(
            color: Styles.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Styles.primaryColor,
                        Styles.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Styles.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: Styles.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Invoice Details',
                              style: TextStyles.pageTitle.copyWith(
                                color: Styles.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Invoice #${invoice.id}',
                              style: TextStyles.dataLabel.copyWith(
                                color: Styles.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: Styles.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                color: statusColor.withOpacity(0.3), width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, color: statusColor, size: 24),
                              const SizedBox(width: 10),
                              Text(
                                statusText,
                                style: TextStyles.cardTitle.copyWith(
                                  color: statusColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Trip Information Section
                      _buildDialogSection(
                        'Trip Information',
                        Icons.route_rounded,
                        [
                          _buildDetailRow('Invoice ID', invoice.id.toString()),
                          _buildDetailRow(
                              'Invoice Number', invoice.invoiceNumber ?? 'N/A'),
                          _buildDetailRow('Status', invoice.status ?? 'N/A'),
                          if (invoice.booking != null)
                            _buildDetailRow('Booking ID', invoice.booking!),
                          _buildDetailRow('Trip ID', invoice.tripId.toString()),
                          if (invoice.tripRoute != null)
                            _buildDetailRow('Route', invoice.tripRoute!),
                          if (invoice.pickupStop != null)
                            _buildDetailRow('Pickup', invoice.pickupStop!),
                          if (invoice.dropStop != null)
                            _buildDetailRow('Drop', invoice.dropStop!),
                          _buildDetailRow(
                              'Seats Booked', invoice.seatsBooked.toString()),
                          if (invoice.pricePerSeat != null)
                            _buildDetailRow('Price/Seat',
                                '${invoice.pricePerSeat!.toStringAsFixed(3)} KWD'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Passenger Information Section (if available)
                      if (invoice.passengerName != null ||
                          invoice.passengerEmail != null ||
                          invoice.phoneNumber != null)
                        _buildDialogSection(
                          'Passenger Information',
                          Icons.person_rounded,
                          [
                            if (invoice.passengerName != null)
                              _buildDetailRow('Name', invoice.passengerName!),
                            if (invoice.passengerEmail != null)
                              _buildDetailRow('Email', invoice.passengerEmail!),
                            if (invoice.phoneNumber != null)
                              _buildDetailRow('Phone', invoice.phoneNumber!),
                          ],
                        ),

                      if (invoice.passengerName != null ||
                          invoice.passengerEmail != null ||
                          invoice.phoneNumber != null)
                        const SizedBox(height: 20),

                      // Date Information Section
                      _buildDialogSection(
                        'Date Information',
                        Icons.calendar_today_rounded,
                        [
                          _buildDetailRow(
                              'Start Date', invoice.formattedStartDate),
                          _buildDetailRow('End Date', invoice.formattedEndDate),
                          if (invoice.tripStartTime != null)
                            _buildDetailRow(
                                'Trip Start Time', invoice.tripStartTime!),
                          if (invoice.tripEndTime != null)
                            _buildDetailRow(
                                'Trip End Time', invoice.tripEndTime!),
                          if (invoice.generatedAt != null)
                            _buildDetailRow(
                                'Generated At', invoice.generatedAt!),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Financial Information Section
                      _buildDialogSection(
                        'Financial Details',
                        Icons.account_balance_wallet_rounded,
                        [
                          if (invoice.totalPrice != null)
                            _buildDetailRow(
                              'Trip Total',
                              '${invoice.totalPrice!.toStringAsFixed(3)} KWD',
                              valueColor: Styles.tertiaryColor,
                            ),
                          const Divider(),
                          _buildDetailRow(
                            'Grand Total',
                            '${invoice.formattedGrandTotal} KWD',
                            valueColor: Styles.primaryColor,
                            isHighlight: true,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Payment Information Section
                      _buildDialogSection(
                        'Payment Details',
                        Icons.payment_rounded,
                        [
                          _buildDetailRow(
                            'Amount Paid',
                            '${invoice.formattedAmountPaid} KWD',
                            valueColor: Styles.successColor,
                            isHighlight: true,
                          ),
                          _buildDetailRow(
                            'Balance Due',
                            '${invoice.formattedBalance} KWD',
                            valueColor: invoice.isPaid
                                ? Styles.successColor
                                : Styles.errorColor,
                            isHighlight: true,
                          ),
                          _buildDetailRow(
                              'Payment Method', invoice.paymentMethod),
                          _buildDetailRow(
                              'Payment Gateway', invoice.paymentGateway),
                          _buildDetailRow('Payment Type', invoice.paymentType),
                          _buildDetailRow('Online Payment',
                              invoice.onlinePayment ? 'Yes' : 'No'),
                          _buildDetailRow('Cash Payment',
                              invoice.cashPayment ? 'Yes' : 'No'),
                          _buildDetailRow('Payment Complete',
                              invoice.paymentComplete ? 'Yes' : 'No'),
                          if (invoice.orderId != null)
                            _buildDetailRow('Order ID', invoice.orderId!),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Additional Information Section
                      _buildDialogSection(
                        'Additional Information',
                        Icons.info_outline_rounded,
                        [
                          if (invoice.airportTransfer != null)
                            _buildDetailRow(
                                'Airport Transfer', invoice.airportTransfer!),
                          if (invoice.shuttleBookingGroupId != null)
                            _buildDetailRow('Shuttle Group ID',
                                invoice.shuttleBookingGroupId!),
                          if (invoice.bookingGroupId != null)
                            _buildDetailRow(
                                'Booking Group ID', invoice.bookingGroupId!),
                          if (invoice.bookingDetails != null)
                            _buildDetailRow(
                                'Booking Details', invoice.bookingDetails!),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Styles.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(
                                              color: Styles.primaryColor,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Generating PDF...',
                                              style: TextStyles.cardTitle,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  // Generate and download PDF
                                  await InvoicePdfService
                                      .generateAndDownloadInvoice(invoice);

                                  // Close loading dialog
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }

                                  // Show success message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded,
                                                color: Styles.white),
                                            const SizedBox(width: 12),
                                            const Text(
                                                'Invoice PDF downloaded successfully!'),
                                          ],
                                        ),
                                        backgroundColor: Styles.successColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  // Close loading dialog if still open
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }

                                  // Show error message
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error_outline_rounded,
                                                color: Styles.white),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                  'Failed to generate PDF: ${e.toString()}'),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Styles.errorColor,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        duration: const Duration(seconds: 5),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                              ),
                              label: const Text('Download PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.primaryColor,
                                foregroundColor: Styles.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close_rounded),
                              label: const Text('Close'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Styles.tertiaryColor,
                                side: BorderSide(color: Styles.tertiaryColor),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSection(
      String title, IconData icon, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Styles.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Styles.primaryColor.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Styles.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Styles.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyles.sectionTitle.copyWith(
                    fontSize: 16,
                    color: Styles.tertiaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyles.dataLabel.copyWith(
                fontSize: 13,
                color: Styles.mutedText,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyles.dataValue.copyWith(
                fontSize: isHighlight ? 15 : 13,
                color: valueColor ?? Styles.tertiaryColor,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: Styles.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Styles.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(60.0),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 80,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 20),
              Text(
                'No Invoices Found',
                style: TextStyles.sectionTitle.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'There are no invoices matching your criteria',
                style: TextStyles.bodyText.copyWith(
                  color: Styles.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

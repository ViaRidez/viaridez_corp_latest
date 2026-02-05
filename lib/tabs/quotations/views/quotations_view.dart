import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/styles.dart';
import '../models/quotations_model.dart';
import '../providers/quotations_provider.dart';

class QuotationsView extends StatefulWidget {
  const QuotationsView({super.key});

  @override
  State<QuotationsView> createState() => _QuotationsViewState();
}

class _QuotationsViewState extends State<QuotationsView> {
  @override
  void initState() {
    super.initState();
    // Load all quotations when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuotationsProvider>().loadQuotations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quotations",
                    style: TextStyles.pageTitle.copyWith(
                      fontSize: 28,
                      color: Styles.primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    height: 3,
                    width: 60,
                    color: Styles.primaryColor,
                  ),
                ],
              ),
              // Refresh Button
              Consumer<QuotationsProvider>(
                builder: (context, provider, child) {
                  return ElevatedButton.icon(
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            provider.refreshQuotations();
                          },
                    icon: provider.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                    label: Text(provider.isLoading ? 'Loading...' : 'Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Summary Cards
          // Consumer<QuotationsProvider>(
          //   builder: (context, provider, child) {
          //     return Row(
          //       children: [
          //         _buildSummaryCard(
          //           'Total Quotations',
          //           provider.quotationCount.toString(),
          //           Icons.request_quote_outlined,
          //           Styles.primaryColor,
          //         ),
          //         const SizedBox(width: 16),
          //         _buildSummaryCard(
          //           'Total Routes',
          //           provider.totalRoutesCount.toString(),
          //           Icons.route_outlined,
          //           Colors.orange,
          //         ),
          //         const Spacer(), // This will push everything to the left and leave space on the right
          //       ],
          //     );
          //   },
          // ),
          // const SizedBox(height: 24),

          // Content Area
          Expanded(
            child: Consumer<QuotationsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading quotations...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading quotations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.error!,
                          style: TextStyle(
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.refreshQuotations(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (!provider.hasData) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.request_quote_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No quotations found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No quotations available',
                          style: TextStyle(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Quotations List
                return ListView.builder(
                  itemCount: provider.quotations.length,
                  itemBuilder: (context, index) {
                    final quotation = provider.quotations[index];
                    return _buildQuotationCard(quotation);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationCard(Quotation quotation) {
    final Color cardColor = Styles.primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardColor.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with unique identifier
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quotation.reportName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cardColor.withOpacity(0.9),
                        fontFamily: 'Lexend',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Created: ${quotation.formattedCreatedAt}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${quotation.routeCount} Routes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quotation.formattedTotalPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Routes List
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...quotation.validRoutes.map((route) =>
                    _buildRouteItem(route, quotation.currency, cardColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteItem(RoutePrice route, Currency currency, Color cardColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Route Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: cardColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: cardColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        route.routeDisplay,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cardColor.withOpacity(0.9),
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      route.distanceDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Price
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cardColor.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${currency.symbol} ${route.priceDisplay}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: cardColor,
                    fontFamily: 'Lexend',
                  ),
                ),
                Text(
                  'Per Trip',
                  style: TextStyle(
                    fontSize: 10,
                    color: cardColor.withOpacity(0.7),
                    fontFamily: 'Lexend',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

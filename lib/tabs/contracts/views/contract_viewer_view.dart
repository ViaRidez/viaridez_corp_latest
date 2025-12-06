import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/styles.dart';
import '../../../../auth/provider/auth_provider.dart';
import '../providers/contract_provider.dart';
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

class ContractViewerView extends StatefulWidget {
  const ContractViewerView({super.key});

  @override
  State<ContractViewerView> createState() => _ContractViewerViewState();
}

class _ContractViewerViewState extends State<ContractViewerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContract());
  }

  void _loadContract() async {
    final contractProvider =
    Provider.of<ContractProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final clientName = authProvider.clientName!;

    await contractProvider.fetchContract(clientName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.white,
      body: Consumer<ContractProvider>(
        builder: (context, provider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - Responsive Layout
              Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 768;

                    if (isMobile) {
                      // Mobile Layout - Stack elements vertically
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            children: [
                              Icon(Icons.description,
                                  color: Styles.primaryColor, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Client Contract',
                                  style: TextStyles.sectionTitle.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Actions row
                          Row(
                            children: [
                              if (provider.hasData) ...[
                                Expanded(
                                  child: Text(
                                    'Size: ${provider.contract!.fileSizeFormatted}',
                                    style: TextStyles.bodyText.copyWith(
                                      color: Styles.tertiaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _downloadContract(provider),
                                    icon: const Icon(Icons.download,
                                        color: Colors.white, size: 16),
                                    label: Text('Download',
                                        style: TextStyles.primaryButtonText
                                            .copyWith(fontSize: 14)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Styles.primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      minimumSize: const Size(0, 36),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: ElevatedButton.icon(
                                  onPressed: _loadContract,
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white, size: 16),
                                  label: Text('Refresh',
                                      style: TextStyles.primaryButtonText
                                          .copyWith(fontSize: 14)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Styles.secondaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    minimumSize: const Size(0, 36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      // Desktop/Tablet Layout - Keep original Row
                      return Row(
                        children: [
                          Icon(Icons.description,
                              color: Styles.primaryColor, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Client Contract',
                            style: TextStyles.sectionTitle.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (provider.hasData) ...[
                            Text(
                              'Size: ${provider.contract!.fileSizeFormatted}',
                              style: TextStyles.bodyText.copyWith(
                                color: Styles.tertiaryColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: () => _downloadContract(provider),
                              icon: const Icon(Icons.download, color: Colors.white),
                              label: Text('Download',
                                  style: TextStyles.primaryButtonText),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Styles.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          ElevatedButton.icon(
                            onPressed: _loadContract,
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: Text('Refresh',
                                style: TextStyles.primaryButtonText),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.secondaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ContractProvider provider) {
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Styles.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Loading contract...',
              style: TextStyles.bodyText.copyWith(
                fontSize: 16,
                color: Styles.tertiaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 64),
            const SizedBox(height: 16),
            Text(
              'Failed to load contract',
              style: TextStyles.sectionTitle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                provider.errorMessage ?? 'Unknown error occurred',
                style: TextStyles.errorText,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContract,
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: Text('Try Again', style: TextStyles.primaryButtonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.hasData && provider.contract!.isValidPdf) {
      return Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // PDF Info Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Styles.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isSmall = constraints.maxWidth < 500;

                  if (isSmall) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.picture_as_pdf,
                                color: Styles.primaryColor, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contract Document',
                                    style: TextStyles.cardTitle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${provider.contract!.clientName} - ${provider.contract!.fileSizeFormatted}',
                                    style: TextStyles.bodyText.copyWith(
                                      color: Styles.tertiaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _viewPdfInNewTab(provider.contract!.pdfData),
                            icon: const Icon(Icons.open_in_new, color: Colors.white),
                            label: Text('View PDF', style: TextStyles.primaryButtonText),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Styles.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Icon(Icons.picture_as_pdf,
                            color: Styles.primaryColor, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contract Document',
                                style: TextStyles.cardTitle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${provider.contract!.clientName} - ${provider.contract!.fileSizeFormatted}',
                                style: TextStyles.bodyText.copyWith(
                                  color: Styles.tertiaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _viewPdfInNewTab(provider.contract!.pdfData),
                          icon: const Icon(Icons.open_in_new, color: Colors.white),
                          label: Text('View PDF', style: TextStyles.primaryButtonText),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Styles.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),

            // PDF Preview Placeholder
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description,
                        color: Styles.primaryColor, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      'PDF Contract Ready',
                      style: TextStyles.sectionTitle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Styles.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Click "View PDF" to open the contract in a new tab',
                      style: TextStyles.bodyText.copyWith(
                        fontSize: 16,
                        color: Styles.tertiaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Valid PDF Document',
                          style: TextStyles.bodyText.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, color: Colors.grey[400], size: 64),
          const SizedBox(height: 16),
          Text(
            'No contract available',
            style: TextStyles.sectionTitle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No contract found for this client',
            style: TextStyles.bodyText.copyWith(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPdfInNewTab(Uint8List pdfData) {
    try {
      // Create a blob URL for the PDF data
      final blob = html.Blob([pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Open in new tab
      html.window.open(url, '_blank');

      // Clean up the blob URL after a delay
      Timer(const Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contract opened in new tab',
              style: TextStyles.primaryButtonText,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to open contract: $e',
              style: TextStyles.primaryButtonText,
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _downloadContract(ContractProvider provider) async {
    if (provider.contract == null) return;

    try {
      // Create a blob and download link
      final blob = html.Blob([provider.contract!.pdfData], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create a temporary anchor element for download
      final anchor = html.AnchorElement(href: url)
        ..target = '_blank'
        ..download = '${provider.contract!.clientName}_contract.pdf';

      // Trigger download
      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();

      // Clean up
      html.Url.revokeObjectUrl(url);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contract download started',
              style: TextStyles.primaryButtonText,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download contract: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

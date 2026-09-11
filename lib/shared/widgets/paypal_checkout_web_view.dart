import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import 'dq_buttons.dart';

const paypalReturnUrl = 'https://donatequran.com/paypal-return';
const paypalCancelUrl = 'https://donatequran.com/paypal-cancel';

class PaypalCheckoutWebView extends StatefulWidget {
  const PaypalCheckoutWebView({super.key, required this.approvalUrl});

  final String approvalUrl;

  static Future<bool> open(BuildContext context, {required String approvalUrl}) async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PaypalCheckoutWebView(approvalUrl: approvalUrl),
      ),
    );
    return result ?? false;
  }

  @override
  State<PaypalCheckoutWebView> createState() => _PaypalCheckoutWebViewState();
}

class _PaypalCheckoutWebViewState extends State<PaypalCheckoutWebView> {
  late final WebViewController _controller;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            if (_isReturn(request.url)) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (_isCancel(request.url)) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  static bool _isReturn(String url) {
    return url.startsWith(paypalReturnUrl) || url.startsWith('donatequran://paypal-return');
  }

  static bool _isCancel(String url) {
    return url.startsWith(paypalCancelUrl) || url.startsWith('donatequran://paypal-cancel');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            DqScreenHeader(
              title: 'PayPal',
              onBack: () => Navigator.of(context).pop(false),
            ),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_loading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

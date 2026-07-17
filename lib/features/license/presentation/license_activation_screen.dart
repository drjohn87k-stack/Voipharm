import 'package:flutter/material.dart';
import '../../../core/services/license_service.dart';
import '../../../core/constants/app_constants.dart';

/// First-launch license activation screen.
///
/// Shows the device id and lets the user enter a registration code.
/// On success it calls [onActivated]. The footer carries the author
/// copyright notice (Abdullah Alshwerif - 0917156449).
class LicenseActivationScreen extends StatefulWidget {
  const LicenseActivationScreen({super.key, required this.onActivated});

  final VoidCallback onActivated;

  @override
  State<LicenseActivationScreen> createState() =>
      _LicenseActivationScreenState();
}

class _LicenseActivationScreenState extends State<LicenseActivationScreen> {
  final _controller = TextEditingController();
  final _license = LicenseService.instance;
  bool _loading = false;
  String? _error;
  bool _showDeviceId = false;

  @override
  void initState() {
    super.initState();
    _license.load().then((_) {
      if (mounted && _license.isActivated) {
        widget.onActivated();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final ok = await _license.activate(_controller.text);
    if (!mounted) return;
    if (ok) {
      widget.onActivated();
    } else {
      setState(() {
        _loading = false;
        _error = 'Invalid registration code. Please check and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 72, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Medical Request Voice App',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Activate your license to continue.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Registration Code',
                      hintText: 'XXXX-XXXX-XXXX-XXXX',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      errorText: _error,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (v) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () =>
                        setState(() => _showDeviceId = !_showDeviceId),
                    child: Row(
                      children: [
                        Icon(_showDeviceId
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 18,
                            color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          _showDeviceId
                              ? 'Device ID: ${_license.deviceId}'
                              : 'Show device ID (for code issuance)',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed:
                        _loading || _controller.text.trim().isEmpty
                            ? null
                            : _activate,
                    icon: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_open_outlined),
                    label: const Text('Activate'),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    '© ${AppConstants.copyrightYear} ${AppConstants.authorName} '
                    '(${AppConstants.authorPhone}).\n'
                    'All rights reserved. Unauthorized copying or '
                    'distribution is prohibited.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

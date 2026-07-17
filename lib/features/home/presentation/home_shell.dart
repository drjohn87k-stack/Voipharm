import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_request_app/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/services/license_service.dart';
import '../../items/data/items_repository.dart';
import '../../history/presentation/bloc/history_bloc.dart';
import '../../request/domain/request_entity.dart';
import '../../request/presentation/bloc/request_builder_bloc.dart';
import '../../items/presentation/items_browser_screen.dart';
import '../../items/presentation/import_screen.dart';
import '../../request/presentation/request_builder_screen.dart';
import '../../history/presentation/history_screen.dart';

/// The main app shell with bottom navigation between:
///   - Home (dashboard)
///   - New Request (builder)
///   - History
///   - Import
///
/// The app bar carries a language toggle (AR ↔ EN) that switches the
/// whole app's locale + text direction (RTL/LTR).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Pre-seed the DB so the dashboard count is correct.
    ItemsRepository.instance.ensureSeeded();
    // Load history for the dashboard badge.
    context.read<HistoryBloc>().add(const HistoryLoadStarted());
  }

  void _openRequestForEditing(RequestEntity request) {
    context.read<RequestBuilderBloc>().add(RequestLoaded(request));
    setState(() => _index = 1);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = LocaleService.instance.isArabic;

    final screens = <Widget>[
      _Dashboard(onStartRequest: () => setState(() => _index = 1)),
      const RequestBuilderScreen(),
      HistoryScreen(onOpenRequest: _openRequestForEditing),
      const ImportScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        centerTitle: true,
        actions: [
          // Language toggle
          IconButton(
            tooltip: isAr ? l.switchToEnglish : l.switchToArabic,
            icon: const Icon(Icons.translate),
            onPressed: () => LocaleService.instance.toggle(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'about') _showAbout(context, l);
              if (v == 'license') _showLicense(context, l);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'about', child: Text(l.about)),
              PopupMenuItem(value: 'license', child: Text(l.license)),
            ],
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == 1) {
            // New Request: always start fresh unless we just came from
            // history (handled via _openRequestForEditing).
            final s = context.read<RequestBuilderBloc>().state;
            if (s is! RequestBuilderEditing || s.id != null) {
              // If editing an existing request, keep it; otherwise new.
            }
          }
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: l.newRequest,
          ),
          NavigationDestination(
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l.history,
          ),
          NavigationDestination(
            icon: const Icon(Icons.file_upload_outlined),
            selectedIcon: const Icon(Icons.file_upload),
            label: l.importItems,
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.about),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.appTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${l.version}: ${AppConstants.appVersion}'),
            const SizedBox(height: 8),
            Text(l.copyright),
            const SizedBox(height: 4),
            Text(l.proprietaryNotice,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Text(l.contactSupport),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  void _showLicense(BuildContext context, AppLocalizations l) async {
    await LicenseService.instance.load();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l.license),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LicenseService.instance.isActivated
                ? l.licenseActivated
                : l.licenseRequired),
            const SizedBox(height: 12),
            Text('${l.registrationCode}:'),
            const SizedBox(height: 4),
            SelectableText(
              LicenseService.instance.activatedCode.isEmpty
                  ? '—'
                  : LicenseService.instance.activatedCode,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Device ID:'),
            const SizedBox(height: 4),
            SelectableText(LicenseService.instance.deviceId,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }
}

// ---------- Dashboard ----------
class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.onStartRequest});
  final VoidCallback onStartRequest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.welcome,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(l.welcomeSubtitle,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: cs.onPrimary.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Stats row
            FutureBuilder<int>(
              future: ItemsRepository.instance.count(),
              builder: (context, snap) {
                final itemsCount = snap.data ?? 0;
                return BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, hState) {
                    final reqCount = hState is HistoryLoadSuccess
                        ? hState.requests.length
                        : 0;
                    return Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.medical_services_outlined,
                            label: l.itemsInDatabase,
                            value: '$itemsCount',
                            color: cs.primaryContainer,
                            onColor: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.request_quote_outlined,
                            label: l.savedRequests,
                            value: '$reqCount',
                            color: cs.secondaryContainer,
                            onColor: cs.onSecondaryContainer,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // Quick actions
            Text(l.quickActions,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _QuickAction(
              icon: Icons.add_circle,
              label: l.startNewRequest,
              onTap: onStartRequest,
            ),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.search,
              label: l.openBrowser,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ItemsBrowserScreen(
                  onItemSelected: (_) {},
                ),
              )),
            ),
            const SizedBox(height: 10),
            _QuickAction(
              icon: Icons.file_upload_outlined,
              label: l.openImport,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ImportScreen(),
              )),
            ),
            const SizedBox(height: 24),
            // Footer copyright
            Center(
              child: Text(
                l.copyrightFooter,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: onColor),
          const SizedBox(height: 8),
          Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: onColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: onColor)),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Icon(icon, color: cs.onPrimaryContainer),
        ),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

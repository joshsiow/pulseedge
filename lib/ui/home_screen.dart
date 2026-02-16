import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Your existing theme + services
import '../theme/app_theme.dart';
import '../core/auth/auth_service.dart';

// IMPORTANT: adjust this import to your actual AI service path
//import '../core/ai/ai_service.dart';
//import '../core/ai/analytics_engine.dart';
import '../core/session/session_context_store.dart';
import 'package:intl/intl.dart';

import '../ui/encounters/encounter_registration_screen.dart';
import '../ui/patients/patient_search_screen.dart';
import '../ui/setting/settings_screen.dart';

//import '../../core/ai/pulse_ai_providers.dart'; // Added for aiServiceProvider + pulseAiReadyProvider
import 'package:pulseedge/core/ai/pulse_ai_providers.dart'
    show aiServiceProvider, analyticsEngineProvider;

Color _mutedText(BuildContext c) =>
    Theme.of(c).textTheme.bodySmall?.color?.withOpacity(0.65)
    ?? Colors.grey;

Color _borderColor(BuildContext c) =>
    Theme.of(c).dividerColor;

Color _successColor(BuildContext c) =>
    Colors.green.shade600;

Color _dangerColor(BuildContext c) =>
    Colors.red.shade600;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class UnitLite {
  final String id;
  final String name;

  const UnitLite({required this.id, required this.name});

  @override
  String toString() => name;
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _chatCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSessionAndUnits();
  }

  bool _sending = false;
  String? _chatError;
  //Session Gate UI
  SessionContext? _activeSession;
  bool _sessionLoading = true;
  String? _sessionError;
  List<UnitLite> _myUnits = const [];

  final List<_ChatMsg> _msgs = <_ChatMsg>[
    _ChatMsg(
      role: _ChatRole.assistant,
      text:
          "Hi 👋 I'm PulseEdge AI.\n\nTry:\n• “how many encounters this morning?”\n• “berapa encounter pagi ini”\n• “top diagnosis today”",
      at: DateTime.now(),
    ),
  ];

  // --- Helpers -------------------------------------------------------------

  Color _opacity(Color c, double o) => c.withAlpha((o * 255).round());

  Future<void> _scrollChatToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (!_chatScroll.hasClients) return;
    _chatScroll.animateTo(
      _chatScroll.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _addMsg(_ChatMsg m) {
    setState(() => _msgs.add(m));
    _scrollChatToBottom();
  }

  Future<void> _sendChat(String prompt) async {
  _addMsg(_ChatMsg(
    role: _ChatRole.assistant,
    text: 'AI is disabled in this build.',
    at: DateTime.now(),
  ));
}
/*
  Future<void> _sendChat(String prompt) async {
    const uiOnlyActions = {
      'start a new encounter workflow.',
      'open patient search.',
    };

    if (uiOnlyActions.contains(prompt.toLowerCase())) {
      return;
    }

    if (_activeSession == null) {
      await _startOrSwitchSession();
      if (_activeSession == null) return; // user cancelled
    }

    final trimmed = prompt.trim();
    if (trimmed.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _chatError = null;
    });

    _chatCtrl.clear();

    _addMsg(_ChatMsg(
      role: _ChatRole.user,
      text: trimmed,
      at: DateTime.now(),
    ));

    try {
      final ai = ref.read(aiServiceProvider);

      // THIS matches your ai_service.dart
      final response = await ai.runRawPrompt(trimmed);

      _addMsg(_ChatMsg(
        role: _ChatRole.assistant,
        text: response.answer.trim(),
        at: DateTime.now(),
      ));
    } catch (e, st) {
      debugPrint('AI ERROR: $e\n$st');
      setState(() {
        _chatError = 'AI error: ${e.toString()}';
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  
  */
  Future<void> _logout() async {
    // clear session context on logout
    await ref.read(sessionContextStoreProvider).clear();

    final auth = ref.read(authServiceProvider);
    auth.logout();
    if (mounted) context.go('/login');
  }

  Future<void> _loadSessionAndUnits() async {
    setState(() {
      _sessionLoading = true;
      _sessionError = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      final user = auth.currentUser;

      if (user == null) {
        setState(() {
          _activeSession = null;
          _myUnits = const [];
          _sessionLoading = false;
        });
        return;
      }

      final store = ref.read(sessionContextStoreProvider);
      final existing = await store.getActive();

      final engine = ref.read(analyticsEngineProvider);
      final units = await engine.unitsForUser(user.id);

      // Auto-start if user only has one unit and no existing session.
      if (existing == null && units.length == 1) {
        final u = units.first;
        final now = DateTime.now();
        final ctx = SessionContext(
          userId: user.id,
          unitId: u.id,
          unitName: u.name,
          startedAt: now,
          expiresAt: now.add(const Duration(hours: 8)),
        );
        await store.setActive(ctx);
        setState(() {
          _activeSession = ctx;
          _myUnits = units
              .map(
                (u) => UnitLite(
                  id: u.id,
                  name: u.name,
                 // code: u.code, // remove if Unit has no `code`
                ),
              )
              .toList();
          _sessionLoading = false;
        });
        return;
      }

      setState(() {
        //_activeSession = ctx;
        _myUnits = units
            .map(
              (u) => UnitLite(
                id: u.id,
                name: u.name,
              //  code: u.code, // remove if Unit has no `code`
              ),
            )
            .toList();
        _sessionLoading = false;
      });
    } catch (e) {
      setState(() {
        _sessionError = e.toString();
        _sessionLoading = false;
      });
    }
  }

  //session
  Future<void> _startOrSwitchSession() async {
    final auth = ref.read(authServiceProvider);
    final user = auth.currentUser;
    if (user == null) return;

    if (_myUnits.isEmpty) {
      setState(() => _chatError = 'No unit assigned to your user. Ask admin to assign a unit.');
      return;
    }

    final selected = await showModalBottomSheet<UnitLite>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Start Session',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkPrimary,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Choose your medical unit. PulseAI will scope analytics + patient access to this session.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _mutedText(context),
                      ),
                ),
                const SizedBox(height: 12),
                ..._myUnits.map((u) {
                  final isActive = _activeSession?.unitId == u.id;
                  return Card(
                    elevation: 0,
                    color: isActive
                        ? AppTheme.primary.withOpacity(0.10)
                        : AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isActive
                            ? AppTheme.primary.withOpacity(0.35)
                            : _borderColor(context),
                      ),
                    ),
                    child: ListTile(
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      //subtitle: Text(u.code),
                      trailing: isActive ? const Icon(Icons.check_circle) : const Icon(Icons.arrow_forward),
                      onTap: () => Navigator.of(ctx).pop(u),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;

    final now = DateTime.now();
    final ctx = SessionContext(
      userId: user.id,
      unitId: selected.id,
      unitName: selected.name,
      startedAt: now,
      expiresAt: now.add(const Duration(hours: 8)),
    );

    final store = ref.read(sessionContextStoreProvider);
    await store.setActive(ctx);

    setState(() => _activeSession = ctx);

    _addMsg(_ChatMsg(
      role: _ChatRole.assistant,
      text: '✅ Session started: **${selected.name}** (expires in 8h).',
      at: DateTime.now(),
    ));
  }

  Future<void> _endSession() async {
    final store = ref.read(sessionContextStoreProvider);
    await store.clear();
    setState(() => _activeSession = null);

    _addMsg(_ChatMsg(
      role: _ChatRole.assistant,
      text: 'Session ended. Start a new session to continue.',
      at: DateTime.now(),
    ));
  }
  // --- UI ------------------------------------------------------------------
 /* @override
  void initState() {
    super.initState();
    _loadSessionAndUnits();
  }
*/
  @override
  void dispose() {
    _chatCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/icons/pulseedge_logo_black.png',
              height: 28,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
            const SizedBox(width: 10),
            const Text('PulseEdge'),
            const Spacer(),
            IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),

      // Make it scrollable to avoid RenderFlex overflow on small windows.
      body: CustomPaint(
        painter: ECGGridPainter(color: _opacity(AppTheme.primary, 0.10)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---- Header row ------------------------------------------------
                    _HeaderRow(
                      subtitle: 'Offline-first clinical operations',
                      rightBadge: _UserBadge(
                        username: auth.currentUser?.username ?? 'Unknown',
                        role: auth.currentUser?.role ?? '—',
                      ),
                    ),
                    _SessionGateCard(
                      loading: _sessionLoading,
                      error: _sessionError,
                      active: _activeSession,
                      unitsCount: _myUnits.length,
                      onStartOrSwitch: _startOrSwitchSession,
                      onEnd: _endSession,
                    ),
                  const SizedBox(height: 8),
                  
                    // ---- AI Chat Panel (center / primary) -------------------------
                    _AiChatCard(
                      sending: _sending,
                      error: _chatError,
                      msgs: _msgs,
                      scrollController: _chatScroll,
                      controller: _chatCtrl,
                      onSend: _sendChat,
                      opacity: _opacity,
                      activeSession: _activeSession,
                      onStartSession: _startOrSwitchSession,
                    ),
                    const SizedBox(height: 16),

                    // ---- Quick Actions (pushed up, no dead center panel) ----------
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkPrimary,
                          ),
                    ),
                    const SizedBox(height: 10),

                    _QuickActionsGrid(
                    opacity: _opacity,
                    onAction: (action) {
                      switch (action.title) {
                        case 'New Encounter':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EncounterRegistrationScreen(),
                            ),
                          );
                          return;

                        case 'Search Patients':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PatientSearchScreen(),
                            ),
                          );
                          return;

                        case 'Settings':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                          return;

                        // 🔽 These are analytics → AI
                        case 'Morning Snapshot':
                        case 'Common Illness':
                        case 'Similar Populations':
                          _sendChat(action.aiHint);
                          return;

                        default:
                          // Safe fallback
                          _sendChat(action.aiHint);
                      }
                    },
                  ),

                    const SizedBox(height: 18),

                    // ---- “Today” cards (optional, compact) ------------------------
                    _MiniStatsRow(opacity: _opacity),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================== AI Chat Card ===============================

class _AiChatCard extends StatelessWidget {
  const _AiChatCard({
    required this.sending,
    required this.error,
    required this.msgs,
    required this.scrollController,
    required this.controller,
    required this.onSend,
    required this.opacity,
    required this.activeSession,
    required this.onStartSession,
  });

  final SessionContext? activeSession;
  final VoidCallback onStartSession;
  final bool sending;
  final String? error;
  final List<_ChatMsg> msgs;
  final ScrollController scrollController;
  final TextEditingController controller;
  final Future<void> Function(String prompt) onSend;
  final Color Function(Color, double) opacity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 10,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title row
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppTheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Pulse AI',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.darkPrimary,
                  ),
                ),
                const Spacer(),
                if (activeSession == null)
                  OutlinedButton(
                    onPressed: onStartSession,
                    child: const Text('Start session'),
                  )
                else
                  Flexible(
                    child: Text(
                      activeSession!.unitName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                const SizedBox(width: 16),  
                /*Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: opacity(AppTheme.primary, 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: opacity(AppTheme.primary, 0.25)),
                  ),
                  child: Text(
                    'Offline-first AI',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),*/
              ],
            ),
            const SizedBox(height: 10),
/*
            // Suggested prompts
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _PromptChip(
                  text: 'Encounters this morning',
                  onTap: () => onSend('How many encounters were created this morning?'),
                ),
                _PromptChip(
                  text: 'Top diagnosis today',
                  onTap: () => onSend('List the top 5 diagnoses today with counts.'),
                ),
                _PromptChip(
                  text: 'BM: berapa encounter pagi ini',
                  onTap: () => onSend('Berapa encounter pagi ini?'),
                ),
                _PromptChip(
                  text: 'Trends (7 days)',
                  onTap: () => onSend('Show diagnosis trend for last 7 days.'),
                ),
              ],
            ),
            const SizedBox(height: 12),*/

            // Chat history
            Container(
              height: 320,
              decoration: BoxDecoration(
                color: opacity(AppTheme.background, 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: opacity(AppTheme.primary, 0.16)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final isUser = m.role == _ChatRole.user;

                    final bubbleColor = isUser
                        ? opacity(AppTheme.primary, 0.14)
                        : opacity(Colors.black, 0.05);

                    final borderColor = isUser
                        ? opacity(AppTheme.primary, 0.28)
                        : opacity(Colors.black, 0.12);

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 640),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor),
                        ),
                        child: SelectableText(
                          m.text,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.25,
                                color: AppTheme.darkPrimary,
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Input row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (v) => onSend(v),
                    decoration: InputDecoration(
                      hintText:
                          'Ask: “how many encounters this morning?” / “berapa encounter pagi ini?”',
                      filled: true,
                      fillColor: opacity(AppTheme.background, 0.85),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: opacity(AppTheme.primary, 0.18)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: opacity(AppTheme.primary, 0.18)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: sending ? null : () => onSend(controller.text),
                    icon: sending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(sending ? 'Thinking…' : 'Send'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
/*
class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppTheme.primary.withAlpha(60)),
          color: AppTheme.primary.withAlpha(22),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}
*/
// ============================ Quick Actions ================================

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid({required this.opacity, required this.onAction});

  final Color Function(Color, double) opacity;
  final void Function(_QuickAction action) onAction;

  @override
  Widget build(BuildContext context) {
    final actions = <_QuickAction>[
      const _QuickAction(
        icon: Icons.add_circle_outline,
        title: 'New Encounter',
        subtitle: 'Start a visit',
        aiHint: 'Start a new encounter workflow.',
      ),
      const _QuickAction(
        icon: Icons.search,
        title: 'Search Patients',
        subtitle: 'Find records fast',
        aiHint: 'Open patient search.',
      ),
      const _QuickAction(
        icon: Icons.analytics_outlined,
        title: 'Morning Snapshot',
        subtitle: 'Today’s stats',
        aiHint: 'How many encounters this morning? Group top diagnosis.',
      ),
      const _QuickAction(
        icon: Icons.medical_information_outlined,
        title: 'Common Illness',
        subtitle: 'Top conditions',
        aiHint: 'What sickness is most common today? Provide counts.',
      ),
      const _QuickAction(
        icon: Icons.groups_2_outlined,
        title: 'Similar Populations',
        subtitle: 'Cross-reference',
        aiHint:
            'Cross-reference top diagnoses with similar demographics and show statistics.',
      ),
      const _QuickAction(
        icon: Icons.settings_outlined,
        title: 'Settings',
        subtitle: 'Units & security',
        aiHint: 'Open settings. Show current unit.',
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 900
            ? 3
            : w >= 600
                ? 2
                : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: cols == 1 ? 3.0 : 2.6,
          ),
          itemBuilder: (context, i) {
            final a = actions[i];
            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onAction(a),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: opacity(AppTheme.primary, 0.12)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                      color: Colors.black.withAlpha(18),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: opacity(AppTheme.primary, 0.12),
                      ),
                      child: Icon(a.icon, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // FIX: prevent truncation by allowing 2 lines with ellipsis.
                          Text(
                            a.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.darkPrimary,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            a.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.black.withAlpha(110),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right,
                        color: Colors.black.withAlpha(90)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.aiHint,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String aiHint;
}

// =============================== Header ===================================

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.subtitle, required this.rightBadge});
  final String subtitle;
  final Widget rightBadge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withAlpha(120),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        rightBadge,
      ],
    );
  }
}

class _UserBadge extends StatelessWidget {
  const _UserBadge({required this.username, required this.role});
  final String username;
  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.primary.withAlpha(18),
        border: Border.all(color: AppTheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            username,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.darkPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

// =============================== Mini Stats ================================

class _MiniStatsRow extends StatelessWidget {
  const _MiniStatsRow({required this.opacity});
  final Color Function(Color, double) opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniCard(
            title: 'Today',
            value: '—',
            hint: 'Encounters',
            opacity: opacity,
            icon: Icons.today_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniCard(
            title: 'Top Dx',
            value: '—',
            hint: 'Most common',
            opacity: opacity,
            icon: Icons.monitor_heart_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniCard(
            title: 'Alerts',
            value: '—',
            hint: 'Flags',
            opacity: opacity,
            icon: Icons.warning_amber_rounded,
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.title,
    required this.value,
    required this.hint,
    required this.opacity,
    required this.icon,
  });

  final String title;
  final String value;
  final String hint;
  final Color Function(Color, double) opacity;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: opacity(AppTheme.primary, 0.12)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: opacity(AppTheme.primary, 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.darkPrimary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$value  •  $hint',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black.withAlpha(115),
                        fontWeight: FontWeight.w600,
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

class _SessionGateCard extends StatelessWidget {
  const _SessionGateCard({
    required this.loading,
    required this.error,
    required this.active,
    required this.unitsCount,
    required this.onStartOrSwitch,
    required this.onEnd,
  });

  final bool loading;
  final String? error;
  final SessionContext? active;
  final int unitsCount;
  final VoidCallback onStartOrSwitch;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    final expiry = active?.expiresAt;

    String fmt(DateTime d) => DateFormat('d MMM, HH:mm').format(d);

    return Card(
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: _borderColor(context)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Session Context',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.darkPrimary,
                      ),
                ),
                const Spacer(),
                if (active != null)
                  Text(
                    'Active',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _successColor(context),
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              Text(
                'Session error: $error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _dangerColor(context),
                      fontWeight: FontWeight.w700,
                    ),
              )
            else if (active == null) ...[
              Text(
                'No active session. Start a session to scope access (unit assignment) and prevent browsing.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedText(context),
                    ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: unitsCount == 0 ? null : onStartOrSwitch,
                icon: const Icon(Icons.play_arrow),
                label: Text(unitsCount == 0 ? 'No unit assigned' : 'Start Session'),
              ),
            ] else ...[
              Text(
                active!.unitName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkPrimary,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                expiry == null
                    ? 'Expires: —'
                    : 'Expires: ${fmt(expiry)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _mutedText(context),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onStartOrSwitch,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Switch'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onEnd,
                      icon: const Icon(Icons.stop_circle),
                      label: const Text('End'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
// ============================== ECG Grid ==================================

class ECGGridPainter extends CustomPainter {
  ECGGridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const grid = 20.0;
    for (double x = 0; x < size.width; x += grid) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += grid) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final bold = Paint()
      ..color = color.withAlpha((color.alpha * 1.6).clamp(0, 255).toInt())
      ..strokeWidth = 2;

    for (double x = 0; x < size.width; x += grid * 5) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), bold);
    }
    for (double y = 0; y < size.height; y += grid * 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), bold);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================== Chat Model ================================

enum _ChatRole { user, assistant }

class _ChatMsg {
  _ChatMsg({required this.role, required this.text, required this.at});
  final _ChatRole role;
  final String text;
  final DateTime at;
}
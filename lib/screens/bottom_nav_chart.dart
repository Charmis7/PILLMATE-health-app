import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../wellbeing_service.dart';
import 'tracker_model.dart';
import 'tracker_service.dart';
import 'notification_service.dart';

class bottom_nav_chart extends StatelessWidget {
  const bottom_nav_chart({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [

          // ── MEASUREMENTS & ACTIVITIES ─────────────────────────────────
          // FIRESTORE: StreamBuilder listens to TrackerService.streamTrackers()
          // Every time a tracker is added or deleted, this rebuilds automatically
          StreamBuilder<List<TrackerEntry>>(
            stream: TrackerService.streamTrackers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // FIRESTORE: snapshot.data = latest list. ?? [] = safe fallback
              final trackers     = snapshot.data ?? [];
              final measurements = trackers.where((t) => t.type == 'measurement').toList();
              final activities   = trackers.where((t) => t.type == 'activity').toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Measurements ────────────────────────────────────
                  if (measurements.isNotEmpty) ...[
                    _sectionTitle("📊 Measurements", measurements.length, context),
                    const SizedBox(height: 6),
                    ...measurements.map((t) => _buildTrackerDismissible(t, context)),
                    const SizedBox(height: 16),
                  ],

                  // ── Activities ───────────────────────────────────────
                  if (activities.isNotEmpty) ...[
                    _sectionTitle("🏃 Activities", activities.length, context),
                    const SizedBox(height: 6),
                    ...activities.map((t) => _buildTrackerDismissible(t, context)),
                    const SizedBox(height: 16),
                  ],

                  if (trackers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.track_changes, size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No trackers set yet.",
                                style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text("Tap + to add one",
                                style: TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // ── WELLBEING LOGS ────────────────────────────────────────────
          // FIRESTORE: second StreamBuilder — independent real-time stream
          StreamBuilder<List<WellbeingEntry>>(
            stream: WellbeingService.streamEntries(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox();
              }

              final entries = snapshot.data ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle("😊 Well-being Logs", entries.length, context),
                  const SizedBox(height: 6),
                  if (entries.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.sentiment_satisfied_alt,
                                size: 60, color: Colors.grey),
                            SizedBox(height: 10),
                            Text("No well-being logs yet.",
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...entries.map((e) => _buildWellbeingDismissible(e, context)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Section title with count + swipe hint ─────────────────────────────────
  Widget _sectionTitle(String text, int count, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(text,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.grey)),
          const SizedBox(width: 6),
          // count badge — same idea as homepage showing number of items
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFF5D9CFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("$count",
                style: const TextStyle(
                    color: Color(0xFF5D9CFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const Spacer(),
          Icon(Icons.swipe_left, size: 13, color: Colors.grey[400]),
          const SizedBox(width: 3),
          Text("swipe to delete",
              style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }

  // ── Tracker Dismissible wrapper ───────────────────────────────────────────
  Widget _buildTrackerDismissible(TrackerEntry entry, BuildContext context) {
    return Dismissible(
      key      : Key(entry.id),
      direction: DismissDirection.endToStart, // swipe LEFT = delete

      // Red background revealed while swiping
      background: Container(
        alignment : Alignment.centerRight,
        padding   : const EdgeInsets.symmetric(horizontal: 20),
        margin    : const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color       : Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Delete",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),

      // Confirm dialog before deleting
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title  : const Text("Delete Tracker?"),
            content: Text(
                "Remove '${entry.title}' and cancel all its reminders?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },

      // After confirmed — cancel notifications FIRST then delete from Firestore
      onDismissed: (direction) async {
        // LOCAL NOTIFICATIONS: cancel alarms for this tracker
        await NotificationService.cancelTrackingNotifications(
          baseId: NotificationService.idFromDocId(entry.id),
          count : entry.times.length,
        );
        // FIRESTORE: delete the tracker document permanently
        await TrackerService.deleteTracker(entry.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("🗑️ ${entry.title} deleted")),
        );
      },

      // The actual card — same style as homepage medicine card
      child: _TrackerCard(entry: entry, context: context),
    );
  }

  // ── Wellbeing Dismissible wrapper ─────────────────────────────────────────
  Widget _buildWellbeingDismissible(WellbeingEntry entry, BuildContext context) {
    return Dismissible(
      key      : Key(entry.id),
      direction: DismissDirection.endToStart,

      background: Container(
        alignment : Alignment.centerRight,
        padding   : const EdgeInsets.symmetric(horizontal: 20),
        margin    : const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color       : Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text("Delete",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.delete, color: Colors.white),
          ],
        ),
      ),

      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title  : const Text("Delete Log?"),
            content: const Text("Remove this well-being entry?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        );
      },

      onDismissed: (direction) async {
        // FIRESTORE: delete wellbeing document permanently
        await WellbeingService.deleteEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Log deleted")),
        );
      },

      child: _WellbeingCard(entry: entry, context: context),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TRACKER CARD — same style as _MedicineCard in homepage_screen.dart
// ══════════════════════════════════════════════════════════════════════════════
class _TrackerCard extends StatelessWidget {
  final TrackerEntry entry;
  final BuildContext context;

  const _TrackerCard({required this.entry, required this.context});

  // Builds the time display string — same approach as homepage _buildTimeDisplay()
  String _buildTimeDisplay() {
    return entry.times.map((t) {
      final h      = t.hour;
      final m      = t.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour   = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:$m $period';
    }).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final isMeasurement = entry.type == 'measurement';

    return Card(
      // same Card style as homepage
      shape    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin   : const EdgeInsets.only(bottom: 12),
      color    : Colors.white,
      elevation: 1,
      child    : ListTile(
        // same CircleAvatar leading as homepage
        leading: CircleAvatar(
          backgroundColor: isMeasurement
              ? const Color(0xFF5D9CFF).withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          child: Icon(
            isMeasurement ? Icons.monitor_heart : Icons.directions_run,
            color: isMeasurement
                ? const Color(0xFF5D9CFF)
                : Colors.orange,
          ),
        ),

        // title same bold style as homepage medicine name
        title: Text(
          entry.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),

        // subtitle shows time + frequency — same two-line approach as homepage
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _buildTimeDisplay(),
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            Text(
              entry.frequency,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),

        // same trailing chevron as homepage
        trailing    : Icon(Icons.chevron_left, color: Colors.grey[400], size: 18),
        isThreeLine : true,
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WELLBEING CARD — same style as _MedicineCard in homepage_screen.dart
// ══════════════════════════════════════════════════════════════════════════════
class _WellbeingCard extends StatelessWidget {
  final WellbeingEntry entry;
  final BuildContext   context;

  const _WellbeingCard({required this.entry, required this.context});

  @override
  Widget build(BuildContext context) {
    return Card(
      // same Card style as homepage
      shape    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin   : const EdgeInsets.only(bottom: 12),
      color    : Colors.white,
      elevation: 1,
      child    : ListTile(
        // emoji as leading — same CircleAvatar size feel
        leading: CircleAvatar(
          backgroundColor: Colors.purple.withOpacity(0.1),
          child: Text(entry.mood, style: const TextStyle(fontSize: 22)),
        ),

        // date as bold title — same as homepage medicine name
        title: Text(
          DateFormat('MMM d, y').format(entry.date),
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),

        // time + symptoms as subtitle — same two-line approach
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.time,
              style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
            ),
            Text(
              entry.symptoms.isNotEmpty
                  ? entry.symptoms
                  : "No symptoms noted",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines  : 1,
              overflow  : TextOverflow.ellipsis,
            ),
          ],
        ),

        trailing    : Icon(Icons.chevron_left, color: Colors.grey[400], size: 18),
        isThreeLine : true,
      ),
    );
  }
}
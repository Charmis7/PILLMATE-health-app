import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pillmate_college/screens/routine_screen.dart';
import 'bottom_nav_profile.dart';
import 'medicine_model.dart';
import 'medicine_service.dart';
import 'notification_service.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1EBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5D9CFF),
        elevation: 0,
        title: const Text(
          "PILLMATE",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: [
        HomeContent(
          selectedDate: _selectedDate,
          onDateSelected: (date) => setState(() => _selectedDate = date),
        ),
        const Center(child: Text("Notifications & Updates")),
        const Center(child: Text("Medicine Inventory")),
        const bottom_nav_profile(),
      ][_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5D9CFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutineSetupScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D9CFF),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: "Updates"),
          BottomNavigationBarItem(icon: Icon(Icons.add_chart), label: "Chart"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const HomeContent({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Horizontal date strip ──────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(14, (index) {
                final day = DateTime.now().add(Duration(days: index - 3));
                final isSelected = DateFormat('ddMMyy').format(day) ==
                    DateFormat('ddMMyy').format(selectedDate);
                return GestureDetector(
                  onTap: () => onDateSelected(day),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF5D9CFF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          day.day.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Swipe hint legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.swipe_right, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text("Swipe right = mark taken   |   Swipe left = delete",
                  style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Real-time medicine list from Firestore ─────────────────────
        Expanded(
          child: StreamBuilder<List<MedicineEntry>>(
            stream: MedicineService.streamMedicines(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              final medicines = snapshot.data ?? [];

              if (medicines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication_liquid, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 10),
                      const Text("No medications added yet.", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      const Text("Tap + to add your first medicine",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final med = medicines[index];
                  final isTaken = med.isTakenToday();

                  return Dismissible(
                    key: Key(med.id),
                    // Both directions enabled
                    direction: DismissDirection.horizontal,

                    // LEFT swipe = mark taken (green)
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isTaken ? Colors.orange : Colors.green,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(isTaken ? Icons.undo : Icons.check, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            isTaken ? "Undo taken" : "Mark taken",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    // RIGHT swipe = delete (red)
                    secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("Delete", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.delete, color: Colors.white),
                        ],
                      ),
                    ),

                    confirmDismiss: (direction) async {
                      // LEFT swipe → mark/unmark taken, don't dismiss
                      if (direction == DismissDirection.startToEnd) {
                        if (isTaken) {
                          await MedicineService.unmarkTaken(med.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("↩️ ${med.name} marked as not taken")),
                          );
                        } else {
                          await MedicineService.markTakenToday(med.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("✅ ${med.name} marked as taken!")),
                          );
                        }
                        return false; // stay in list
                      }

                      // RIGHT swipe → confirm delete dialog
                      if (direction == DismissDirection.endToStart) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text("Delete Medicine?"),
                            content: Text(
                              "This will permanently remove ${med.name} and cancel all its reminders.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Cancel notifications for this medicine
                          await NotificationService.cancelMedicineNotifications(
                            notificationBaseId: NotificationService.idFromDocId(med.id),
                            intakeCount: med.intakes.length,
                          );
                          // Delete from Firestore
                          await MedicineService.deleteMedicine(med.id);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("🗑️ ${med.name} deleted")),
                          );
                          return true; // remove from list
                        }
                        return false; // user cancelled
                      }

                      return false;
                    },

                    child: _MedicineCard(med: med, isTaken: isTaken),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final MedicineEntry med;
  final bool isTaken;

  const _MedicineCard({required this.med, required this.isTaken});

  String _buildSubtitle() {
    if (med.frequency == 'asneeded') {
      return 'As needed • ${med.intakes.first.dose} ${med.unit}';
    }
    final labels = med.intakes.map((i) => i.label).join(' & ');
    final doses = med.intakes.map((i) => '${i.dose} ${med.unit}').toSet().join(' / ');
    return '$labels • $doses';
  }

  String _buildTimeDisplay() {
    if (med.frequency == 'asneeded') return 'When needed';
    return med.intakes.map((i) {
      final h = i.time.hour;
      final m = i.time.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'PM' : 'AM';
      final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$hour:$m $period';
    }).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      color: isTaken ? Colors.grey[100] : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isTaken
              ? Colors.green.withOpacity(0.15)
              : const Color(0xFF5D9CFF).withOpacity(0.1),
          child: Icon(
            isTaken ? Icons.check_circle : Icons.medication,
            color: isTaken ? Colors.green : const Color(0xFF5D9CFF),
          ),
        ),
        title: Text(
          med.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isTaken ? TextDecoration.lineThrough : null,
            color: isTaken ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_buildTimeDisplay(),
                style: const TextStyle(fontSize: 13, color: Colors.blueGrey)),
            Text(_buildSubtitle(),
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: isTaken
            ? const Text("Done ✓",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12))
            : Icon(Icons.chevron_left, color: Colors.grey[400], size: 18),
        isThreeLine: true,
      ),
    );
  }
}
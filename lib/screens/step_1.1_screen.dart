import 'package:flutter/material.dart';
import 'package:pillmate_college/screens/step_1.2_screen.dart';

class Step_1 extends StatefulWidget {
  const Step_1({super.key});

  @override
  State<Step_1> createState() => _Step_1State();
}

class _Step_1State extends State<Step_1> {
  String? selectedMed;
  String? selectedUnit = "Pill(s)";
  String? selectedCondition;

  // ✅ Medicine categories map
  final Map<String, List<String>> medicineCategories = {
    "Pain / Fever": [
      "Aspirin", "Paracetamol", "Ibuprofen", "Dolo 650", "Crocin", "Calpol",
      "Combiflam", "Brufen", "Disprin", "Saridon", "Voveran", "Diclofenac", "Naproxen",
    ],
    "Cold & Cough": ["Sinarest", "D-Cold", "Cheston Cold", "Ascoril", "Alex", "Benadryl", "Grilinctus"],
    "Allergy": ["Cetirizine", "Allegra", "Avil", "Montair", "Levocetrizine", "Loratadine"],
    "Antibiotics": ["Amoxicillin", "Azithromycin", "Ciprofloxacin", "Augmentin", "Moxikind", "Zifi", "Norflox", "Doxycycline", "Cephalexin"],
    "Diabetes": ["Metformin", "Glimepiride", "Glipizide", "Insulin", "Januvia"],
    "Blood Pressure": ["Amlodipine", "Atenolol", "Metoprolol", "Losartan", "Telmisartan", "Lisinopril", "Telma", "Amlong"],
    "Cholesterol / Heart Protection": ["Atorvastatin", "Rosuvastatin", "Simvastatin", "Storvas", "Clopidogrel", "Ecosprin"],
    "Stomach / Acidity / Gas": ["Omeprazole", "Pantoprazole", "Ranitidine", "Esomeprazole", "Pan", "Pantocid", "Digene", "Eno"],
    "Vitamins & Supplements": ["Vitamin D3", "Vitamin B12", "Vitamin C", "Calcium", "Iron", "Folic Acid", "Becosules", "Shelcal", "Zincovit"],
    "Thyroid": ["Levothyroxine", "Eltroxin", "Thyronorm"],
    "Asthma / Breathing": ["Albuterol", "Salbutamol", "Montelukast", "Asthalin"],
  };

  @override
  Widget build(BuildContext context) {
    // Flatten the map to a single list for dropdown
    List<String> medicineItems = medicineCategories.values.expand((list) => list).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBBDEFB),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Hero(
                  tag: 'app_logo',
                  child: Image.asset('assets/images/img_2.png', height: 120),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Enter medicine details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A374D)),
                ),
                const SizedBox(height: 8),
                const Text(
                  "How should your health condition be measured?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 35),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Medicine Name Dropdown
                        _buildGlassDropdown(
                          hint: "Medicine Name",
                          value: selectedMed,
                          items: medicineItems,
                          onChanged: (val) => setState(() => selectedMed = val),
                        ),
                        const SizedBox(height: 20),
                        // Unit Dropdown
                        _buildGlassDropdown(
                          hint: "Unit",
                          value: selectedUnit,
                          items: ["Pill(s)", "Tablet(s)", "Spoon", "ML", "Capsule(s)"],
                          onChanged: (val) => setState(() => selectedUnit = val),
                        ),
                        const SizedBox(height: 20),
                        // Health Condition Dropdown
                        _buildGlassDropdown(
                          hint: "Health Condition",
                          value: selectedCondition,
                          items: [
                            "Fever", "Headache", "Blood Pressure", "High Cholesterol",
                            "Acidity", "Allergies", "Mental Health"
                          ],
                          onChanged: (val) => setState(() => selectedCondition = val),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5D9CFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        if (selectedMed != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Step_2(
                                medicineName: selectedMed!,
                                unit: selectedUnit ?? "Pill(s)",
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please select a medicine"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Next",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Glass-style Dropdown helper
  Widget _buildGlassDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint, style: const TextStyle(color: Colors.black45)),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF5D9CFF)),
      dropdownColor: const Color(0xFFF5F9FF),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF5D9CFF), width: 1.5),
        ),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: onChanged,
    );
  }
}
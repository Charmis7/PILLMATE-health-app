import 'package:flutter/material.dart';
import 'step_1.2_screen.dart';

class Step_1 extends StatefulWidget {
  const Step_1({super.key});

  @override
  State<Step_1> createState() => _Step_1State();
}

class _Step_1State extends State<Step_1> {
  String? selectedMed;
  String? selectedUnit = "Pill(s)";
  String? selectedCondition;

  final Map<String, List<String>> medicineCategories = {
    "Pain / Fever": ["Aspirin","Paracetamol","Ibuprofen","Dolo 650","Crocin","Calpol","Combiflam","Brufen","Disprin","Saridon","Voveran","Diclofenac","Naproxen"],
    "Cold & Cough": ["Sinarest","D-Cold","Cheston Cold","Ascoril","Alex","Benadryl","Grilinctus"],
    "Allergy": ["Cetirizine","Allegra","Avil","Montair","Levocetrizine","Loratadine"],
    "Antibiotics": ["Amoxicillin","Azithromycin","Ciprofloxacin","Augmentin","Moxikind","Zifi","Norflox","Doxycycline","Cephalexin"],
    "Diabetes": ["Metformin","Glimepiride","Glipizide","Insulin","Januvia"],
    "Blood Pressure": ["Amlodipine","Atenolol","Metoprolol","Losartan","Telmisartan","Lisinopril","Telma","Amlong"],
    "Cholesterol / Heart Protection": ["Atorvastatin","Rosuvastatin","Simvastatin","Storvas","Clopidogrel","Ecosprin"],
    "Stomach / Acidity / Gas": ["Omeprazole","Pantoprazole","Ranitidine","Esomeprazole","Pan","Pantocid","Digene","Eno"],
    "Vitamins & Supplements": ["Vitamin D3","Vitamin B12","Vitamin C","Calcium","Iron","Folic Acid","Becosules","Shelcal","Zincovit"],
    "Thyroid": ["Levothyroxine","Eltroxin","Thyronorm"],
    "Asthma / Breathing": ["Albuterol","Salbutamol","Montelukast","Asthalin"],
  };

  @override
  Widget build(BuildContext context) {
    List<String> medicineItems =
    medicineCategories.values.expand((list) => list).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFD6EAFE),
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
                  "Select your medicine, unit and condition",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 35),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        simpleDropdown(
                          hint: "Medicine Name",
                          value: selectedMed,
                          items: medicineItems,
                          onChanged: (val) => setState(() => selectedMed = val),
                        ),
                        const SizedBox(height: 20),
                        simpleDropdown(
                          hint: "Unit",
                          value: selectedUnit,
                          items: ["Pill(s)", "Tablet(s)", "Spoon", "ML", "Capsule(s)"],
                          onChanged: (val) => setState(() => selectedUnit = val),
                        ),
                        const SizedBox(height: 20),
                        simpleDropdown(
                          hint: "Health Condition",
                          value: selectedCondition,
                          items: ["Fever","Headache","Blood Pressure","High Cholesterol","Acidity","Allergies","Mental Health"],
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
                        if (selectedMed != null && selectedCondition != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Step_2(
                                medicineName: selectedMed!,
                                unit: selectedUnit ?? "Pill(s)",
                                condition: selectedCondition!, // ← pass condition
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select medicine and health condition")),
                          );
                        }
                      },
                      child: const Text("Next", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget simpleDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      hint: Text(hint),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _institution = "";
  String _level = "S1";
  String _studyField = "";
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _levels = ['SMA', 'D3', 'S1', 'S2', 'S3'];

  // Text editing controller is how you see text being displayed
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  // This makes YYYY-MM-DD
  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _institution = "";
      _level = "S1";
      _studyField = "";
      _startDate = null;
      _endDate = null;
      _startDateController.clear();
      _endDateController.clear();
    });
  }

  void _goBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // opened from the card: go back
    } else {
      Navigator.pushReplacement(
        // opened from the drawer: nothing to go back to
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  // Frees the controller when the page closes
  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Education Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Institution Name
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Nama Institusi",
                    labelText: "Nama Institusi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() => _institution = value!);
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama institusi tidak boleh kosong!";
                    }
                    if (value.trim().length > 100) {
                      return "Nama institusi maksimal 100 karakter!";
                    }
                    return null;
                  },
                ),
              ),
              // Levels
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Tingkat Edukasi",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _level,
                  items: _levels
                      .map(
                        (level) =>
                            DropdownMenuItem(value: level, child: Text(level)),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() => _level = newValue!);
                  },
                ),
              ),
              // Field of study
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Jurusan / Bidang Studi",
                    labelText: "Jurusan / Bidang Studi (Optional)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() => _studyField = value!);
                  },
                  validator: (String? value) {
                    if ((value ?? "").trim().length > 100) {
                      return "Jurusan maksimal 100 karakter!";
                    }
                    return null;
                  },
                ),
              ),
              // Start date
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Tanggal Mulai",
                    hintText: "Pilih tanggal",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime.now(),
                    );
                    if (!mounted) return;
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                        _startDateController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_startDate == null) {
                      return "Tanggal mulai harus dipilih!";
                    }
                    return null;
                  },
                ),
              ),

              // End date
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Tanggal Berakhir",
                    hintText: "Pilih tanggal",
                    suffixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(1990),
                      lastDate: DateTime(2050),
                    );
                    if (!mounted) return;
                    if (picked != null) {
                      setState(() {
                        _endDate = picked;
                        _endDateController.text = _formatDate(picked);
                      });
                    }
                  },
                  validator: (String? value) {
                    if (_endDate == null) {
                      return "Tanggal berakhir harus dipilih!";
                    }
                    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                      return "Tanggal berakhir tidak boleh sebelum tanggal mulai!";
                    }
                    return null;
                  },
                ),
              ),

              // Buttons
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _goBack,
                        child: const Text('Kembali'),
                      ),
                      OutlinedButton(
                        onPressed: _resetForm,
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.indigo,
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Data edukasi tersimpan!'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Institusi: $_institution'),
                                        Text('Tingkat: $_level'),
                                        Text(
                                          'Jurusan: ${_studyField.trim().isEmpty ? "-" : _studyField}',
                                        ),
                                        Text(
                                          'Tanggal Mulai: ${_formatDate(_startDate!)}',
                                        ),
                                        Text(
                                          'Tanggal Berakhir: ${_formatDate(_endDate!)}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _resetForm();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        child: const Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

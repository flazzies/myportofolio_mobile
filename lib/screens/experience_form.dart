import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/experience.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  final _startedController = TextEditingController();
  final _endedController = TextEditingController();

  // Samakan dengan CATEGORY_CHOICES di model Django kamu.
  static const _categories = <String, String>{
    'full-time': 'Full-time',
    'part-time': 'Part-time',
    'internship': 'Internship',
    'freelance': 'Freelance',
  };

  String _category = 'full-time';
  DateTime? _startedAt;
  DateTime? _endedAt;
  bool _isOngoing = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _startedController.dispose();
    _endedController.dispose();
    super.dispose();
  }

  bool _isValidUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startedAt : _endedAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startedAt = picked;
        _startedController.text = _fmt(picked);
      } else {
        _endedAt = picked;
        _endedController.text = _fmt(picked);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final api = context.read<ApiClient>();
    final auth = context.read<AuthState>();
    final messenger = ScaffoldMessenger.of(context);

    final ok = await ensureLoggedIn(context);
    if (!ok || !mounted) return;
    final token = auth.token;
    if (token == null) return;

    final thumbnail = _thumbnailController.text.trim();
    final newExperience = Experience(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      thumbnail: thumbnail.isEmpty ? null : thumbnail,
      startedAt: _startedAt,
      endedAt: _isOngoing ? null : _endedAt,
    );

    setState(() => _isSubmitting = true);

    try {
      final created = await api.createExperience(newExperience, token: token);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Experience created!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${created.title}'),
                Text('Category: ${created.category}'),
                if (created.startedAt != null)
                  Text('Started: ${_fmt(created.startedAt!)}'),
                if (created.endedAt != null)
                  Text('Ended: ${_fmt(created.endedAt!)}'),
                if (created.isOngoing == true) const Text('Status: Ongoing'),
                if (created.thumbnail != null && created.thumbnail!.isNotEmpty)
                  Text('Thumbnail: ${created.thumbnail}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, true); // true = ada data baru, list perlu refresh
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token invalid/expired: hapus sesi dan minta login ulang.
        await auth.logout();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
          ),
        );
        if (!mounted) return;
        await ensureLoggedIn(context);
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to create experience (${e.statusCode})'),
          ),
        );
      }
    } catch (_) {
      // Error jaringan (server mati, API_BASE_URL salah, dll.)
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not reach the server.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint ?? label,
          labelText: label,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        validator: validator,
      ),
    );
  }

  String? _required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName cannot be empty!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Experience Form'),
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
              _field(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g. Backend Developer Intern',
                validator: (v) => _required(v, 'Title'),
              ),
              _field(
                controller: _descriptionController,
                label: 'Description',
                maxLines: 5,
                validator: (v) => _required(v, 'Description'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _category, // Flutter lama: ganti ke `value:`
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  items: _categories.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
              ),
              _field(
                controller: _thumbnailController,
                label: 'Thumbnail URL (Optional)',
                hint: 'https://example.com/image.png',
                keyboardType: TextInputType.url,
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return null; // optional
                  if (!_isValidUrl(value)) {
                    return 'Enter a valid URL (http:// or https://)';
                  }
                  return null;
                },
              ),
              _field(
                controller: _startedController,
                label: 'Started At',
                hint: 'Select start date',
                readOnly: true,
                onTap: () => _pickDate(isStart: true),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => _required(v, 'Start date'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Currently ongoing'),
                  value: _isOngoing,
                  onChanged: (v) => setState(() {
                    _isOngoing = v ?? false;
                    if (_isOngoing) {
                      _endedAt = null;
                      _endedController.clear();
                    }
                  }),
                ),
              ),
              if (!_isOngoing)
                _field(
                  controller: _endedController,
                  label: 'Ended At (Optional)',
                  hint: 'Select end date',
                  readOnly: true,
                  onTap: () => _pickDate(isStart: false),
                  suffixIcon: const Icon(Icons.event),
                  validator: (_) {
                    if (_endedAt != null &&
                        _startedAt != null &&
                        _endedAt!.isBefore(_startedAt!)) {
                      return 'End date cannot be before start date';
                    }
                    return null;
                  },
                ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
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

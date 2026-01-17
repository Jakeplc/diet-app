import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../models/glp1_log.dart';
import '../../services/hive_boxes.dart';

class Glp1TrackerPage extends StatefulWidget {
  const Glp1TrackerPage({super.key});

  @override
  State<Glp1TrackerPage> createState() => _Glp1TrackerPageState();
}

class _Glp1TrackerPageState extends State<Glp1TrackerPage> {
  Box<Glp1Log> get box => HiveBoxes.glp1();

  List<Glp1Log> get logs {
    final list = box.values.toList();
    list.sort((a, b) => b.injectionAt.compareTo(a.injectionAt));
    return list;
  }

  Future<void> _addOrEdit([Glp1Log? existing]) async {
    final saved = await Navigator.of(context).push<Glp1Log>(
      MaterialPageRoute(builder: (_) => Glp1LogEditor(existing: existing)),
    );
    if (saved == null) return;

    await box.put(saved.id, saved);
    if (mounted) setState(() {});
  }

  Future<void> _delete(String id) async {
    await box.delete(id);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = logs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GLP-1 Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Dose log + injection dates + side effects', style: TextStyle(fontWeight: FontWeight.w800)),
                  SizedBox(height: 6),
                  Text('Quick, simple tracking so you don\'t lose your schedule or notes.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('No injections logged yet. Tap “Add injection” to start.'),
            ),

          ...items.map((e) {
            final d = e.injectionAt;
            final date = '${d.month}/${d.day}/${d.year}';
            final time = '${_two(d.hour)}:${_two(d.minute)}';

            return Dismissible(
              key: ValueKey(e.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _delete(e.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                child: const Icon(Icons.delete),
              ),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.vaccines),
                  title: Text('${e.medication} • ${e.doseMg} mg', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('$date • $time'
                      '${e.site.isNotEmpty ? ' • ${e.site}' : ''}'
                      '${e.sideEffects.isNotEmpty ? '\nSide effects: ${e.sideEffects}' : ''}'
                      '${e.notes.isNotEmpty ? '\nNotes: ${e.notes}' : ''}'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _addOrEdit(e),
                ),
              ),
            );
          }),

          const SizedBox(height: 80),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add injection'),
        onPressed: () => _addOrEdit(),
      ),
    );
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}

class Glp1LogEditor extends StatefulWidget {
  final Glp1Log? existing;
  const Glp1LogEditor({super.key, this.existing});

  @override
  State<Glp1LogEditor> createState() => _Glp1LogEditorState();
}

class _Glp1LogEditorState extends State<Glp1LogEditor> {
  final _formKey = GlobalKey<FormState>();

  late DateTime when;
  final medication = TextEditingController();
  final doseMg = TextEditingController();
  final site = TextEditingController();
  final sideEffects = TextEditingController();
  final notes = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    when = e?.injectionAt ?? DateTime.now();
    medication.text = e?.medication ?? '';
    doseMg.text = (e?.doseMg ?? 0).toString().replaceAll('.0', '');
    site.text = e?.site ?? '';
    sideEffects.text = e?.sideEffects ?? '';
    notes.text = e?.notes ?? '';
  }

  @override
  void dispose() {
    medication.dispose();
    doseMg.dispose();
    site.dispose();
    sideEffects.dispose();
    notes.dispose();
    super.dispose();
  }

  double _d(String s) => double.tryParse(s.trim()) ?? 0;

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (d == null) return;

    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(when));
    if (t == null) return;

    setState(() {
      when = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.existing == null ? 'Add injection' : 'Edit injection';
    final date = '${when.month}/${when.day}/${when.year} '
        '${when.hour.toString().padLeft(2, '0')}:${when.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              final id = widget.existing?.id ?? 'glp1_${DateTime.now().microsecondsSinceEpoch}';
              final saved = Glp1Log(
                id: id,
                injectionAt: when,
                medication: medication.text.trim(),
                doseMg: _d(doseMg.text),
                site: site.text.trim(),
                sideEffects: sideEffects.text.trim(),
                notes: notes.text.trim(),
              );
              Navigator.pop(context, saved);
            },
            child: const Text('Save'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Injection date & time', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(date),
              trailing: const Icon(Icons.edit),
              onTap: _pickDateTime,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: medication,
                  decoration: const InputDecoration(labelText: 'Medication (e.g., Wegovy, Ozempic)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: doseMg,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Dose (mg)'),
                  validator: (v) => (_d(v ?? '0') <= 0) ? 'Enter dose' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: site,
                  decoration: const InputDecoration(labelText: 'Injection site (optional)'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sideEffects,
                  decoration: const InputDecoration(labelText: 'Side effects (optional)'),
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  minLines: 1,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

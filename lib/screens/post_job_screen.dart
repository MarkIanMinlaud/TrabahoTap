import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class PostJobScreen extends StatefulWidget {
  final VoidCallback? onPosted;

  const PostJobScreen({super.key, this.onPosted});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _pay = TextEditingController();
  final _vacancies = TextEditingController(text: '1');
  final _description = TextEditingController();
  String _category = 'Construction';

  final _categories = const [
    'Construction',
    'Delivery',
    'Tutoring',
    'Household',
    'Farming',
    'Food Service',
    'Retail',
    'Repair',
  ];

  @override
  void dispose() {
    _title.dispose();
    _pay.dispose();
    _vacancies.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = context.read<AppProvider>();
    final employer = app.currentUser;
    if (employer == null) return;

    await app.postJob(
      title: _title.text.trim(),
      category: _category,
      pay: _pay.text.trim(),
      description: _description.text.trim(),
      employerId: employer.id,
      vacancies: int.parse(_vacancies.text.trim()),
    );

    _title.clear();
    _pay.clear();
    _vacancies.text = '1';
    _description.clear();
    setState(() => _category = 'Construction');

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.check, color: AppColors.text, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Job Posted!', style: AppTextStyles.dialogTitle),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Your job is now visible to workers.',
                textAlign: TextAlign.center,
                style: AppTextStyles.hint,
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
    widget.onPosted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Post a Job', style: AppTextStyles.pageTitle),
              const SizedBox(height: AppSpacing.lg),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(hintText: 'Job title'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(hintText: 'Category'),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _pay,
                decoration: const InputDecoration(
                  hintText: 'Pay (e.g. PHP 500/day)',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _vacancies,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  hintText: 'How many workers do you need?',
                ),
                validator: (v) {
                  final count = int.tryParse(v?.trim() ?? '');
                  if (count == null || count < 1) {
                    return 'Enter at least 1';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _description,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Tell job seekers what you need and who you are looking for',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(onPressed: _submit, child: const Text('Post Job')),
            ],
          ),
        ),
      ),
    );
  }
}

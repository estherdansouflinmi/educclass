// lib/features/resources/presentation/screens/add_resource_screen.dart
import 'dart:io';
import 'package:educclass/core/constants/app_colors.dart';
import 'package:educclass/core/constants/app_strings.dart';
import 'package:educclass/core/utils/file_utils.dart';
import 'package:educclass/core/utils/validators.dart';
import 'package:educclass/core/widgets/app_button.dart';
import 'package:educclass/core/widgets/app_text_field.dart';
import 'package:educclass/features/auth/presentation/providers/auth_provider.dart';
import 'package:educclass/features/resources/domain/models/resource_model.dart';
import 'package:educclass/features/resources/presentation/providers/resource_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddResourceScreen extends ConsumerStatefulWidget {
  const AddResourceScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  ConsumerState<AddResourceScreen> createState() => _AddResourceScreenState();
}

class _AddResourceScreenState extends ConsumerState<AddResourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _urlController = TextEditingController();

  ResourceType _type = ResourceType.pdf;
  File? _selectedFile;
  String? _selectedFileName;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final size = await file.length();
      if (!FileUtils.isValidFileSize(size)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.fileTooLarge)),
          );
        }
        return;
      }
      setState(() {
        _selectedFile = file;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authNotifierProvider).valueOrNull;
    if (user == null) return;

    ResourceModel? result;

    if (_type == ResourceType.pdf) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un fichier PDF')),
        );
        return;
      }
      result = await ref.read(addResourceProvider.notifier).uploadPdf(
            classroomId: widget.classroomId,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            file: _selectedFile!,
            publishedById: user.uid,
            publishedByName: user.displayName,
          );
    } else {
      result = await ref.read(addResourceProvider.notifier).addLink(
            classroomId: widget.classroomId,
            title: _titleController.text.trim(),
            description: _descController.text.trim(),
            url: _urlController.text.trim(),
            type: _type,
            publishedById: user.uid,
            publishedByName: user.displayName,
          );
    }

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ressource publiée avec succès !')),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(addResourceProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(error?.toString() ?? AppStrings.unknownError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addResourceProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addResource)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type selector
                const Text(
                  AppStrings.resourceType,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 10),
                SegmentedButton<ResourceType>(
                  segments: const [
                    ButtonSegment(
                      value: ResourceType.pdf,
                      label: Text('PDF'),
                      icon: Icon(Icons.picture_as_pdf_outlined),
                    ),
                    ButtonSegment(
                      value: ResourceType.link,
                      label: Text('Lien'),
                      icon: Icon(Icons.link),
                    ),
                    ButtonSegment(
                      value: ResourceType.video,
                      label: Text('Vidéo'),
                      icon: Icon(Icons.play_circle_outline),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) =>
                      setState(() => _type = s.first),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: AppStrings.resourceTitle,
                  controller: _titleController,
                  validator: (v) =>
                      Validators.required(v, 'Titre de la ressource'),
                  prefixIcon: const Icon(Icons.title),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: AppStrings.resourceDescription,
                  controller: _descController,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                const SizedBox(height: 16),
                if (_type == ResourceType.pdf) ...[
                  GestureDetector(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedFile != null
                              ? AppColors.success
                              : AppColors.grey300,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedFile != null
                            ? AppColors.success.withOpacity(0.05)
                            : AppColors.grey50,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedFile != null
                                ? Icons.check_circle_outline
                                : Icons.upload_file,
                            color: _selectedFile != null
                                ? AppColors.success
                                : AppColors.grey400,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedFile != null
                                      ? _selectedFileName ?? 'Fichier sélectionné'
                                      : AppStrings.selectFile,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: _selectedFile != null
                                        ? AppColors.grey800
                                        : AppColors.grey500,
                                  ),
                                ),
                                if (_selectedFile == null)
                                  const Text(
                                    'Fichiers PDF uniquement (max 50MB)',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.grey400),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isLoading && _uploadProgress > 0) ...[
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Envoi : ${(_uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grey600),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: _uploadProgress,
                          backgroundColor: AppColors.grey200,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ] else ...[
                  AppTextField(
                    label: AppStrings.enterUrl,
                    controller: _urlController,
                    keyboardType: TextInputType.url,
                    validator: Validators.url,
                    prefixIcon: const Icon(Icons.link),
                    textInputAction: TextInputAction.done,
                  ),
                ],
                const SizedBox(height: 32),
                AppButton(
                  label: 'Publier la ressource',
                  onPressed: _submit,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

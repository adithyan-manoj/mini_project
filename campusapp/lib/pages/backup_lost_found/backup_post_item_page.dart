import 'dart:io';
import 'package:campusapp/core/app_colors.dart';
import 'package:campusapp/services/backup_api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class BackupPostItemPage extends StatefulWidget {
  const BackupPostItemPage({super.key});

  @override
  State<BackupPostItemPage> createState() => _BackupPostItemPageState();
}

class _BackupPostItemPageState extends State<BackupPostItemPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'lost';
  String _itemName = '';
  String _location = '';
  String _phoneNumber = '';
  File? _selectedImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    
    // Attempt to get user ID
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to report an item.')),
        );
      }
      return;
    }
    final userId = user.id;

    String? imageUrl;

    try {
      if (_selectedImage != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user?.id ?? 'anon'}.jpg';
        await Supabase.instance.client.storage
            .from('backup_lost_found_images')
            .upload(fileName, _selectedImage!);
        
        imageUrl = Supabase.instance.client.storage
            .from('backup_lost_found_images')
            .getPublicUrl(fileName);
      }

      await BackupApiService.createBackupItem({
        'item_name': _itemName,
        'type': _type,
        'location': _location,
        'phone_number': _phoneNumber,
        'user_id': userId,
        'status': 'open',
        'image_url': imageUrl,
      });

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, true); // Pop back to list and trigger reload
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item reported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting item: $e')),
        );
      }
    }
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
    child: Text(
      text,
      style: GoogleFonts.robotoFlex(
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: false,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  Widget _buildTextField(
      String label, 
      String hint, 
      Function(String?) onSaved, 
      {TextInputType kbType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          style: const TextStyle(color: Colors.white),
          keyboardType: kbType,
          decoration: _inputDeco(hint),
          validator: (val) => val!.trim().isEmpty ? 'Required' : null,
          onSaved: onSaved,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Item',
          style: GoogleFonts.oswald(textStyle: const TextStyle(fontSize: 28, color: Colors.white)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLabel('What are you reporting?'),
                    const SizedBox(height: 4),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'lost', label: Text('I Lost Something')),
                        ButtonSegment(
                            value: 'found', label: Text('I Found Something')),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _type = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return _type == 'lost'
                                  ? Colors.red[100]!
                                  : Colors.green[100]!;
                            }
                            return const Color.fromARGB(255, 40, 40, 40);
                          },
                        ),
                        foregroundColor:
                            WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return _type == 'lost'
                                  ? Colors.red[900]!
                                  : Colors.green[900]!;
                            }
                            return Colors.white;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      'Item Name',
                      'e.g. Blue Umbrella, Wallet, Keys',
                      (val) => _itemName = val!,
                    ),
                    _buildTextField(
                      'Location',
                      'Where did you lose/find it?',
                      (val) => _location = val!,
                    ),
                    _buildTextField(
                      'Contact Phone Number',
                      'e.g. +91 9876543210',
                      (val) => _phoneNumber = val!,
                      kbType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildLabel('Attachment (Optional)'),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_selectedImage!,
                                    fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo,
                                      color: Colors.white54, size: 40),
                                  SizedBox(height: 8),
                                  Text(
                                    'Tap to add an image',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submit,
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

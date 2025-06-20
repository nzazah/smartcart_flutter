import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    setState(() {
      _nameController.text = profile['name'] ?? '';
      _phoneController.text = profile['phone'] ?? '';
      _emailController.text = user.email ?? '';
      _uploadedImageUrl = profile['image'];
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final file = File(pickedFile.path);
    final fileExt = path.extension(file.path);
    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}$fileExt';
    final filePath = 'avatars/$fileName';
    final mimeType = lookupMimeType(file.path);

    // Upload ke Supabase Storage
    await Supabase.instance.client.storage.from('avatars').uploadBinary(
      filePath,
      await file.readAsBytes(),
      fileOptions: FileOptions(contentType: mimeType),
    );

    // Ambil URL public
    final imageUrl =
    Supabase.instance.client.storage.from('avatars').getPublicUrl(filePath);

    // Simpan URL ke kolom image di profiles
    await Supabase.instance.client.from('profiles').upsert({
      'id': user.id,
      'image': imageUrl,
    });

    setState(() {
      _selectedImage = file;
      _uploadedImageUrl = imageUrl;
    });
  }

  Future<void> _saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'name': _nameController.text,
        'phone': _phoneController.text,
        'image': _uploadedImageUrl, // pastikan tetap disimpan saat update
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
    final double padding = isTablet ? 24 : 16;
    final double fontSize = isTablet ? 18 : 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(padding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_uploadedImageUrl != null
                          ? NetworkImage(_uploadedImageUrl!) as ImageProvider
                          : const AssetImage('assets/default_avatar.png')),
                    ),
                    TextButton(
                      onPressed: _pickAndUploadImage,
                      child: const Text('Change Photo'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Username'),
                style: TextStyle(fontSize: fontSize),
                validator: (value) => value!.isEmpty ? 'Username cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Email (readonly)'),
                style: TextStyle(fontSize: fontSize),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                style: TextStyle(fontSize: fontSize),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveUserData,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text('Save Changes', style: TextStyle(fontSize: fontSize)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

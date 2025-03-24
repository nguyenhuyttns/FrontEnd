// lib/views/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../view_models/user_view_model.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isInitialized = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Don't call getUserProfile directly in initState
    // Instead, use a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_isInitialized) return;

    setState(() {
      _isLoading = true;
    });

    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    await userViewModel.getUserProfile();
    _populateFormFields();

    setState(() {
      _isLoading = false;
      _isInitialized = true;
    });
  }

  void _populateFormFields() {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final user = userViewModel.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _streetController.text = user.street;
      _apartmentController.text = user.apartment;
      _zipController.text = user.zip;
      _cityController.text = user.city;
      _countryController.text = user.country;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _apartmentController.dispose();
    _zipController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final updatedUser = User(
        id: userViewModel.user?.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        isAdmin: userViewModel.user?.isAdmin ?? false,
        street: _streetController.text,
        apartment: _apartmentController.text,
        zip: _zipController.text,
        city: _cityController.text,
        country: _countryController.text,
      );

      final password =
          _passwordController.text.isNotEmpty ? _passwordController.text : null;

      final success = await userViewModel.updateUserProfile(
        updatedUser,
        password: password,
      );

      setState(() {
        _isLoading = false;
        if (success) {
          _isEditing = false;
          _passwordController.clear();
        }
      });

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(userViewModel.errorMessage)));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              )
            else
              IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () {
                  setState(() {
                    _isEditing = false;
                    _populateFormFields();
                    _passwordController.clear();
                  });
                },
              ),
          ],
        ),
        body: Consumer<UserViewModel>(
          builder: (context, userViewModel, _) {
            if (!_isInitialized && userViewModel.isBusy) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userViewModel.isError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userViewModel.errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadUserProfile,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (userViewModel.user == null) {
              return const Center(
                child: Text('No profile information available'),
              );
            }

            return _buildProfileForm(context, userViewModel.user!);
          },
        ),
        bottomNavigationBar:
            _isEditing
                ? Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  Widget _buildProfileForm(BuildContext context, User user) {
    // The rest of the method remains the same as before
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                if (user.isAdmin)
                  Chip(
                    label: const Text('Admin'),
                    backgroundColor: Colors.blue[100],
                    labelStyle: TextStyle(color: Colors.blue[800]),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Personal Information Section
          const Text(
            'Personal Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Name
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            prefixIcon: Icons.person,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Phone
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Address Section
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Address Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Street
          CustomTextField(
            controller: _streetController,
            label: 'Street',
            prefixIcon: Icons.location_on,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your street';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Apartment
          CustomTextField(
            controller: _apartmentController,
            label: 'Apartment/Suite',
            prefixIcon: Icons.home,
            enabled: _isEditing,
          ),
          const SizedBox(height: 16),

          // City
          CustomTextField(
            controller: _cityController,
            label: 'City',
            prefixIcon: Icons.location_city,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your city';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ZIP
          CustomTextField(
            controller: _zipController,
            label: 'ZIP/Postal Code',
            prefixIcon: Icons.markunread_mailbox,
            keyboardType: TextInputType.number,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your ZIP code';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Country
          CustomTextField(
            controller: _countryController,
            label: 'Country',
            prefixIcon: Icons.flag,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your country';
              }
              return null;
            },
          ),

          // Password Section (only when editing)
          if (_isEditing) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Change Password (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Leave blank if you don\'t want to change your password',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value != null && value.isNotEmpty && value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 32),

          // Logout Button
          if (!_isEditing)
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Provider.of<AuthViewModel>(
                                context,
                                listen: false,
                              ).logout();
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/login');
                            },
                            child: const Text('LOGOUT'),
                          ),
                        ],
                      ),
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('LOGOUT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}

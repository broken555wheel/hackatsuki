import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/appbar_widget.dart';
import 'package:provider/provider.dart';
import 'package:mobile/data/models/user_details.dart';
import 'package:mobile/providers/auth/auth_provider.dart';
import 'package:mobile/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserDetails> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = context.read<AuthProvider>().fetchAndCacheCurrentUser();
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppTheme.green3.withAlpha(150),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightGray2.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.green5.withAlpha(50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.green5,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.lightGray2,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not provided',
                  style: AppTheme.bodyLarge.copyWith(
                    color: AppTheme.green1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGreen1,
      appBar: AppbarWidget(),
      body: FutureBuilder<UserDetails>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.green5),
                  const SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.lightGray2,
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to load profile',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.lightGray2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _userDetailsFuture = context
                              .read<AuthProvider>()
                              .fetchAndCacheCurrentUser();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green5,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.green5.withAlpha(77),
                          AppTheme.green5.withAlpha(26),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.green5.withAlpha(77),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.green5,
                                AppTheme.green5.withAlpha(153),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.green3,
                            child: Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : '?',
                              style: AppTheme.titleLarge.copyWith(
                                color: AppTheme.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: AppTheme.titleLarge.copyWith(
                            color: AppTheme.green1,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.green5.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Member',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.green5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Contact Information',
                      style: AppTheme.titleMedium.copyWith(
                        color: AppTheme.green2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildDetailCard(Icons.email_outlined, 'Email Address', user.email),
                  _buildDetailCard(Icons.phone_outlined, 'Phone Number', user.phoneNumber),
                  _buildDetailCard(Icons.location_on_outlined, 'City', user.city),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.lightGray2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No user data available',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.white,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
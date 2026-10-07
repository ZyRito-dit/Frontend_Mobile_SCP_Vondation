import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';
import 'register_page.dart';

class ClearanceProfilePage extends StatelessWidget {
  final bool isDarkMode;

  const ClearanceProfilePage({super.key, required this.isDarkMode});

  Color _getBadgeColor(int level) {
    switch (level) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.amberAccent;
      case 3:
        return Colors.orangeAccent;
      case 4:
        return Colors.purpleAccent;
      default:
        return Colors.greenAccent;
    }
  }

  void _showPaymentModal(BuildContext context, {required int targetLevel, required int priceInRupiah}) {
    final formattedPrice = 'Rp ${priceInRupiah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'PEMBAYARAN NAIK PANGKAT',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Target Level Pangkat:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LEVEL $targetLevel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getBadgeColor(targetLevel),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Total Biaya Top-Up / Up Level:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black26 : Colors.grey[100],
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'METODE PEMBAYARAN INSTAN:',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.qr_code_scanner, size: 20, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'QRIS / GoPay / OVO / Dana / Transfer Bank',
                            style: TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<AuthBloc>().add(UpgradeClearanceEvent(targetLevel));
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'BAYAR & PROSES NAIK PANGKAT ($formattedPrice)',
                    style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      builder: (context, state) {
        final user = state.user;
        final isLoggedIn = state.status == AuthStatus.authenticated && user != null;
        final userLevel = isLoggedIn ? user.clearanceLevel : 1;

        return Scaffold(
          appBar: AppBar(
            title: const Text('CLEARANCE & AGENT PROFILE'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Personnel Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    border: Border.all(
                      color: isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey)
                            .withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.shield,
                                  color: isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isLoggedIn ? user.agentId : 'AGENT-GUEST-00',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      fontFamily: 'Fira Code',
                                      color: isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: (isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey)
                                  .withValues(alpha: 0.2),
                              border: Border.all(
                                color: isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey,
                              ),
                            ),
                            child: Text(
                              isLoggedIn ? 'LEVEL $userLevel' : 'LEVEL 1 (GUEST)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isLoggedIn ? _getBadgeColor(userLevel) : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      if (isLoggedIn) ...[
                        Text('AGENT NAME: ${user.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('EMAIL: ${user.email}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 4),
                        Text('STATUS PANGKAT: ${user.clearanceTitle}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getBadgeColor(userLevel))),
                        if (userLevel > 1) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 20, color: Colors.blueAccent),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'MASA BERLAKU PANGKAT (30 HARI):',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.daysRemaining > 0
                                            ? '${user.daysRemaining} Hari Lagi (Direset 30 Hari Setiap Naik Level)'
                                            : 'Pangkat Aktif (30 Hari)',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ] else ...[
                        const Text(
                          'UNAUTHORIZED PERSONNEL / GUEST MODE',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Login atau mendaftar sebagai Agent resmi untuk menyimpan bookmark ke Cloud dan meningkatkan Clearance Level (Pangkat) membaca SCP.',
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const LoginPage()),
                                  );
                                },
                                child: const Text('LOGIN AGENT'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(color: Colors.redAccent),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterPage()),
                                  );
                                },
                                child: const Text('REGISTER'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Clearance Level Upgrade Section
                const Text(
                  'SECURITY CLEARANCE LEVELS (4 PANGKAT)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tarif naik pangkat Rp 25.000 per level. Masa berlaku level adalah 30 hari & direset penuh 30 hari setiap kali melakukan upgrade pangkat:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Level 1 Card
                _buildClearanceTierCard(
                  context,
                  level: 1,
                  title: 'Level 1 - Restricted / Safe Class',
                  description: 'Akses membaca artikel SCP standar berkategori Safe & cerita publik dasar.',
                  badgeColor: Colors.greenAccent,
                  currentLevel: userLevel,
                  isLoggedIn: isLoggedIn,
                ),
                const SizedBox(height: 12),

                // Level 2 Card
                _buildClearanceTierCard(
                  context,
                  level: 2,
                  title: 'Level 2 - Euclid Clearance',
                  description: 'Akses membuka dokumen rahasia berkategori Euclid & riset perbatasan.',
                  badgeColor: Colors.amberAccent,
                  currentLevel: userLevel,
                  isLoggedIn: isLoggedIn,
                ),
                const SizedBox(height: 12),

                // Level 3 Card
                _buildClearanceTierCard(
                  context,
                  level: 3,
                  title: 'Level 3 - Keter Clearance',
                  description: 'Akses membuka ancaman berbahaya tinggi (Keter) & eksperimen anomali ekstrim.',
                  badgeColor: Colors.orangeAccent,
                  currentLevel: userLevel,
                  isLoggedIn: isLoggedIn,
                ),
                const SizedBox(height: 12),

                // Level 4 Card
                _buildClearanceTierCard(
                  context,
                  level: 4,
                  title: 'Level 4 - Thaumiel / O5 Executive',
                  description: 'Akses Penuh Tanpa Batas seluruh arsip SCP (Thaumiel, Apollyon, O5 Council Secret Files).',
                  badgeColor: Colors.purpleAccent,
                  currentLevel: userLevel,
                  isLoggedIn: isLoggedIn,
                ),
                const SizedBox(height: 24),

                if (isLoggedIn)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(LogoutAuthEvent());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('LOGOUT SESI AGENT'),
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildClearanceTierCard(
    BuildContext context, {
    required int level,
    required String title,
    required String description,
    required Color badgeColor,
    required int currentLevel,
    required bool isLoggedIn,
  }) {
    final isUnlocked = currentLevel >= level;
    final levelDiff = level - currentLevel;
    final priceInRupiah = levelDiff > 0 ? levelDiff * 25000 : 0;
    final formattedPrice = 'Rp ${priceInRupiah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.all(
          color: isUnlocked
              ? badgeColor
              : !isUnlocked
                  ? Colors.redAccent.withValues(alpha: 0.6)
                  : Colors.grey.withValues(alpha: 0.3),
          width: !isUnlocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      isUnlocked ? Icons.verified_user : Icons.lock_outline,
                      color: isUnlocked ? badgeColor : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isUnlocked ? badgeColor : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  color: badgeColor.withValues(alpha: 0.2),
                  child: Text(
                    'TERBUKA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                  ),
                )
              else
                Text(
                  formattedPrice,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 13),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.grey[400] : Colors.grey[700]),
          ),
          if (!isUnlocked && isLoggedIn) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showPaymentModal(context, targetLevel: level, priceInRupiah: priceInRupiah);
                },
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('NAIK PANGKAT KE LEVEL $level ($formattedPrice)'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/scp_list/scp_list_bloc.dart';
import '../bloc/scp_list/scp_list_event.dart';
import '../bloc/scp_list/scp_list_state.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const HomePage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _selectedLevelFilter = 0; // 0: ALL, 1-4: Level, 5: BISA DIAKSES

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

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

  void _onSearchChanged(BuildContext context, String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ScpListBloc>().add(SearchScpArticlesEvent(query));
    });
  }

  Widget _buildFilterChip(String label, int levelValue, Color accentColor, {IconData? icon}) {
    final isSelected = _selectedLevelFilter == levelValue;
    return ChoiceChip(
      avatar: icon != null ? Icon(icon, size: 14, color: isSelected ? Colors.black : accentColor) : null,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: isSelected ? Colors.black : accentColor,
        ),
      ),
      selected: isSelected,
      selectedColor: accentColor,
      backgroundColor: widget.isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[200],
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedLevelFilter = levelValue;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userClearance = authState.user?.clearanceLevel ?? 1;

    return BlocProvider(
      create: (_) => getIt<ScpListBloc>()..add(const FetchScpArticlesEvent()),
      child: Builder(
        builder: (context) {
          _scrollController.addListener(() {
            if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
              context.read<ScpListBloc>().add(const FetchScpArticlesEvent());
            }
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('SCP ARCHIVE - DATABASE'),
              actions: [
                IconButton(
                  icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: widget.toggleTheme,
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),
            body: Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari SCP (Contoh: Peanut, 173)',
                      prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged(context, '');
                        },
                      ),
                      border: const OutlineInputBorder(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.redAccent, width: 2),
                      ),
                    ),
                    onChanged: (q) => _onSearchChanged(context, q),
                  ),
                ),

                // Clearance Level Filter Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      _buildFilterChip('SEMUA', 0, Colors.redAccent),
                      const SizedBox(width: 8),
                      _buildFilterChip('BISA DIAKSES', 5, Colors.blueAccent, icon: Icons.verified_user),
                      const SizedBox(width: 8),
                      _buildFilterChip('LVL 1', 1, Colors.greenAccent),
                      const SizedBox(width: 8),
                      _buildFilterChip('LVL 2', 2, Colors.amberAccent),
                      const SizedBox(width: 8),
                      _buildFilterChip('LVL 3', 3, Colors.orangeAccent),
                      const SizedBox(width: 8),
                      _buildFilterChip('LVL 4', 4, Colors.purpleAccent),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                Expanded(
                  child: BlocBuilder<ScpListBloc, ScpListState>(
                    builder: (context, state) {
                      if (state.status == ScpListStatus.loading && state.articles.isEmpty) {
                        return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
                      }

                      if (state.status == ScpListStatus.failure && state.articles.isEmpty) {
                        return Center(
                          child: Text(
                            'Error: ${state.errorMessage}',
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        );
                      }

                      if (state.articles.isEmpty) {
                        return const Center(child: Text('Tidak ada SCP ditemukan.'));
                      }

                      final filteredArticles = state.articles.where((article) {
                        if (_selectedLevelFilter == 0) return true;
                        if (_selectedLevelFilter == 5) return article.requiredClearance <= userClearance;
                        return article.requiredClearance == _selectedLevelFilter;
                      }).toList();

                      if (filteredArticles.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.filter_alt_off, size: 48, color: Colors.grey[600]),
                                const SizedBox(height: 12),
                                Text(
                                  'Tidak ada SCP pada filter ini.',
                                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: filteredArticles.length + (state.hasMore && _selectedLevelFilter == 0 ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == filteredArticles.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator(color: Colors.redAccent)),
                            );
                          }

                          final article = filteredArticles[index];
                          final isUnlocked = userClearance >= article.requiredClearance;
                          final badgeColor = _getBadgeColor(article.requiredClearance);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailPage(
                                    link: article.link,
                                    title: article.title,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                border: Border.all(
                                  color: isUnlocked
                                      ? (widget.isDarkMode ? Colors.redAccent.withValues(alpha: 0.5) : Colors.black87)
                                      : Colors.redAccent.withValues(alpha: 0.8),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.isDarkMode
                                        ? Colors.red.withValues(alpha: 0.1)
                                        : Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          article.scp.isNotEmpty ? article.scp : 'UNKNOWN',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        color: widget.isDarkMode ? Colors.white10 : Colors.black12,
                                        child: Text(
                                          (article.type ?? 'ARTICLE').toUpperCase(),
                                          style: const TextStyle(fontSize: 10, letterSpacing: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  if (article.thumbnailUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4.0),
                                        child: Image.network(
                                          article.thumbnailUrl!,
                                          width: double.infinity,
                                          height: 180,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                        ),
                                      ),
                                    ),
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${article.rating}'),
                                      const SizedBox(width: 12),
                                      // Level Required Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: badgeColor.withValues(alpha: 0.15),
                                          border: Border.all(color: badgeColor, width: 1),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          'LVL ${article.requiredClearance}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      // TERBUKA / TERKUNCI Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isUnlocked
                                              ? Colors.greenAccent.withValues(alpha: 0.15)
                                              : Colors.redAccent.withValues(alpha: 0.15),
                                          border: Border.all(
                                            color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isUnlocked ? Icons.verified_user : Icons.lock,
                                              size: 12,
                                              color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isUnlocked ? 'TERBUKA' : 'TERKUNCI',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: isUnlocked ? Colors.greenAccent : Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

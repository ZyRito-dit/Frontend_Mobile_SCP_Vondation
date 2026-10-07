import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/clearance_profile_page.dart';
import '../bloc/bookmark/bookmark_bloc.dart';
import '../bloc/bookmark/bookmark_event.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import 'home_page.dart';
import 'bookmark_page.dart';
import 'history_page.dart';

class MainNavigationPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const MainNavigationPage({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<BookmarkBloc>()..add(LoadBookmarksEvent())),
        BlocProvider(create: (_) => getIt<HistoryBloc>()..add(LoadHistoryEvent())),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status || previous.user != current.user,
        listener: (context, state) {
          context.read<BookmarkBloc>().add(LoadBookmarksEvent());
          context.read<HistoryBloc>().add(LoadHistoryEvent());
        },
        child: Builder(
          builder: (context) {
            final List<Widget> pages = [
              HomePage(toggleTheme: widget.toggleTheme, isDarkMode: widget.isDarkMode),
              ClearanceProfilePage(isDarkMode: widget.isDarkMode),
              BookmarkPage(isDarkMode: widget.isDarkMode),
              HistoryPage(isDarkMode: widget.isDarkMode),
            ];

            return Scaffold(
              body: IndexedStack(
                index: _selectedIndex,
                children: pages,
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedIndex,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Colors.redAccent,
                unselectedItemColor: widget.isDarkMode ? Colors.grey[600] : Colors.grey[700],
                backgroundColor: widget.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  if (index == 2) {
                    context.read<BookmarkBloc>().add(LoadBookmarksEvent());
                  } else if (index == 3) {
                    context.read<HistoryBloc>().add(LoadHistoryEvent());
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dns),
                    label: 'Database',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shield),
                    label: 'Pangkat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark),
                    label: 'Bookmark',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'Riwayat',
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

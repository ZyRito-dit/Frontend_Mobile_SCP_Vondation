import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/scp_item.dart';
import '../bloc/scp_detail/scp_detail_bloc.dart';
import '../bloc/scp_detail/scp_detail_event.dart';
import '../bloc/scp_detail/scp_detail_state.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/pages/clearance_profile_page.dart';

class DetailPage extends StatelessWidget {
  final String link;
  final String title;

  const DetailPage({super.key, required this.link, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = context.watch<AuthBloc>().state;
    final userClearance = authState.user?.clearanceLevel ?? 1;

    return BlocProvider(
      create: (_) => getIt<ScpDetailBloc>()..add(FetchScpDetailEvent(link: link, title: title)),
      child: BlocBuilder<ScpDetailBloc, ScpDetailState>(
        builder: (context, state) {
          final detail = state.detail;
          final requiredLevel = detail?.requiredClearance ?? 1;
          final isDenied = requiredLevel > userClearance;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.isTranslated ? (state.translatedTitle ?? title) : title,
                style: const TextStyle(fontSize: 14),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    state.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: state.isBookmarked ? Colors.redAccent : null,
                  ),
                  tooltip: state.isBookmarked ? 'Hapus Bookmark' : 'Simpan Bookmark',
                  onPressed: () {
                    context.read<ScpDetailBloc>().add(
                          ToggleBookmarkDetailEvent(
                            ScpItem(
                              scp: detail?.scp ?? title,
                              title: title,
                              link: link,
                              rating: detail?.rating ?? 0,
                              series: detail?.series,
                              requiredClearance: requiredLevel,
                            ),
                          ),
                        );
                  },
                ),
                if (state.status == ScpDetailStatus.success && !isDenied)
                  IconButton(
                    icon: state.isTranslating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent),
                          )
                        : Icon(
                            state.isTranslated ? Icons.g_translate : Icons.translate,
                            color: state.isTranslated ? Colors.redAccent : null,
                          ),
                    tooltip: 'Terjemahkan',
                    onPressed: () {
                      if (!state.isTranslating) {
                        context.read<ScpDetailBloc>().add(TranslateScpDetailEvent());
                      }
                    },
                  ),
              ],
            ),
            body: state.status == ScpDetailStatus.loading
                ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
                : state.status == ScpDetailStatus.failure
                    ? Center(child: Text('Error: ${state.errorMessage}', style: const TextStyle(color: Colors.red)))
                    : detail == null
                        ? const Center(child: Text('No content available.'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Section
                                Container(
                                  padding: const EdgeInsets.all(16.0),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.redAccent, width: 2),
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Expanded(
                                            child: Text(
                                              'WARNING: CLASSIFIED DATA',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                letterSpacing: 1,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            color: Colors.redAccent.withValues(alpha: 0.2),
                                            child: Text(
                                              'REQ: LEVEL $requiredLevel',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Item #: ${detail.scp}'),
                                      Text('Rating: ${detail.rating}'),
                                      if (detail.series != null) Text('Series: ${detail.series}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Clearance Denial Guard OR Content Section
                                if (isDenied)
                                  Container(
                                    padding: const EdgeInsets.all(24.0),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.05),
                                      border: Border.all(color: Colors.redAccent, width: 2),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.lock_person_outlined,
                                          size: 72,
                                          color: Colors.redAccent,
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'CLEARANCE LEVEL DENIED',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'DOKUMEN INI MEMBUTUHKAN SECURITY CLEARANCE LEVEL $requiredLevel.',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Pangkat Security Clearance akun Anda saat ini: Level $userClearance.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ClearanceProfilePage(isDarkMode: isDark),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.shield, size: 20),
                                          label: const Text(
                                            'NAIKKAN PANGKAT (TOP-UP CREDITS)',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Builder(
                                    builder: (context) {
                                      String contentToDisplay = state.isTranslated
                                          ? (state.translatedContent ?? detail.rawContent)
                                          : detail.rawContent;

                                      contentToDisplay = contentToDisplay.replaceAll(RegExp(r'\[DISUNTING\]', caseSensitive: false), '[DATA DIHAPUS]');
                                      contentToDisplay = contentToDisplay.replaceAll(RegExp(r'\[DIHAPUS\]', caseSensitive: false), '[DATA DIHAPUS]');
                                      contentToDisplay = contentToDisplay.replaceAll(RegExp(r'style\s*=\s*"display:\s*none;?"', caseSensitive: false), '');
                                      contentToDisplay = contentToDisplay.replaceAll(RegExp(r"style\s*=\s*'display:\s*none;?'", caseSensitive: false), '');

                                      contentToDisplay = contentToDisplay.replaceAllMapped(
                                        RegExp(r'█+'),
                                        (match) => '<span style="color: #111111; background-color: #111111; letter-spacing: -1px;">${match.group(0)}</span>',
                                      );

                                      return HtmlWidget(
                                        contentToDisplay,
                                        textStyle: TextStyle(
                                          fontFamily: 'Fira Code',
                                          color: isDark ? Colors.white : Colors.black87,
                                          fontSize: 14.0,
                                        ),
                                        customStylesBuilder: (element) {
                                          if (element.classes.contains('collapsible-block-unfolded')) {
                                            return {'display': 'block'};
                                          }
                                          if (element.classes.contains('collapsible-block-folded')) {
                                            return {'display': 'none'};
                                          }

                                          if (element.localName == 'blockquote') {
                                            return {
                                              'background-color': isDark ? '#1a1a1a' : '#f0f0f0',
                                              'padding': '12px',
                                              'border-left': '4px solid #D32F2F',
                                            };
                                          }
                                          if (element.localName == 'a') {
                                            return {'color': '#D32F2F', 'text-decoration': 'none'};
                                          }
                                          return null;
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
          );
        },
      ),
    );
  }
}

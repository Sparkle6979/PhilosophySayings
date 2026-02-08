import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/quote.dart';
import '../../services/favorites_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoritesService = FavoritesService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        toolbarHeight: 80, // Increased height for bilingual title
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Echoes of the Soul',
              style: GoogleFonts.imFellEnglishSc(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 1.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "灵魂的回响",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 12,
                letterSpacing: 2.0,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: favoritesService,
        builder: (context, child) {
          final favorites = favoritesService.favorites;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmarks_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "暂无灵魂的回响",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 2-Column Staggered Grid
          return MasonryGridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2, // Two quotes per row
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final quote = favorites[index];
              return _buildQuoteCard(context, quote, favoritesService);
            },
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    Quote quote,
    FavoritesService service,
  ) {
    return GestureDetector(
      onTap: () => _showQuoteDetails(context, quote),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote Text
            Text(
              "“${quote.text}”",
              style: GoogleFonts.notoSerif(
                fontWeight: FontWeight.w600,
                fontSize: 14, // Slightly smaller for grid
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 6, // Allow more lines in grid
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Divider
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 8),

            // Metadata: Author & Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "— ${quote.author}",
                        style: GoogleFonts.imFellEnglishSc(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (quote.tagline != null && quote.tagline!.isNotEmpty)
                        Text(
                          quote.tagline!,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Delete Action (Subtle)
                InkWell(
                  onTap: () {
                    service.remove(quote);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        width: 300,
                        backgroundColor: Colors.black87,
                        content: const Text(
                          "已移除回响",
                          style: TextStyle(color: Colors.white),
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.remove_circle_outline,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuoteDetails(BuildContext context, Quote quote) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, // Transparent for custom shape
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Quote Content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "“${quote.text}”",
                        style: GoogleFonts.notoSerif(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Text(
                            "— ${quote.author}",
                            style: GoogleFonts.imFellEnglishSc(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (quote.lifeYears != null)
                            Text(
                              "  (${quote.lifeYears})",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                      if (quote.tagline != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          quote.tagline!,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Divider(),
                      ),
                      if (quote.explanation.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 16,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "哲言妄解",
                              style: GoogleFonts.imFellEnglishSc(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          quote.explanation,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

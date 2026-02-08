import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;

  const QuoteCard({Key? key, required this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(24),
      child: SelectionArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double cardWidth = constraints.maxWidth;
            final bool isDesktop = cardWidth > 600; // 宽屏阈值

            // 动态字体大小 calculation
            final double scalingBase = isDesktop
                ? cardWidth * 0.5
                : cardWidth; // 0.5 for elegance

            final double quoteFontSize = (scalingBase * 0.06).clamp(16.0, 36.0);
            final double authorFontSize = (scalingBase * 0.035).clamp(
              12.0,
              18.0,
            );
            final double explanationFontSize = (scalingBase * 0.032).clamp(
              12.0,
              16.0,
            );
            final double metaFontSize = (scalingBase * 0.028).clamp(
              10.0,
              14.0,
            ); // For tagline/years

            // --- 组件构建: Profile Column (人物侧写 - 左侧) ---
            // 完整版: 图片 + 姓名 + 生卒年 + Tagline + Bio
            // 修复: 图片可以滚动，但最好不要太大以至于第一眼看不到字
            Widget buildProfileContent() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. 画像 (保持 3:4 纵向比例, 但限制最大高度以确保下方内容可见)
                  // 使用 AspectRatio 0.75 (3:4)
                  // 但加上 LayoutBuilder 或 Constraint 来防止在极高屏幕下过大?
                  // 其实 Flex 3 已经限制了 width，所以 height 也会随之受限。
                  // 问题是“拉长时”，即高度变大？ 不，是宽度变大时，图片也会变大。
                  // 修复方案：给图片加一个最大高度限制，或者 allow shrink.
                  Container(
                    constraints: BoxConstraints(
                      // 限制最大高度，避免在大屏或者宽屏下图片占据整个垂直空间
                      maxHeight: isDesktop ? 600 : 500,
                    ),
                    child: AspectRatio(
                      aspectRatio: 0.75, // 3:4 Ratio
                      child: Container(
                        decoration: BoxDecoration(
                          color: quote.imageUrl != null
                              ? Colors.white
                              : Colors.grey[300],
                          borderRadius: isDesktop
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                )
                              : const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                          image: quote.imageUrl != null
                              ? DecorationImage(
                                  image: AssetImage(quote.imageUrl!),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                )
                              : null,
                        ),
                        child: quote.imageUrl == null
                            ? Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  // 2. 左侧完整人物信息 (Magazine Sidebar Style)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        // Name
                        Text(
                          quote.author,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSerif(
                            fontSize: authorFontSize * 1.3,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                            height: 1.2,
                          ),
                        ),

                        // Life Years
                        if (quote.lifeYears != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            quote.lifeYears!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                              fontSize: metaFontSize * 0.9,
                              color: Colors.grey[500],
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],

                        // Tagline (Simplified Plain Text Style)
                        if (quote.tagline != null) ...[
                          const SizedBox(height: 12), // Slightly closer
                          Text(
                            quote.tagline!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSerif(
                              fontSize: metaFontSize * 0.95,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                              fontWeight: FontWeight
                                  .w500, // Slightly heavier than normal
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Bio
                        if (quote.bio != null) ...[
                          // Divider for elegance
                          Container(
                            width: 20,
                            height: 1,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),

                          Text(
                            quote.bio!,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.lato(
                              fontSize: metaFontSize * 0.95,
                              height: 1.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }

            // --- 组件构建: Content Column (思想完整版 - 右侧) ---
            // 恢复所有内容: 名言 + 作者 + Bio + 解析
            Widget buildFullContent() {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64.0 : 24.0,
                  vertical: isDesktop ? 48.0 : 32.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 1. 名言正文
                    Text(
                      "“${quote.text}”",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: quoteFontSize,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 2. 作者元数据 (恢复到右侧)
                    Text(
                      quote.author,
                      style: GoogleFonts.notoSerif(
                        fontSize: authorFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (quote.lifeYears != null) ...[
                      const SizedBox(height: 4), // Reduced from 6
                      Text(
                        quote.lifeYears!,
                        style: GoogleFonts.lato(
                          fontSize: metaFontSize,
                          color: Colors.grey[500],
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                    if (quote.tagline != null) ...[
                      const SizedBox(height: 6), // Reduced from 8
                      Text(
                        quote.tagline!,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.notoSerif(
                          fontSize: metaFontSize,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32), // Reduced from 48
                    const Divider(),
                    const SizedBox(height: 16), // Reduced from 24
                    // 3. Bio & Explanation
                    if (quote.bio != null) ...[
                      Text(
                        "关于哲人",
                        style: GoogleFonts.lato(
                          fontSize: 10, // Reduced from 14 (Subtle)
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: Colors.grey[500], // Muted color
                        ),
                      ),
                      const SizedBox(height: 6), // Reduced from 8
                      Text(
                        quote.bio!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: explanationFontSize,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20), // Reduced from 24
                    ],

                    // 哲言妄解 Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 1,
                          color: Colors.grey[400], // Darker line
                          margin: const EdgeInsets.only(right: 12),
                        ),
                        Text(
                          "哲言妄解",
                          style: TextStyle(
                            fontSize: 15, // Increased size for Emphasis
                            color: Colors.black87, // Darker color
                            fontWeight: FontWeight.w900, // Heavier weight
                            letterSpacing: 4.0,
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 1,
                          color: Colors.grey[400],
                          margin: const EdgeInsets.only(left: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Explanation Content
                    Text(
                      quote.explanation,
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.notoSerif(
                        fontSize: explanationFontSize,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            }

            // --- 核心布局逻辑 ---
            if (isDesktop) {
              // Magazine Layout Hybrid
              // Left: Image (Narrower)
              // Right: Full Content
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 左栏 (30%)：变窄，限制图片大小
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(16),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: buildProfileContent(),
                        ), // Allowed to scroll if image is tall
                      ),
                    ),
                    // 右栏 (70%)：内容丰富
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(
                            right: Radius.circular(16),
                          ),
                        ),
                        child: SingleChildScrollView(child: buildFullContent()),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Mobile: Standard
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Reuse profile content logic partially or custom
                    Container(
                      height: (cardWidth * 0.75).clamp(200.0, 500.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: quote.imageUrl != null
                            ? Colors.white
                            : Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        image: quote.imageUrl != null
                            ? DecorationImage(
                                image: AssetImage(quote.imageUrl!),
                                fit: BoxFit.contain, // Mobile keep contain
                                alignment: Alignment.center,
                              )
                            : null,
                      ),
                      child: quote.imageUrl == null
                          ? Center(
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              ),
                            )
                          : null,
                    ),

                    Padding(
                      padding: EdgeInsets.all(cardWidth * 0.06),
                      child: Column(
                        children: [
                          // Quote
                          Text(
                            "“${quote.text}”",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSerif(
                              fontSize: quoteFontSize,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Author Info
                          Text(
                            quote.author,
                            style: GoogleFonts.notoSerif(
                              fontSize: authorFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (quote.lifeYears != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              quote.lifeYears!,
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Explanation Title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 30,
                                height: 1,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.only(right: 8),
                              ),
                              Text(
                                "哲言妄解",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              Container(
                                width: 30,
                                height: 1,
                                color: Colors.grey[300],
                                margin: const EdgeInsets.only(left: 8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Explanation
                          Text(
                            quote.explanation,
                            textAlign: TextAlign.justify,
                            style: GoogleFonts.notoSerif(
                              fontSize: explanationFontSize,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

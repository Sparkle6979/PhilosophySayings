import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/quote.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;

  const QuoteCard({Key? key, required this.quote}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Card 是 Flutter 中常用的带有阴影和圆角的容器
    return Card(
      elevation: 4, // 阴影深度
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        // 允许内容过长时滚动
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 画像区域 (暂时用颜色块或 Icon 代替，直到我们放入真实图片)
            Container(
              height: 380, // 再次增加高度，增强视觉冲击力
              width: double.infinity,
              decoration: BoxDecoration(
                color: quote.imageUrl != null ? Colors.white : Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                image: quote.imageUrl != null
                    ? DecorationImage(
                        image: AssetImage(quote.imageUrl!),
                        fit: BoxFit.contain, // 确保图片完整展示，不被裁剪
                      )
                    : null,
              ),
              child: quote.imageUrl == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            quote.author,
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null, // 如果有图片，就不显示中间的 Placeholder
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // 2. 金句正文
                  Text(
                    "“${quote.text}”",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      fontSize: 32, // 增大字体，更有分量
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 作者名
                  Text(
                    "— ${quote.author}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),

                  // Tagline (新建)
                  if (quote.tagline != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      quote.tagline!,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSerif(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 3. 分割线
                  const Divider(),
                  const SizedBox(height: 16),

                  // 4. 生平简介
                  if (quote.bio != null) ...[
                    Text(
                      "关于哲人",
                      style: TextStyle(
                        fontSize: 14, // 小标题微调
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quote.bio!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        height: 1.5,
                      ), // 增大正文
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 5. 深度批注 (Agent Generated)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 装饰线条 (左)
                      Container(
                        width: 40,
                        height: 1,
                        color: Colors.grey[400],
                        margin: const EdgeInsets.only(right: 12),
                      ),
                      Text(
                        "深度解析",
                        style: TextStyle(
                          fontSize: 16, // 增大标题
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4.0, // 增加字间距，更有呼吸感
                        ),
                      ),
                      // 装饰线条 (右)
                      Container(
                        width: 40,
                        height: 1,
                        color: Colors.grey[400],
                        margin: const EdgeInsets.only(left: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    quote.explanation,
                    textAlign: TextAlign.justify, // 两端对齐
                    // 使用 Noto Serif 替代 Lato，Serif 字体更有书卷气和诗意
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      color: Colors.black87,
                      height: 1.8, // 增加行高，提升阅读舒适度
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

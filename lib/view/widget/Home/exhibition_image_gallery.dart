import 'package:flutter/material.dart';
import '../../../core/constant/appcolors.dart';

// ════════════════════════════════════════════════════════════
//  ExhibitionImageGallery
//  شبكة صور المعرض — تُعرض في صفحة تفاصيل المعرض
//  • أول صورة: عرض كامل (كبيرة)
//  • باقي الصور: عمودين (شبكة)
//  • عند الضغط: ExhibitionImageViewer (fullscreen)
//  مشترك بين الموبايل والويب
// ════════════════════════════════════════════════════════════
class ExhibitionImageGallery extends StatelessWidget {
  final List<String> images;
  final bool isWeb;

  const ExhibitionImageGallery({
    super.key,
    required this.images,
    this.isWeb = false,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    if (images.length == 1) {
      return _SingleImage(url: images.first, onTap: () => _openViewer(context, 0));
    }
    return _buildGrid(context);
  }

  Widget _buildGrid(BuildContext context) {
    final cols = isWeb ? 3 : 2;
    final rest = images.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero image (أول صورة كبيرة) ──────────────────────
        GestureDetector(
          onTap: () => _openViewer(context, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: isWeb ? 21 / 9 : 16 / 7,
              child: _NetworkImage(url: images.first),
            ),
          ),
        ),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 8),
          // ── Grid للصور الباقية ────────────────────────────
          LayoutBuilder(
            builder: (_, constraints) {
              final spacing = 8.0;
              final itemW = (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: rest.asMap().entries.map((entry) {
                  final idx = entry.key + 1; // index in images list
                  final url = entry.value;
                  final isLast = idx == images.length - 1 && images.length > cols + 1;
                  final remaining = images.length - (cols + 1);
                  return GestureDetector(
                    onTap: () => _openViewer(context, idx),
                    child: SizedBox(
                      width: itemW,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: AspectRatio(
                          aspectRatio: isWeb ? 4 / 3 : 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              _NetworkImage(url: url),
                              // ── "+N more" overlay on last visible cell ──
                              if (isLast && remaining > 0)
                                Container(
                                  color: Colors.black.withOpacity(0.55),
                                  child: Center(
                                    child: Text(
                                      '+$remaining',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ],
    );
  }

  void _openViewer(BuildContext context, int initialIndex) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.92, end: 1.0).animate(anim), child: child),
      ),
      pageBuilder: (ctx, _, __) => ExhibitionImageViewer(
        images: images,
        initialIndex: initialIndex,
      ),
    );
  }
}

// ─────────────────────────────── Single Image ────────────────
class _SingleImage extends StatelessWidget {
  final String url;
  final VoidCallback onTap;
  const _SingleImage({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: _NetworkImage(url: url),
          ),
        ),
      );
}

// ─────────────────────────── Network Image ───────────────────
class _NetworkImage extends StatelessWidget {
  final String url;
  const _NetworkImage({required this.url});

  @override
  Widget build(BuildContext context) => Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.darkSurface,
          child: const Icon(Icons.image_not_supported_outlined,
              color: AppColors.grey, size: 32),
        ),
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : Container(
                color: AppColors.darkSurface,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.darkPrimary,
                    strokeWidth: 2,
                  ),
                ),
              ),
      );
}

// ════════════════════════════════════════════════════════════
//  ExhibitionImageViewer  —  Fullscreen image viewer
//  PageView أفقي + dots indicator + زر إغلاق + swipe للإغلاق
// ════════════════════════════════════════════════════════════
class ExhibitionImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ExhibitionImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<ExhibitionImageViewer> createState() => _ExhibitionImageViewerState();
}

class _ExhibitionImageViewerState extends State<ExhibitionImageViewer> {
  late PageController _pageCtrl;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Page View ─────────────────────────────────────
            PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(
                    widget.images[i],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.grey,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),

            // ── Close button ─────────────────────────────────
            Positioned(
              top: 12,
              left: 12,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),

            // ── Image counter ─────────────────────────────────
            Positioned(
              top: 18,
              right: 0,
              left: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_current + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            // ── Dots indicator ────────────────────────────────
            if (widget.images.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = i == _current;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? Colors.white : Colors.white38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

            // ── Prev / Next arrows (tablet/desktop) ───────────
            if (widget.images.length > 1) ...[
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowBtn(
                    icon: Icons.chevron_left_rounded,
                    enabled: _current > 0,
                    onTap: () => _pageCtrl.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _ArrowBtn(
                    icon: Icons.chevron_right_rounded,
                    enabled: _current < widget.images.length - 1,
                    onTap: () => _pageCtrl.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _ArrowBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      );
}

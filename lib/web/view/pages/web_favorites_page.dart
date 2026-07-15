import 'package:flutter/material.dart';
import '../../models/web_theme.dart';
import 'package:get/get.dart';
import '../../../controller/Home/favorites_controller.dart';
import '../../../core/constant/appcolors.dart';
import '../widgets/web_section_header.dart';
import '../widgets/web_exhibition_card.dart';

class WebFavoritesPage extends StatelessWidget {
  const WebFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<FavoritesController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: WebTheme.bg,
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
          child: const WebSectionHeader(
            title: 'المفضلة',
            subtitle: 'المعارض والأجنحة المحفوظة',
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Obx(() {
              final exhibitions = c.favoriteExhibitions.toList();
              final booths = c.favoriteBooths.toList();
              final events = c.favoriteEvents.toList();

              if (exhibitions.isEmpty && booths.isEmpty && events.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(60),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 56,
                        color: AppColors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد عناصر في المفضلة',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (exhibitions.isNotEmpty) ...[
                    _subTitle('المعارض', exhibitions.length),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      children: exhibitions
                          .map(
                            (e) => SizedBox(
                              width: 300,
                              child: WebExhibitionCard(
                                exhibition: e,
                                onFavorite: () => c.removeExhibition(e),
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 28),
                  ],
                  if (events.isNotEmpty) ...[
                    _subTitle('الفعاليات', events.length),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: events
                          .map(
                            (ev) => Container(
                              width: 320,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: WebTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: WebTheme.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.favoriteGradient,
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      Icons.campaign_rounded,
                                      color: WebTheme.text,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ev.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: WebTheme.text,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          ev.exhibitionName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => c.removeEvent(ev),
                                    icon: Icon(
                                      Icons.favorite,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                  ],
                  if (booths.isNotEmpty) ...[
                    _subTitle('الأجنحة', booths.length),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: booths
                          .map(
                            (b) => Container(
                              width: 260,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: WebTheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: WebTheme.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: WebTheme.primary.withOpacity(
                                        0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.storefront_rounded,
                                      color: WebTheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'جناح ${b.number}',
                                          style: TextStyle(
                                            color: WebTheme.text,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          b.exhibitionName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.grey,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => c.removeBooth(b),
                                    icon: Icon(
                                      Icons.favorite,
                                      color: AppColors.error,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _subTitle(String t, int count) => Row(
    children: [
      Text(
        t,
        style: TextStyle(
          color: WebTheme.text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: WebTheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            color: WebTheme.pink,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

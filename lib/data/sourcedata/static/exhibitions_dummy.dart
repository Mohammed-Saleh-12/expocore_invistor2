import '../../model/exhibition/exhibition_model.dart';
import '../../model/event/event_model.dart';
import '../../model/booth/booth_model.dart';
import '../../model/campaign/campaign_model.dart';
import '../../model/report/report_model.dart';
import '../../model/message/message_model.dart';
import '../../model/notification/notification_model.dart';

class DummyData {
  static List<ExhibitionModel> exhibitions = [
    ExhibitionModel(
      id: 1, name: 'معرض التقنية 2026',
      description: 'أكبر معرض تقني في المنطقة يجمع أبرز الشركات والمبتكرين في مجال التكنولوجيا والذكاء الاصطناعي.',
      imageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      startDate: '2026-07-15', endDate: '2026-07-20',
      location: 'مركز الرياض للمعارض', city: 'الرياض',
      status: 'upcoming', availableBooths: 45,
      sectors: ['تقنية', 'ذكاء اصطناعي', 'أمن سيبراني'],
      isFavorite: true,
    ),
    ExhibitionModel(
      id: 2, name: 'معرض الغذاء والضيافة',
      description: 'المعرض الأشمل لقطاع الغذاء والمطاعم في الشرق الأوسط.',
      imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      startDate: '2026-08-01', endDate: '2026-08-05',
      location: 'مركز دبي التجاري', city: 'دبي',
      status: 'upcoming', availableBooths: 32,
      sectors: ['غذاء', 'ضيافة', 'مطاعم'],
      isFavorite: false,
    ),
    ExhibitionModel(
      id: 3, name: 'معرض الموضة والأزياء',
      description: 'معرض الموضة العالمي يستقطب أبرز المصممين والعلامات التجارية.',
      imageUrl: 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=800',
      startDate: '2026-06-10', endDate: '2026-06-14',
      location: 'مركز الملك عبدالله', city: 'جدة',
      status: 'active', availableBooths: 18,
      sectors: ['موضة', 'أزياء', 'إكسسوار'],
      isFavorite: false,
    ),
    ExhibitionModel(
      id: 4, name: 'معرض الصحة والرفاهية',
      description: 'معرض متكامل يضم أحدث الابتكارات في مجال الصحة والرياضة.',
      imageUrl: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800',
      startDate: '2026-04-01', endDate: '2026-04-05',
      location: 'قاعة الأمير سلطان', city: 'الرياض',
      status: 'ended', availableBooths: 0,
      sectors: ['صحة', 'رياضة', 'رفاهية'],
      isFavorite: true,
    ),
  ];

  static List<BoothModel> myBooths = [
    BoothModel(
      id: 1, number: 'B12', exhibitionName: 'معرض التقنية 2026',
      imageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      area: 400, status: 'active',
      price: 15000, endDate: '2026-07-20',
      location: 'القاعة A - صف 3',
      amenities: ['واي فاي', 'كهرباء', 'إضاءة'],
      isFavorite: false,
    ),
    BoothModel(
      id: 2, number: 'C05', exhibitionName: 'معرض الغذاء والضيافة',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=800',
      area: 200, status: 'pending',
      price: 8000, endDate: '2026-08-05',
      location: 'القاعة B - صف 1',
      amenities: ['واي فاي', 'مياه'],
      isFavorite: true,
    ),
    BoothModel(
      id: 3, number: 'A01', exhibitionName: 'معرض الموضة والأزياء',
      imageUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=800',
      area: 600, status: 'rejected',
      price: 25000, endDate: '2026-06-14',
      location: 'القاعة الرئيسية - صف 1',
      amenities: ['واي فاي', 'كهرباء', 'موقف مميز'],
      isFavorite: false,
    ),
    BoothModel(
      id: 4, number: 'D08', exhibitionName: 'معرض الصحة والرفاهية',
      imageUrl: 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      area: 300, status: 'ended',
      price: 12000, endDate: '2026-04-05',
      location: 'القاعة C - صف 2',
      amenities: ['واي فاي', 'كهرباء'],
      isFavorite: false,
    ),
  ];

  static List<EventModel> events = [
    EventModel(
      id: 1, name: 'ورشة عمل: مستقبل الذكاء الاصطناعي',
      type: 'ورشة عمل', boothNumber: 'B12',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-16', time: '14:00',
      maxParticipants: 50, registeredCount: 38,
      status: 'upcoming', description: 'ورشة عمل تفاعلية تناقش أحدث تطورات الذكاء الاصطناعي.',
      requiresBooking: true, isFavorite: false,
    ),
    EventModel(
      id: 2, name: 'عرض مباشر: منتجاتنا الجديدة',
      type: 'عرض مباشر', boothNumber: 'B12',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-17', time: '10:00',
      maxParticipants: 100, registeredCount: 72,
      status: 'upcoming', description: 'عرض حصري لأحدث منتجاتنا التقنية.',
      requiresBooking: false, isFavorite: true,
    ),
    EventModel(
      id: 3, name: 'لقاء B2B: فرص الاستثمار',
      type: 'لقاء B2B', boothNumber: 'C05',
      exhibitionName: 'معرض الغذاء والضيافة',
      date: '2026-08-02', time: '16:00',
      maxParticipants: 30, registeredCount: 15,
      status: 'upcoming', description: 'لقاء تجاري بين المستثمرين لاستكشاف فرص الشراكة.',
      requiresBooking: true, isFavorite: false,
    ),
    EventModel(
      id: 4, name: 'مسابقة أفضل منتج',
      type: 'مسابقة', boothNumber: '',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-19', time: '18:00',
      maxParticipants: 200, registeredCount: 185,
      status: 'upcoming', description: 'مسابقة لاختيار أفضل منتج تقني في المعرض.',
      requiresBooking: false, isFavorite: true,
    ),
  ];

  static List<CampaignModel> campaigns = [
    CampaignModel(
      id: 1, title: 'حملة عرض الصيف',
      type: 'إعلانات على شاشات المعرض',
      startDate: '2026-07-15', endDate: '2026-07-20',
      reach: 15420, status: 'active', budget: 5000,
      weeklyTrend: [120, 250, 380, 450, 520, 610, 700],
    ),
    CampaignModel(
      id: 2, title: 'حملة منتجاتنا الجديدة',
      type: 'إعلانات على الخريطة 3D',
      startDate: '2026-07-16', endDate: '2026-07-18',
      reach: 8900, status: 'active', budget: 3000,
      weeklyTrend: [80, 160, 200, 320, 400, 350, 410],
    ),
    CampaignModel(
      id: 3, title: 'عروض خاصة للزوار',
      type: 'عروض خاصة لزوار المعرض',
      startDate: '2026-06-10', endDate: '2026-06-14',
      reach: 22100, status: 'ended', budget: 8000,
      weeklyTrend: [300, 450, 600, 750, 900, 850, 800],
    ),
  ];

  static List<ReportModel> reports = [
    ReportModel(
      id: 'r1', title: 'تقرير الزوار اليومي',
      type: 'visitors', description: 'تحليل حركة الزوار خلال معرض التقنية 2026',
      period: 'يوليو 2026', boothName: 'جناح B12',
      exhibitionName: 'معرض التقنية 2026',
      createdAt: '2026-07-20', mainValue: 2450, mainLabel: 'إجمالي الزوار',
      trend: 12.5, sparklineData: [120, 180, 250, 310, 400, 380, 420],
    ),
    ReportModel(
      id: 'r2', title: 'تقرير أداء الجناح',
      type: 'performance', description: 'مؤشرات الأداء الرئيسية للجناح B12',
      period: 'يوليو 2026', boothName: 'جناح B12',
      exhibitionName: 'معرض التقنية 2026',
      createdAt: '2026-07-20', mainValue: 87, mainLabel: 'مؤشر الأداء (من 100)',
      trend: 8.3, sparklineData: [70, 75, 78, 82, 85, 86, 87],
    ),
    ReportModel(
      id: 'r3', title: 'تقرير الفعاليات',
      type: 'events', description: 'ملخص فعاليات الجناح وتفاعل المشاركين',
      period: 'يوليو 2026', boothName: 'جناح B12',
      exhibitionName: 'معرض التقنية 2026',
      createdAt: '2026-07-20', mainValue: 148, mainLabel: 'إجمالي المسجلين',
      trend: 22.1, sparklineData: [20, 35, 50, 80, 110, 130, 148],
    ),
    ReportModel(
      id: 'r4', title: 'تقرير الحملات الإعلانية',
      type: 'campaigns', description: 'نتائج الحملات الإعلانية ومعدل العائد',
      period: 'يونيو - يوليو 2026', boothName: 'جناح B12',
      exhibitionName: 'معرض التقنية 2026',
      createdAt: '2026-07-20', mainValue: 24320, mainLabel: 'إجمالي الوصول',
      trend: 18.7, sparklineData: [800, 1200, 1800, 2400, 3200, 3800, 4200],
    ),
    ReportModel(
      id: 'r5', title: 'التقرير الشهري الموحّد',
      type: 'monthly', description: 'ملخص شامل لأداء يوليو 2026',
      period: 'يوليو 2026', boothName: 'جناح B12',
      exhibitionName: 'معرض التقنية 2026',
      createdAt: '2026-07-31', mainValue: 95, mainLabel: 'نسبة الإنجاز %',
      trend: 15.2, sparklineData: [60, 65, 70, 78, 85, 90, 95],
    ),
  ];

  static List<MessageModel> messages = [
    MessageModel(id: 1, text: 'مرحباً، كيف يمكننا مساعدتك؟', isMe: false, time: '09:00', isRead: true),
    MessageModel(id: 2, text: 'أريد الاستفسار عن حجز الجناح B12', isMe: true, time: '09:02', isRead: true),
    MessageModel(id: 3, text: 'بالتأكيد! الجناح B12 متاح. هل تريد تفاصيل؟', isMe: false, time: '09:05', isRead: true),
    MessageModel(id: 4, text: 'نعم، أرسل لي التفاصيل من فضلك', isMe: true, time: '09:06', isRead: true),
    MessageModel(id: 5, text: 'الجناح B12 مساحته 20x20م، السعر 15,000 ريال للمعرض كاملاً. هل تريد المتابعة؟', isMe: false, time: '09:10', isRead: true),
    MessageModel(id: 6, text: 'ممتاز، سأرسل طلب الحجز الآن', isMe: true, time: '09:12', isRead: false),
  ];

  static List<NotificationModel> notifications = [
    NotificationModel(id: 1, title: 'تم قبول طلب الحجز', body: 'تم قبول طلب حجز الجناح B12 في معرض التقنية 2026', type: 'booking_accepted', time: 'منذ ساعة', isRead: false, route: '/booths/booking-detail'),
    NotificationModel(id: 2, title: 'معرض جديد متاح', body: 'معرض التقنية 2026 متاح الآن للتسجيل. سارع بحجز جناحك!', type: 'new_exhibition', time: 'منذ 3 ساعات', isRead: false, route: '/exhibitions/detail'),
    NotificationModel(id: 3, title: 'حملتك نشطة الآن', body: 'حملة "عرض الصيف" بدأت الآن وتصل لآلاف الزوار', type: 'campaign_active', time: 'منذ 5 ساعات', isRead: true, route: '/campaigns'),
    NotificationModel(id: 4, title: 'رسالة جديدة', body: 'رسالة جديدة من إدارة معرض التقنية 2026', type: 'new_message', time: 'أمس', isRead: true, route: '/messages'),
    NotificationModel(id: 5, title: 'تقريرك الشهري جاهز', body: 'تقرير يوليو 2026 جاهز للتنزيل. اطلع على أداء جناحك', type: 'report_ready', time: 'أمس', isRead: true, route: '/reports'),
    NotificationModel(id: 6, title: 'تذكير: فعاليتك تبدأ قريباً', body: 'ورشة عمل الذكاء الاصطناعي تبدأ خلال ساعة', type: 'event_reminder', time: 'منذ يومين', isRead: true, route: '/events'),
    NotificationModel(id: 7, title: 'معرض مفضّل بدأ التسجيل', body: 'معرض الغذاء والضيافة المحفوظ في مفضلاتك فتح باب التسجيل', type: 'favorite_update', time: 'منذ 3 أيام', isRead: true, route: '/favorites'),
  ];
}

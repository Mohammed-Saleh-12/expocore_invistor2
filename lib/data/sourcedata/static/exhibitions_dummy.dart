import 'package:expocore_invistor2/data/model/message/conversation_model.dart';
import 'package:expocore_invistor2/data/model/message/visitor_conversation_model.dart';

import '../../model/exhibition/exhibition_model.dart';
import '../../model/event/event_model.dart';
import '../../model/event/exhibition_sponsor_event_model.dart';
import '../../model/event/sponsorship_booking_model.dart';
import '../../model/event/ticket_request_model.dart';
import '../../model/booth/booth_model.dart';
import '../../model/campaign/campaign_model.dart';
import '../../model/report/report_model.dart';
import '../../model/message/message_model.dart';
import '../../model/notification/notification_model.dart';

class DummyData {
  static Map<String, dynamic> exhibitionMap = {
    'exhibition_id': 1,
    'exhibition_name': 'معرض التقنية 2026',
    'grid_width': 13,
    'grid_depth': 10,
    'halls': [
      {
        'id': 'A',
        'name': 'القاعة أ',
        'color': '7A1FFF',
        'booths': [
          {'id': 1,  'number': 'A01', 'col': 0, 'row': 0, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'available', 'price': 18000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء', 'إضاءة']},
          {'id': 2,  'number': 'A02', 'col': 3, 'row': 0, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'booked',    'price': 18000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء']},
          {'id': 3,  'number': 'A03', 'col': 0, 'row': 3, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'available', 'price': 15000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء', 'موقف']},
          {'id': 4,  'number': 'A04', 'col': 3, 'row': 3, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'available', 'price': 15000, 'area': 400, 'amenities': ['واي فاي']},
        ],
      },
      {
        'id': 'B',
        'name': 'القاعة ب',
        'color': '1565C0',
        'booths': [
          {'id': 5,  'number': 'B01', 'col': 7, 'row': 0, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'available', 'price': 16000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء']},
          {'id': 6,  'number': 'B02', 'col': 10,'row': 0, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'booked',    'price': 16000, 'area': 400, 'amenities': ['واي فاي']},
          {'id': 7,  'number': 'B03', 'col': 7, 'row': 3, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'booked',    'price': 14000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء', 'مياه']},
          {'id': 8,  'number': 'B04', 'col': 10,'row': 3, 'width': 2, 'depth': 2, 'height': 1.6, 'status': 'available', 'price': 14000, 'area': 400, 'amenities': ['واي فاي', 'كهرباء']},
        ],
      },
      {
        'id': 'C',
        'name': 'القاعة ج',
        'color': 'E65100',
        'booths': [
          {'id': 9,  'number': 'C01', 'col': 0, 'row': 7, 'width': 2, 'depth': 2, 'height': 1.2, 'status': 'available', 'price': 9000,  'area': 200, 'amenities': ['واي فاي']},
          {'id': 10, 'number': 'C02', 'col': 3, 'row': 7, 'width': 2, 'depth': 2, 'height': 1.2, 'status': 'booked',    'price': 9000,  'area': 200, 'amenities': ['واي فاي', 'كهرباء']},
          {'id': 11, 'number': 'C03', 'col': 6, 'row': 7, 'width': 2, 'depth': 2, 'height': 1.2, 'status': 'available', 'price': 9000,  'area': 200, 'amenities': ['واي فاي']},
          {'id': 12, 'number': 'C04', 'col': 9, 'row': 7, 'width': 2, 'depth': 2, 'height': 1.2, 'status': 'available', 'price': 8000,  'area': 200, 'amenities': ['واي فاي', 'مياه']},
          {'id': 13, 'number': 'C05', 'col': 12,'row': 7, 'width': 1, 'depth': 2, 'height': 1.2, 'status': 'booked',    'price': 7000,  'area': 150, 'amenities': ['واي فاي']},
        ],
      },
    ],
  };

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
    ExhibitionModel(
      id: 5, name: 'معرض السيارات الدولي',
      description: 'أحدث موديلات السيارات والمركبات الكهربائية من كبرى الشركات العالمية.',
      imageUrl: 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=800',
      startDate: '2026-09-10', endDate: '2026-09-15',
      location: 'مركز قطر الوطني', city: 'الدوحة',
      status: 'upcoming', availableBooths: 60,
      sectors: ['سيارات', 'مركبات كهربائية', 'تقنية'],
      isFavorite: false,
    ),
    ExhibitionModel(
      id: 6, name: 'معرض العقارات والإسكان',
      description: 'أكبر تجمع لشركات التطوير العقاري والمشاريع السكنية الفاخرة.',
      imageUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
      startDate: '2026-05-20', endDate: '2026-05-25',
      location: 'مركز جدة للمعارض', city: 'جدة',
      status: 'active', availableBooths: 27,
      sectors: ['عقارات', 'إسكان', 'استثمار'],
      isFavorite: false,
    ),
    ExhibitionModel(
      id: 7, name: 'معرض التعليم والتدريب',
      description: 'منصة تجمع الجامعات ومراكز التدريب وحلول التعليم الرقمي.',
      imageUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800',
      startDate: '2026-10-05', endDate: '2026-10-09',
      location: 'مركز أبوظبي الوطني', city: 'أبوظبي',
      status: 'upcoming', availableBooths: 40,
      sectors: ['تعليم', 'تدريب', 'تقنية'],
      isFavorite: false,
    ),
    ExhibitionModel(
      id: 8, name: 'معرض الزراعة المستدامة',
      description: 'حلول الزراعة الذكية والتقنيات الحديثة في الأمن الغذائي.',
      imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
      startDate: '2026-03-12', endDate: '2026-03-16',
      location: 'مركز الرياض للمعارض', city: 'الرياض',
      status: 'ended', availableBooths: 0,
      sectors: ['زراعة', 'غذاء', 'استدامة'],
      isFavorite: false,
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
      status: 'upcoming', description: 'ورشة عمل تفاعلية تناقش أحدث تطورات الذكاء الاصطناعي وتطبيقاتها في بيئة الأعمال.',
      requiresBooking: true, isFavorite: false,
      place: 'جناح B12 - القاعة الرئيسية',
      durationDays: 1, hasBookableSeats: true,
      totalSeats: 50, bookedSeats: 38, soldTickets: 35,
      ticketPrice: 150, isGeneralInvitation: false,
      currentDay: 1, totalEventDays: 1,
      dailyAttendees: [38], scannedCount: 28,
    ),
    EventModel(
      id: 2, name: 'عرض مباشر: منتجاتنا الجديدة',
      type: 'عرض مباشر', boothNumber: 'B12',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-17', time: '10:00',
      maxParticipants: 100, registeredCount: 72,
      status: 'upcoming', description: 'عرض حصري لأحدث منتجاتنا التقنية مع تجربة مباشرة للزوار.',
      requiresBooking: false, isFavorite: true,
      place: 'جناح B12 - منصة العرض',
      durationDays: 2, hasBookableSeats: false,
      isGeneralInvitation: true,
      currentDay: 1, totalEventDays: 2,
      dailyAttendees: [72, 58], scannedCount: 0,
    ),
    EventModel(
      id: 3, name: 'لقاء B2B: فرص الاستثمار',
      type: 'لقاء B2B', boothNumber: 'C05',
      exhibitionName: 'معرض الغذاء والضيافة',
      date: '2026-08-02', time: '16:00',
      maxParticipants: 30, registeredCount: 15,
      status: 'upcoming', description: 'لقاء تجاري مغلق بين المستثمرين لاستكشاف فرص الشراكة في قطاع الغذاء.',
      requiresBooking: true, isFavorite: false,
      place: 'جناح C05 - غرفة الاجتماعات',
      durationDays: 1, hasBookableSeats: true,
      totalSeats: 30, bookedSeats: 15, soldTickets: 12,
      ticketPrice: 0, isGeneralInvitation: false,
      currentDay: 1, totalEventDays: 1,
      dailyAttendees: [15], scannedCount: 10,
    ),
    EventModel(
      id: 4, name: 'مسابقة أفضل منتج',
      type: 'مسابقة', boothNumber: '',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-19', time: '18:00',
      maxParticipants: 200, registeredCount: 185,
      status: 'upcoming', description: 'مسابقة لاختيار أفضل منتج تقني في المعرض بحضور لجنة تحكيم متخصصة.',
      requiresBooking: false, isFavorite: true,
      place: 'القاعة الرئيسية',
      durationDays: 1, hasBookableSeats: false,
      isGeneralInvitation: true,
      currentDay: 1, totalEventDays: 1,
      dailyAttendees: [185], scannedCount: 0,
    ),
  ];

  // Exhibition-announced sponsorship events (for investors to advertise)
  static List<ExhibitionSponsorEvent> exhibitionSponsorEvents = [
    ExhibitionSponsorEvent(
      id: 101,
      name: 'حفل افتتاح معرض التقنية 2026',
      type: 'حفل افتتاح',
      exhibitionId: 1,
      exhibitionName: 'معرض التقنية 2026',
      exhibitionImageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      date: '2026-07-15',
      startTime: '09:00',
      endTime: '12:00',
      place: 'القاعة الرئيسية - مركز الرياض للمعارض',
      listingDays: 5,
      description: 'حفل افتتاح رسمي بحضور كبار المسؤولين والشخصيات البارزة. فرصة إعلانية ذهبية لعرض شركتك أمام آلاف الحضور.',
      durationOptions: [
        SponsorDurationOption(label: 'يوم واحد', days: 1, price: 2500),
        SponsorDurationOption(label: 'يومان', days: 2, price: 4000),
        SponsorDurationOption(label: 'طوال الفعالية (5 أيام)', days: 5, price: 8500),
      ],
      isFavorite: false,
    ),
    ExhibitionSponsorEvent(
      id: 102,
      name: 'مؤتمر الذكاء الاصطناعي والمستقبل',
      type: 'مؤتمر',
      exhibitionId: 1,
      exhibitionName: 'معرض التقنية 2026',
      exhibitionImageUrl: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
      date: '2026-07-16',
      startTime: '10:00',
      endTime: '17:00',
      place: 'قاعة المؤتمرات أ - مركز الرياض للمعارض',
      listingDays: 2,
      description: 'مؤتمر متخصص يجمع نخبة من خبراء الذكاء الاصطناعي وقادة الأعمال. يُتوقع حضور أكثر من 1500 مشارك.',
      durationOptions: [
        SponsorDurationOption(label: 'يوم واحد', days: 1, price: 3000),
        SponsorDurationOption(label: 'يومان (كامل المؤتمر)', days: 2, price: 5000),
      ],
      isFavorite: true,
    ),
    ExhibitionSponsorEvent(
      id: 103,
      name: 'حفلة اليوم الختامي لمعرض الغذاء',
      type: 'حفل ختامي',
      exhibitionId: 2,
      exhibitionName: 'معرض الغذاء والضيافة',
      exhibitionImageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      date: '2026-08-05',
      startTime: '19:00',
      endTime: '23:00',
      place: 'قاعة الاحتفالات الكبرى - مركز دبي التجاري',
      listingDays: 1,
      description: 'احتفالية ختامية فاخرة بمشاركة أبرز وجوه قطاع الغذاء والضيافة في المنطقة.',
      durationOptions: [
        SponsorDurationOption(label: 'الاحتفالية كاملة', days: 1, price: 3500),
      ],
      isFavorite: false,
    ),
    ExhibitionSponsorEvent(
      id: 104,
      name: 'ندوة الابتكار في قطاع الغذاء',
      type: 'ندوة',
      exhibitionId: 2,
      exhibitionName: 'معرض الغذاء والضيافة',
      exhibitionImageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800',
      date: '2026-08-02',
      startTime: '14:00',
      endTime: '18:00',
      place: 'قاعة الندوات B - مركز دبي التجاري',
      listingDays: 3,
      description: 'ندوة تفاعلية تناقش أحدث الاتجاهات والابتكارات في صناعة الغذاء وتقنيات التصنيع الحديثة.',
      durationOptions: [
        SponsorDurationOption(label: 'يوم واحد', days: 1, price: 1800),
        SponsorDurationOption(label: '3 أيام', days: 3, price: 4200),
      ],
      isFavorite: false,
    ),
  ];

  // Investor's booked sponsorships
  static List<SponsorshipBookingModel> sponsorshipBookings = [
    SponsorshipBookingModel(
      id: 1001, eventId: 101,
      eventName: 'حفل افتتاح معرض التقنية 2026',
      eventType: 'حفل افتتاح',
      exhibitionName: 'معرض التقنية 2026',
      date: '2026-07-15', place: 'القاعة الرئيسية - مركز الرياض للمعارض',
      time: '09:00',
      selectedDurationLabel: 'يومان', selectedDays: 2, price: 4000,
      status: 'approved', bookedAt: '2026-06-01',
      totalVisitors: 3200, totalAttendees: 2800,
      dailyVisitors: [1500, 1700],
      currentDay: 1, totalDays: 2,
    ),
    SponsorshipBookingModel(
      id: 1002, eventId: 103,
      eventName: 'حفلة اليوم الختامي لمعرض الغذاء',
      eventType: 'حفل ختامي',
      exhibitionName: 'معرض الغذاء والضيافة',
      date: '2026-08-05', place: 'قاعة الاحتفالات الكبرى',
      time: '19:00',
      selectedDurationLabel: 'الاحتفالية كاملة', selectedDays: 1, price: 3500,
      status: 'pending', bookedAt: '2026-06-15',
      totalVisitors: 0, totalAttendees: 0,
      dailyVisitors: [0],
      currentDay: 0, totalDays: 1,
    ),
  ];

  // Ticket requests per event
  static Map<int, List<TicketRequestModel>> ticketRequests = {
    1: [
      TicketRequestModel(
        id: 1, eventId: 1,
        requesterName: 'محمد العمري',
        requesterPhone: '+966501234567',
        requesterEmail: 'mohammed@example.com',
        requestedAt: '2026-07-10 09:30',
        status: 'approved',
        qrCodeData: 'ECT-001-2026',
        ticketNumber: 'ECT-001',
      ),
      TicketRequestModel(
        id: 2, eventId: 1,
        requesterName: 'سارة الأحمدي',
        requesterPhone: '+966509876543',
        requesterEmail: 'sara@example.com',
        requestedAt: '2026-07-10 11:00',
        status: 'pending',
      ),
      TicketRequestModel(
        id: 3, eventId: 1,
        requesterName: 'فهد القحطاني',
        requesterPhone: '+966556789012',
        requesterEmail: 'fahad@example.com',
        requestedAt: '2026-07-11 08:45',
        status: 'pending',
      ),
      TicketRequestModel(
        id: 4, eventId: 1,
        requesterName: 'نورة السالم',
        requesterPhone: '+966543210987',
        requesterEmail: 'noura@example.com',
        requestedAt: '2026-07-11 14:20',
        status: 'rejected',
      ),
    ],
    3: [
      TicketRequestModel(
        id: 5, eventId: 3,
        requesterName: 'خالد المطيري',
        requesterPhone: '+966512345678',
        requesterEmail: 'khalid@business.com',
        requestedAt: '2026-07-20 10:00',
        status: 'approved',
        qrCodeData: 'ECT-005-2026',
        ticketNumber: 'ECT-005',
      ),
      TicketRequestModel(
        id: 6, eventId: 3,
        requesterName: 'عبدالله الزهراني',
        requesterPhone: '+966523456789',
        requesterEmail: 'abdullah@corp.com',
        requestedAt: '2026-07-21 09:15',
        status: 'pending',
      ),
    ],
  };

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

  static List<VisitorConversationModel> visitorConversations = [
    VisitorConversationModel(
      id: 601,
      visitorName: 'محمد العمري',
      visitorInitials: 'مع',
      color: 0xFFFF1592,
      unreadCount: 3,
      messages: [
        MessageModel(id: 601, text: 'مرحباً، أود الاستفسار عن منتجاتكم', isMe: false, time: '10:15', isRead: true),
        MessageModel(id: 602, text: 'أهلاً بك! يسعدنا مساعدتك. ما الذي يهمك بالتحديد؟', isMe: true, time: '10:17', isRead: true),
        MessageModel(id: 603, text: 'هل لديكم حلول للشركات الصغيرة؟', isMe: false, time: '10:20', isRead: true),
        MessageModel(id: 604, text: 'نعم، لدينا باقات مخصصة للشركات الصغيرة والمتوسطة', isMe: false, time: '10:25', isRead: false),
        MessageModel(id: 605, text: 'هل يمكنني الحصول على عرض سعر؟', isMe: false, time: '10:26', isRead: false),
        MessageModel(id: 606, text: 'بالطبع! هل يمكنك مشاركة متطلباتك؟', isMe: false, time: '10:27', isRead: false),
      ],
    ),
    VisitorConversationModel(
      id: 602,
      visitorName: 'سارة الأحمدي',
      visitorInitials: 'سأ',
      color: 0xFF7A1FFF,
      unreadCount: 0,
      messages: [
        MessageModel(id: 611, text: 'مرحباً، هل ستشاركون في المعرض القادم؟', isMe: false, time: '13:00', isRead: true),
        MessageModel(id: 612, text: 'نعم، سنكون في الجناح B12 في معرض التقنية 2026', isMe: true, time: '13:02', isRead: true),
        MessageModel(id: 613, text: 'رائع! سأزوركم بالتأكيد', isMe: false, time: '13:05', isRead: true),
        MessageModel(id: 614, text: 'نتطلع لرؤيتك! سيكون هناك عروض خاصة', isMe: true, time: '13:06', isRead: true),
      ],
    ),
    VisitorConversationModel(
      id: 603,
      visitorName: 'خالد المطيري',
      visitorInitials: 'خم',
      color: 0xFF1565C0,
      unreadCount: 1,
      messages: [
        MessageModel(id: 621, text: 'السلام عليكم، أريد الحجز في فعاليتكم', isMe: false, time: '15:30', isRead: true),
        MessageModel(id: 622, text: 'وعليكم السلام! يمكنك الحجز عبر التطبيق', isMe: true, time: '15:32', isRead: true),
        MessageModel(id: 623, text: 'شكراً، هل هناك مقاعد متاحة؟', isMe: false, time: '15:45', isRead: false),
      ],
    ),
    VisitorConversationModel(
      id: 604,
      visitorName: 'نورة السالم',
      visitorInitials: 'نس',
      color: 0xFFE65100,
      unreadCount: 0,
      messages: [
        MessageModel(id: 631, text: 'هل يوجد لديكم عروض للزوار الجدد؟', isMe: false, time: '09:00', isRead: true),
        MessageModel(id: 632, text: 'نعم! خصم 20% على أول طلب للزوار الجدد', isMe: true, time: '09:05', isRead: true),
        MessageModel(id: 633, text: 'ممتاز، سأستفيد من العرض', isMe: false, time: '09:10', isRead: true),
      ],
    ),
  ];

  static List<ConversationModel> conversations = [
    ConversationModel(
      id: 1,
      exhibitionId: 1,
      exhibitionName: 'معرض التقنية 2026',
      exhibitionInitials: 'تق',
      color: 0xFF7A1FFF,
      unreadCount: 2,
      messages: [
        MessageModel(id: 101, text: 'مرحباً، كيف يمكننا مساعدتك؟', isMe: false, time: '09:00', isRead: true),
        MessageModel(id: 102, text: 'أريد الاستفسار عن حجز الجناح B12', isMe: true, time: '09:02', isRead: true),
        MessageModel(id: 103, text: 'بالتأكيد! الجناح B12 متاح. هل تريد تفاصيل؟', isMe: false, time: '09:05', isRead: true),
        MessageModel(id: 104, text: 'نعم، أرسل لي التفاصيل من فضلك', isMe: true, time: '09:06', isRead: true),
        MessageModel(id: 105, text: 'الجناح B12 مساحته 20×20م، السعر 15,000 ريال للمعرض كاملاً.', isMe: false, time: '09:10', isRead: false),
        MessageModel(id: 106, text: 'هل يمكنني الاطلاع على الصور والخدمات المتوفرة؟', isMe: false, time: '09:11', isRead: false),
      ],
    ),
    ConversationModel(
      id: 2,
      exhibitionId: 2,
      exhibitionName: 'معرض الغذاء والضيافة',
      exhibitionInitials: 'غض',
      color: 0xFF1565C0,
      unreadCount: 0,
      messages: [
        MessageModel(id: 201, text: 'مرحباً بكم في معرض الغذاء والضيافة', isMe: false, time: '11:30', isRead: true),
        MessageModel(id: 202, text: 'شكراً، أود الاستفسار عن الجناح C05', isMe: true, time: '11:32', isRead: true),
        MessageModel(id: 203, text: 'طلب حجزكم للجناح C05 قيد المراجعة. سيتم إعلامكم خلال 24 ساعة.', isMe: false, time: '11:45', isRead: true),
      ],
    ),
    ConversationModel(
      id: 3,
      exhibitionId: 3,
      exhibitionName: 'معرض الموضة والأزياء',
      exhibitionInitials: 'مأ',
      color: 0xFFE65100,
      unreadCount: 1,
      messages: [
        MessageModel(id: 301, text: 'للأسف، طلب الحجز للجناح A01 لم يُقبل هذه المرة.', isMe: false, time: '14:00', isRead: true),
        MessageModel(id: 302, text: 'هل يمكنني معرفة السبب؟', isMe: true, time: '14:05', isRead: true),
        MessageModel(id: 303, text: 'يسعدنا مساعدتك في المرة القادمة. هل تريد الاطلاع على الأجنحة المتاحة؟', isMe: false, time: '14:10', isRead: false),
      ],
    ),  ];
}

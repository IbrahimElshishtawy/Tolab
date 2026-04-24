import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/support_models.dart';
import '../../../../core/services/mock_backend_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return MockSupportRepository(ref.watch(mockBackendServiceProvider));
});

class MockSupportRepository implements SupportRepository {
  MockSupportRepository(this._backendService) {
    _tickets = _buildSeedTickets();
  }

  final MockBackendService _backendService;
  late List<SupportTicket> _tickets;

  @override
  Future<SupportTicket> createTicket(SupportTicketDraft draft) async {
    final profile = await _backendService.fetchProfile();
    final now = DateTime.now();
    final id = 'support-${_tickets.length + 1}';
    final ticket = SupportTicket(
      id: id,
      ticketId: _generateTicketId(_tickets.length + 1, now),
      title: draft.title,
      description: draft.description,
      category: draft.category,
      priority: draft.priority,
      status: SupportTicketStatus.pending,
      createdAtLabel: formatArabicDate(now, pattern: 'd MMM - h:mm a'),
      updatedAtLabel: 'الآن',
      studentName: profile.fullName,
      studentCode: profile.studentNumber,
      subjectId: draft.subjectId,
      subjectName: draft.subjectName,
      attachmentName: draft.attachmentName,
      messages: [
        SupportMessage(
          id: '$id-message-1',
          authorName: profile.fullName,
          content: draft.description,
          createdAtLabel: 'الآن',
          isMine: true,
          attachmentName: draft.attachmentName,
        ),
        const SupportMessage(
          id: 'support-auto-reply',
          authorName: 'الدعم الفني',
          content:
              'تم استلام الطلب وربطه بفريق IT/الإدارة. سيتم تحديث الحالة بمجرد بدء المعالجة.',
          createdAtLabel: 'الآن',
          isMine: false,
        ),
      ],
    );

    _tickets = [ticket, ..._tickets];
    return ticket;
  }

  @override
  Future<List<SupportTicket>> fetchTickets() async {
    return List<SupportTicket>.from(_tickets);
  }

  @override
  Future<SupportTicket> sendMessage({
    required String ticketId,
    required String content,
    String? attachmentName,
  }) async {
    final profile = await _backendService.fetchProfile();
    late SupportTicket updated;

    _tickets = _tickets.map((ticket) {
      if (ticket.ticketId != ticketId) {
        return ticket;
      }

      updated = ticket.copyWith(
        status: ticket.status == SupportTicketStatus.resolved
            ? SupportTicketStatus.inProgress
            : ticket.status,
        updatedAtLabel: 'الآن',
        messages: [
          ...ticket.messages,
          SupportMessage(
            id: '${ticket.id}-message-${ticket.messages.length + 1}',
            authorName: profile.fullName,
            content: content,
            createdAtLabel: 'الآن',
            isMine: true,
            attachmentName: attachmentName,
          ),
          const SupportMessage(
            id: 'support-follow-up',
            authorName: 'مهندس IT',
            content:
                'وصلتنا الرسالة، ونعمل الآن على متابعة الحالة مع الجهة المختصة.',
            createdAtLabel: 'بعد لحظات',
            isMine: false,
          ),
        ],
      );
      return updated;
    }).toList();

    return updated;
  }

  List<SupportTicket> _buildSeedTickets() {
    return [
      SupportTicket(
        id: 'support-1',
        ticketId: 'SUP-240426-101',
        title: 'تعذر فتح كويز التطبيقات المتقدمة',
        description:
            'زر الدخول للكويز كان ظاهرًا لكن الصفحة لم تكمل التحميل على اللابتوب.',
        category: SupportTicketCategory.quiz,
        priority: SupportTicketPriority.high,
        status: SupportTicketStatus.inProgress,
        createdAtLabel: '24 أبريل - 10:15 ص',
        updatedAtLabel: 'منذ 20 دقيقة',
        studentName: 'مريم حسن',
        studentCode: '20241182',
        subjectId: 'subject-1',
        subjectName: 'تطوير تطبيقات الهاتف المتقدمة',
        messages: const [
          SupportMessage(
            id: 'support-1-message-1',
            authorName: 'مريم حسن',
            content: 'لم أتمكن من فتح صفحة الكويز من المتصفح على ويندوز.',
            createdAtLabel: '10:15 ص',
            isMine: true,
          ),
          SupportMessage(
            id: 'support-1-message-2',
            authorName: 'مهندس IT',
            content:
                'تمت مراجعة السجل ونعمل على التحقق من صلاحية الجلسة والروابط.',
            createdAtLabel: '10:32 ص',
            isMine: false,
          ),
        ],
      ),
      SupportTicket(
        id: 'support-2',
        ticketId: 'SUP-230426-097',
        title: 'مراجعة نتيجة مادة الحوسبة السحابية',
        description:
            'أحتاج مراجعة توزيع درجات الشيت الثاني لأن التقدير لا يطابق ملف التسليم.',
        category: SupportTicketCategory.result,
        priority: SupportTicketPriority.medium,
        status: SupportTicketStatus.pending,
        createdAtLabel: '23 أبريل - 03:40 م',
        updatedAtLabel: 'منذ يوم',
        studentName: 'مريم حسن',
        studentCode: '20241182',
        subjectId: 'subject-2',
        subjectName: 'الحوسبة السحابية',
        attachmentName: 'submission-proof.pdf',
        messages: const [
          SupportMessage(
            id: 'support-2-message-1',
            authorName: 'مريم حسن',
            content: 'أرفقت ملف التسليم للمراجعة.',
            createdAtLabel: '03:40 م',
            isMine: true,
            attachmentName: 'submission-proof.pdf',
          ),
        ],
      ),
    ];
  }

  String _generateTicketId(int seed, DateTime now) {
    final prefix =
        '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${(now.year % 100).toString().padLeft(2, '0')}';
    return 'SUP-$prefix-${(100 + seed).toString()}';
  }
}

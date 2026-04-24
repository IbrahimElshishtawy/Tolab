import '../../../../core/models/support_models.dart';

abstract class SupportRepository {
  Future<List<SupportTicket>> fetchTickets();

  Future<SupportTicket> createTicket(SupportTicketDraft draft);

  Future<SupportTicket> sendMessage({
    required String ticketId,
    required String content,
    String? attachmentName,
  });
}

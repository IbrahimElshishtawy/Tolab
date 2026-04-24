import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/support_models.dart';
import '../../data/repositories/mock_support_repository.dart';

final supportTicketsProvider =
    AsyncNotifierProvider<SupportTicketsController, List<SupportTicket>>(
      SupportTicketsController.new,
    );

class SupportTicketsController extends AsyncNotifier<List<SupportTicket>> {
  @override
  Future<List<SupportTicket>> build() async {
    return ref.watch(supportRepositoryProvider).fetchTickets();
  }

  Future<SupportTicket> createTicket(SupportTicketDraft draft) async {
    final ticket = await ref
        .read(supportRepositoryProvider)
        .createTicket(draft);
    state = AsyncData(await ref.read(supportRepositoryProvider).fetchTickets());
    return ticket;
  }

  Future<SupportTicket> sendMessage({
    required String ticketId,
    required String content,
    String? attachmentName,
  }) async {
    final ticket = await ref
        .read(supportRepositoryProvider)
        .sendMessage(
          ticketId: ticketId,
          content: content,
          attachmentName: attachmentName,
        );
    state = AsyncData(await ref.read(supportRepositoryProvider).fetchTickets());
    return ticket;
  }
}

final latestSupportTicketProvider = Provider<SupportTicket?>((ref) {
  final ticketsAsync = ref.watch(supportTicketsProvider);
  return ticketsAsync.maybeWhen(
    data: (tickets) => tickets.isEmpty ? null : tickets.first,
    orElse: () => null,
  );
});

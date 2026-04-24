import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/support_models.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/support_providers.dart';

class SupportTicketsPage extends ConsumerStatefulWidget {
  const SupportTicketsPage({super.key});

  @override
  ConsumerState<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends ConsumerState<SupportTicketsPage> {
  SupportTicketStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حالة الطلبات')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: ticketsAsync.when(
            data: (tickets) {
              final filtered = _selectedStatus == null
                  ? tickets
                  : tickets
                        .where((ticket) => ticket.status == _selectedStatus)
                        .toList();

              return ListView(
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'لوحة متابعة الطلبات',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'تابع كل تذكرة، آخر تحديث، والجهة الحالية التي تعمل على الطلب.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ChoiceChip(
                              label: const Text('الكل'),
                              selected: _selectedStatus == null,
                              onSelected: (_) =>
                                  setState(() => _selectedStatus = null),
                            ),
                            for (final status in SupportTicketStatus.values)
                              ChoiceChip(
                                label: Text(status.label),
                                selected: _selectedStatus == status,
                                onSelected: (_) =>
                                    setState(() => _selectedStatus = status),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (filtered.isEmpty)
                    const AppCard(
                      child: Text('لا توجد تذاكر مطابقة لهذا الفلتر.'),
                    )
                  else
                    ...filtered.map(
                      (ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _TicketTimelineCard(ticket: ticket),
                      ),
                    ),
                ],
              );
            },
            loading: () => const LoadingWidget(),
            error: (error, _) => ErrorStateWidget(message: error.toString()),
          ),
        ),
      ),
    );
  }
}

class _TicketTimelineCard extends StatelessWidget {
  const _TicketTimelineCard({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (ticket.status) {
      SupportTicketStatus.pending => AppColors.warning,
      SupportTicketStatus.inProgress => AppColors.support,
      SupportTicketStatus.resolved => AppColors.success,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(ticket.ticketId),
                  ],
                ),
              ),
              AppBadge(
                label: ticket.status.label,
                backgroundColor: statusColor.withValues(alpha: 0.12),
                foregroundColor: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              AppBadge(label: ticket.category.label),
              AppBadge(label: 'الأولوية: ${ticket.priority.label}'),
              AppBadge(label: 'آخر تحديث: ${ticket.updatedAtLabel}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(ticket.description),
          const SizedBox(height: AppSpacing.md),
          ...ticket.messages
              .take(2)
              .map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        message.isMine
                            ? Icons.person_outline_rounded
                            : Icons.support_agent_rounded,
                        size: 18,
                        color: message.isMine
                            ? AppColors.primary
                            : AppColors.support,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${message.authorName}: ${message.content}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

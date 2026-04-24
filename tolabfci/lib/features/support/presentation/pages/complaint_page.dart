import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/support_models.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/adaptive_page_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../providers/support_providers.dart';
import '../widgets/complaint_form.dart';

class ComplaintPage extends ConsumerStatefulWidget {
  const ComplaintPage({super.key});

  @override
  ConsumerState<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends ConsumerState<ComplaintPage> {
  bool _isSubmitting = false;
  SupportTicket? _latestCreatedTicket;

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الشكاوى والطلبات')),
      body: SafeArea(
        child: AdaptivePageContainer(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مركز الطلبات الطلابية',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'قدّم شكوى أو طلب دعم، ثم تابع الحالة والتحديثات من نفس المكان.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_latestCreatedTicket != null) ...[
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.appColors.successSoft,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تم إنشاء الطلب بنجاح',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: AppColors.success),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'رقم التذكرة: ${_latestCreatedTicket!.ticketId}',
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              AppBadge(
                                label: _latestCreatedTicket!.status.label,
                                backgroundColor: AppColors.success.withValues(
                                  alpha: 0.12,
                                ),
                                foregroundColor: AppColors.success,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: context.appColors.border),
                  ),
                  child: const TabBar(
                    tabs: [
                      Tab(text: 'إرسال شكوى'),
                      Tab(text: 'السجل'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: TabBarView(
                    children: [
                      ListView(
                        children: [
                          ComplaintForm(
                            isSubmitting: _isSubmitting,
                            onSubmit: (draft) async {
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _isSubmitting = true);
                              final ticket = await ref
                                  .read(supportTicketsProvider.notifier)
                                  .createTicket(draft);
                              if (!mounted) {
                                return;
                              }
                              setState(() {
                                _isSubmitting = false;
                                _latestCreatedTicket = ticket;
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم إرسال الطلب وربطه بالتذكرة ${ticket.ticketId}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      ticketsAsync.when(
                        data: (tickets) =>
                            _ComplaintHistoryList(tickets: tickets),
                        loading: () => const LoadingWidget(),
                        error: (error, _) =>
                            ErrorStateWidget(message: error.toString()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: AppButton(
        label: 'حالة الطلبات',
        onPressed: () => context.goNamed(RouteNames.supportTickets),
        isExpanded: false,
        variant: AppButtonVariant.secondary,
        icon: Icons.confirmation_number_outlined,
      ),
    );
  }
}

class _ComplaintHistoryList extends StatelessWidget {
  const _ComplaintHistoryList({required this.tickets});

  final List<SupportTicket> tickets;

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return const Center(child: Text('لا توجد طلبات سابقة بعد.'));
    }

    return ListView.separated(
      itemCount: tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        final color = _statusColor(ticket.status);
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
                    backgroundColor: color.withValues(alpha: 0.12),
                    foregroundColor: color,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(ticket.description),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  AppBadge(label: ticket.category.label),
                  AppBadge(label: 'الأولوية: ${ticket.priority.label}'),
                  if (ticket.subjectName != null)
                    AppBadge(label: ticket.subjectName!),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

Color _statusColor(SupportTicketStatus status) {
  return switch (status) {
    SupportTicketStatus.pending => AppColors.warning,
    SupportTicketStatus.inProgress => AppColors.support,
    SupportTicketStatus.resolved => AppColors.success,
  };
}

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/app_colors.dart';
import '../../../../core/spacing/app_spacing.dart';
import '../../models/student_management_models.dart';
import '../../widgets/student_module_primitives.dart';

class CommunicationSection extends StatelessWidget {
  const CommunicationSection({
    super.key,
    required this.snapshot,
    required this.selectedStudentIds,
    required this.onCompose,
  });

  final StudentModuleSnapshot snapshot;
  final Set<String> selectedStudentIds;
  final VoidCallback onCompose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StudentSectionCard(
          title: 'Communication center',
          subtitle:
              'Send individual, grouped, or bulk messages using in-app, email, and push channels tied to the app’s realtime notifications stack.',
          trailing: FilledButton.icon(
            onPressed: onCompose,
            icon: const Icon(Icons.send_rounded),
            label: const Text('Compose campaign'),
          ),
          child: Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              StudentStatusPill(
                label: '${selectedStudentIds.length} selected students',
                color: AppColors.primary,
              ),
              StudentStatusPill(
                label: '${snapshot.groups.length} groups',
                color: AppColors.info,
              ),
              StudentStatusPill(
                label: '${snapshot.campaigns.length} recent campaigns',
                color: AppColors.success,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        StudentSectionCard(
          title: 'Recent campaigns',
          subtitle:
              'Delivery log with recipients, delivery rate, and open-rate feedback.',
          child: SizedBox(
            height: 420,
            child: DataTable2(
              fixedTopRows: 1,
              minWidth: 920,
              columns: const [
                DataColumn2(label: Text('Title'), size: ColumnSize.L),
                DataColumn2(label: Text('Audience')),
                DataColumn2(label: Text('Channel')),
                DataColumn2(label: Text('Delivered')),
                DataColumn2(label: Text('Opened')),
                DataColumn2(label: Text('Sent')),
              ],
              rows: [
                for (final campaign in snapshot.campaigns)
                  DataRow2(
                    cells: [
                      DataCell(Text(campaign.title)),
                      DataCell(Text(campaign.audienceLabel)),
                      DataCell(Text(campaign.channel.label)),
                      DataCell(
                        Text('${campaign.delivered}/${campaign.recipients}'),
                      ),
                      DataCell(
                        Text('${campaign.opened}/${campaign.recipients}'),
                      ),
                      DataCell(
                        Text(
                          DateFormat('MMM d, HH:mm').format(campaign.sentAt),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

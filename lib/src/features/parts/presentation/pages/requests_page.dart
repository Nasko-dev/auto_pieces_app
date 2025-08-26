import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/presentation/widgets/app_menu.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final requests = const [
    ('BMW Série 1', 'Phare avant droit', '2j', 'en_attente', 3),
    ('BMW Série 1', 'Pare-chocs avant', '2j', 'en_attente', 3),
    ('Volkswagen Golf', 'Moteur 1.6 TDI', '5j', 'reponse_recue', 2),
    ('Mercedes Classe C', 'Rétroviseur gauche', '1 semaine', 'termine', 1),
    ('Peugeot 308', 'Feux arrière', '3j', 'en_attente', 4),
    ('Renault Clio', 'Alternateur', '1j', 'reponse_recue', 1),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const Text(
          'Mes Demandes',
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 24,
            color: AppTheme.primaryBlue,
            onPressed: () {},
            tooltip: 'Nouvelle demande',
          ),
          const AppMenu(),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: requests.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (carModel, partName, time, status, responseCount) = requests[index];
          return _RequestCard(
            carModel: carModel,
            partName: partName,
            time: time,
            status: status,
            responseCount: responseCount,
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String carModel;
  final String partName;
  final String time;
  final String status;
  final int responseCount;

  const _RequestCard({
    required this.carModel,
    required this.partName,
    required this.time,
    required this.status,
    required this.responseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkBlue.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Navigation vers les détails de la demande
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.directions_car,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          carModel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          partName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.gray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: AppTheme.gray,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(status: status),
                  if (status == 'reponse_recue' || status == 'termine')
                    _ResponseCountBadge(count: responseCount),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'en_attente':
        backgroundColor = AppTheme.warning.withOpacity(0.1);
        textColor = AppTheme.warning;
        icon = Icons.schedule;
        label = 'En attente';
        break;
      case 'reponse_recue':
        backgroundColor = AppTheme.primaryBlue.withOpacity(0.1);
        textColor = AppTheme.primaryBlue;
        icon = Icons.mark_email_unread;
        label = 'Réponse reçue';
        break;
      case 'termine':
        backgroundColor = AppTheme.success.withOpacity(0.1);
        textColor = AppTheme.success;
        icon = Icons.check_circle_outline;
        label = 'Terminé';
        break;
      default:
        backgroundColor = AppTheme.gray.withOpacity(0.1);
        textColor = AppTheme.gray;
        icon = Icons.help_outline;
        label = 'Inconnu';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: textColor,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCountBadge extends StatelessWidget {
  final int count;

  const _ResponseCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: AppTheme.success,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            '$count réponse${count > 1 ? 's' : ''}',
            style: const TextStyle(
              color: AppTheme.success,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
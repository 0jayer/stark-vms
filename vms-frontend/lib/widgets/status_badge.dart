import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/vehicle.dart';

/// Clean status pill badge adhering to Stark Group design rules:
/// Green ONLY for active/success states, neutral for inactive, corporate for maintenance.
class StatusBadge extends StatelessWidget {
  final VehicleStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (status) {
      case VehicleStatus.active:
        bg = AppTheme.successGreenBg;
        border = AppTheme.successGreenBorder;
        text = AppTheme.successGreen;
        break;
      case VehicleStatus.inactive:
        bg = AppTheme.neutralBg;
        border = AppTheme.neutralBorder;
        text = AppTheme.neutralText;
        break;
      case VehicleStatus.maintenance:
        bg = AppTheme.maintenanceBg;
        border = AppTheme.maintenanceBorder;
        text = AppTheme.maintenanceText;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

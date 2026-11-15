import 'package:flutter/material.dart';
import '../app/theme.dart';

/// Displays a confirmation dialog before deleting a vehicle.
/// Uses red styling specifically for the destructive delete action.
Future<bool?> showConfirmDeleteDialog({
  required BuildContext context,
  required String vehicleNumber,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed, size: 28),
          SizedBox(width: 12),
          Text(
            'Confirm Delete',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.deepBlue,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: Text(
        'Are you sure you want to delete vehicle "$vehicleNumber"? This action cannot be undone.',
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.errorRed,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete Vehicle'),
        ),
      ],
    ),
  );
}


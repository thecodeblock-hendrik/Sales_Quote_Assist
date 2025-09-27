import 'package:flutter/material.dart';
import '../models/quote_item.dart';

class EmailTypeSelector extends StatelessWidget {
  final EmailType selectedType;
  final Function(EmailType) onTypeSelected;

  const EmailTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Desktop layout - horizontal buttons
          return Row(
            children: EmailType.values
                .map((type) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: type != EmailType.values.last ? 8 : 0,
                        ),
                        child: _buildButton(type, theme, colorScheme),
                      ),
                    ))
                .toList(),
          );
        } else {
          // Mobile layout - vertical buttons
          return Column(
            children: EmailType.values
                .map((type) => Padding(
                      padding: EdgeInsets.only(
                        bottom: type != EmailType.values.last ? 8 : 0,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: _buildButton(type, theme, colorScheme),
                      ),
                    ))
                .toList(),
          );
        }
      },
    );
  }

  Widget _buildButton(
      EmailType type, ThemeData theme, ColorScheme colorScheme) {
    final isSelected = selectedType == type;

    return ElevatedButton(
      onPressed: () => onTypeSelected(type),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? const Color(0xFF8B5CF6) : colorScheme.surface,
        foregroundColor: isSelected ? Colors.white : colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isSelected
              ? BorderSide.none
              : BorderSide(
                  color: colorScheme.outline.withValues(alpha: (0.3)),
                ),
        ),
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

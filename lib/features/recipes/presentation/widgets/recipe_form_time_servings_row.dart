import 'package:flutter/material.dart';
import '../../../../core/constants/app_spacing.dart';

class RecipeFormTimeServingsRow extends StatelessWidget {
  final TextEditingController prepController;
  final TextEditingController cookController;
  final TextEditingController servingsController;
  final InputDecoration Function({
    required String label,
    required String hint,
    IconData? icon,
  }) buildDecoration;

  const RecipeFormTimeServingsRow({
    super.key,
    required this.prepController,
    required this.cookController,
    required this.servingsController,
    required this.buildDecoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: prepController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration(
                  label: 'Prep Time (m)',
                  hint: '15',
                  icon: Icons.timer_outlined,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
            AppSpacing.gapW12,
            Expanded(
              child: TextFormField(
                controller: cookController,
                keyboardType: TextInputType.number,
                decoration: buildDecoration(
                  label: 'Cook Time (m)',
                  hint: '25',
                  icon: Icons.local_fire_department_outlined,
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ),
          ],
        ),
        AppSpacing.gapH16,
        TextFormField(
          controller: servingsController,
          keyboardType: TextInputType.number,
          decoration: buildDecoration(
            label: 'Servings',
            hint: '4',
            icon: Icons.people_outline_rounded,
          ),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}


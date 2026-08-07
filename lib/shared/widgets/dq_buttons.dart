import 'package:flutter/material.dart';



import '../../core/theme/app_spacing.dart';

import '../../core/theme/dq_theme.dart';



class DqBackButton extends StatelessWidget {

  const DqBackButton({super.key, required this.onPressed, this.dark = false});



  final VoidCallback onPressed;

  final bool dark;



  @override

  Widget build(BuildContext context) {

    final bg = dark ? Colors.white.withValues(alpha: 0.09) : context.dq.surfaceAlt;

    final border = dark ? Colors.white.withValues(alpha: 0.1) : context.dq.cardBorder;

    final iconColor = dark ? Colors.white : context.colors.onSurface;

    return Semantics(

      button: true,

      label: 'Go back',

      child: Material(

        color: bg,

        shape: const CircleBorder(),

        child: InkWell(

          onTap: onPressed,

          customBorder: const CircleBorder(),

          child: Container(

            width: 44,

            height: 44,

            decoration: BoxDecoration(

              shape: BoxShape.circle,

              border: Border.all(color: border),

            ),

            child: Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: iconColor),

          ),

        ),

      ),

    );

  }

}



class DqPrimaryButton extends StatelessWidget {

  const DqPrimaryButton({

    super.key,

    required this.label,

    this.onPressed,

    this.expanded = true,

  });



  final String label;

  final VoidCallback? onPressed;

  final bool expanded;



  @override

  Widget build(BuildContext context) {

    final child = ElevatedButton(onPressed: onPressed, child: Text(label));

    return expanded ? SizedBox(width: double.infinity, child: child) : child;

  }

}



class DqGhostButton extends StatelessWidget {

  const DqGhostButton({super.key, required this.label, this.onPressed});



  final String label;

  final VoidCallback? onPressed;



  @override

  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      child: OutlinedButton(

        onPressed: onPressed,

        style: OutlinedButton.styleFrom(

          foregroundColor: Colors.white,

          backgroundColor: Colors.white.withValues(alpha: 0.09),

          side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),

          minimumSize: const Size.fromHeight(52),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(16),

          ),

        ),

        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),

      ),

    );

  }

}



class DqScreenHeader extends StatelessWidget {

  const DqScreenHeader({

    super.key,

    required this.title,

    this.onBack,

    this.trailing,

  });



  final String title;

  final VoidCallback? onBack;

  final Widget? trailing;



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),

      child: Row(

        children: [

          if (onBack != null) ...[

            DqBackButton(onPressed: onBack!),

            const SizedBox(width: AppSpacing.md),

          ],

          Expanded(

            child: Text(

              title,

              style: context.text.titleMedium?.copyWith(

                fontWeight: FontWeight.bold,

                color: context.colors.onSurface,

              ),

            ),

          ),

          if (trailing != null) trailing!,

        ],

      ),

    );

  }

}



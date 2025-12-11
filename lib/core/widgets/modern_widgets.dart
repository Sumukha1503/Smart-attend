import 'package:flutter/material.dart';
import '../config/modern_theme.dart';

// ============================================
// MODERN CARD - Reusable Container
// ============================================

class ModernCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final bool enableHover;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.enableHover = true,
    this.borderRadius,
    this.boxShadow,
    this.border,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHover || widget.onTap == null) return;

    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => _handleHover(true),
            onExit: (_) => _handleHover(false),
            cursor: widget.onTap != null
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: widget.margin,
                padding: widget.padding ?? const EdgeInsets.all(ModernTheme.spacing20),
                decoration: BoxDecoration(
                  color: widget.color ?? ModernTheme.pureWhite,
                  borderRadius: widget.borderRadius ?? ModernTheme.radiusLarge,
                  border: widget.border,
                  boxShadow: widget.boxShadow ??
                      (_isHovered
                          ? ModernTheme.hoverShadow
                          : ModernTheme.softShadow),
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// STATUS CHIP - Capsule for Status Display
// ============================================

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
    this.fontSize,
    this.padding,
  });

  factory StatusChip.good(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      color: ModernTheme.softEmerald,
      backgroundColor: ModernTheme.softEmeraldBg,
      icon: icon,
    );
  }

  factory StatusChip.warning(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      color: ModernTheme.amber,
      backgroundColor: ModernTheme.amberBg,
      icon: icon,
    );
  }

  factory StatusChip.critical(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      color: ModernTheme.rose,
      backgroundColor: ModernTheme.roseBg,
      icon: icon,
    );
  }

  factory StatusChip.neutral(String label, {IconData? icon}) {
    return StatusChip(
      label: label,
      color: ModernTheme.blueGrey,
      backgroundColor: ModernTheme.blueGreyBg,
      icon: icon,
    );
  }

  factory StatusChip.fromPercentage(double percentage, String label, {IconData? icon}) {
    if (percentage >= 75) {
      return StatusChip.good(label, icon: icon);
    } else if (percentage >= 60) {
      return StatusChip.warning(label, icon: icon);
    } else {
      return StatusChip.critical(label, icon: icon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: ModernTheme.spacing12,
            vertical: ModernTheme.spacing8,
          ),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize ?? 12,
              color: color,
            ),
            const SizedBox(width: ModernTheme.spacing4),
          ],
          Text(
            label,
            style: ModernTheme.captionBold.copyWith(
              color: color,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// MODERN BUTTON - Primary Action Button
// ============================================

class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final BorderRadius? borderRadius;
  final bool useGradient;

  const ModernButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.height,
    this.borderRadius,
    this.useGradient = false,
  });

  factory ModernButton.gradient({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return ModernButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      useGradient: true,
    );
  }

  factory ModernButton.outline({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isFullWidth = true,
  }) {
    return ModernButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      backgroundColor: Colors.transparent,
      foregroundColor: ModernTheme.royalBlue,
    );
  }

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: isEnabled ? _handleTapDown : null,
            onTapUp: isEnabled ? _handleTapUp : null,
            onTapCancel: isEnabled ? _handleTapCancel : null,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              height: widget.height ?? 56,
              width: widget.isFullWidth ? double.infinity : null,
              padding: widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: ModernTheme.spacing24,
                    vertical: ModernTheme.spacing16,
                  ),
              decoration: BoxDecoration(
                gradient: widget.useGradient ? ModernTheme.primaryGradient : null,
                color: widget.useGradient
                    ? null
                    : (widget.backgroundColor ?? ModernTheme.royalBlue),
                borderRadius: widget.borderRadius ?? ModernTheme.radiusMedium,
                border: widget.backgroundColor == Colors.transparent
                    ? Border.all(
                        color: ModernTheme.royalBlue,
                        width: 2,
                      )
                    : null,
                // Only add shadow to solid buttons (not gradient, not outline/transparent)
                boxShadow: isEnabled && 
                           !widget.useGradient && 
                           widget.backgroundColor != Colors.transparent
                    ? [
                        BoxShadow(
                          color: (widget.backgroundColor ?? ModernTheme.royalBlue)
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.foregroundColor ?? ModernTheme.pureWhite,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              size: 20,
                              color: widget.foregroundColor ?? ModernTheme.pureWhite,
                            ),
                            const SizedBox(width: ModernTheme.spacing8),
                          ],
                          Text(
                            widget.label,
                            style: ModernTheme.button.copyWith(
                              color: widget.foregroundColor ?? ModernTheme.pureWhite,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================
// MODERN TEXT FIELD - Clean Input Field
// ============================================

class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;

  const ModernTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: ModernTheme.labelBold,
          ),
          const SizedBox(height: ModernTheme.spacing8),
        ],
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isFocused ? ModernTheme.pureWhite : ModernTheme.lightGrey,
              borderRadius: ModernTheme.radiusMedium,
              border: Border.all(
                color: _isFocused
                    ? ModernTheme.royalBlue
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: _isFocused ? ModernTheme.softShadow : null,
            ),
            child: TextFormField(
              controller: widget.controller,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              validator: widget.validator,
              onChanged: widget.onChanged,
              maxLines: widget.maxLines,
              enabled: widget.enabled,
              style: ModernTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: _isFocused
                            ? ModernTheme.royalBlue
                            : ModernTheme.slateGrey,
                      )
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: ModernTheme.spacing16,
                  vertical: ModernTheme.spacing16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================
// INSIGHT CARD - Dashboard Stat Card
// ============================================

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? ModernTheme.royalBlue;

    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(ModernTheme.spacing20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ModernTheme.pureWhite,
              cardColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: ModernTheme.radiusMedium,
        ),
        padding: const EdgeInsets.all(ModernTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(ModernTheme.spacing12),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: ModernTheme.lightSlateGrey,
                ),
              ],
            ),
            const SizedBox(height: ModernTheme.spacing16),
            Text(
              title,
              style: ModernTheme.label,
            ),
            const SizedBox(height: ModernTheme.spacing4),
            Text(
              value,
              style: ModernTheme.h2.copyWith(
                color: cardColor,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: ModernTheme.spacing4),
              Text(
                subtitle!,
                style: ModernTheme.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================
// GLASS APP BAR - Frosted Glass Effect
// ============================================

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: ModernTheme.pureWhite.withOpacity(0.8),
          border: const Border(
            bottom: BorderSide(
              color: ModernTheme.borderLight,
              width: 1,
            ),
          ),
        ),
        child: AppBar(
          title: Text(title),
          centerTitle: centerTitle,
          leading: leading,
          actions: actions,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

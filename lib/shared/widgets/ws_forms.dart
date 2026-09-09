/// Forms. `design/worksettle-design-system.md` section 12.
///
/// **Labels sit above the field and stay visible — never a floating or
/// placeholder label.** People are entering passport-accurate information under
/// stress; the label must stay readable while they type.
///
/// **Error text names the fix**, not the failure: *"Enter your date of birth as
/// YYYY-MM-DD"*, never *"Invalid input"*. Helper text uses the same slot in
/// Grey 500, and **the two never appear at once.**
library;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

class WsField extends StatelessWidget {
  const WsField({
    required this.label,
    this.controller,
    this.hint,
    this.helper,
    this.error,
    this.required = false,
    this.obscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.leadingIcon,
    this.trailingIcon,
    this.onTrailingTap,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;

  /// Shown below the field in Grey 500. Ignored when [error] is set.
  final String? helper;

  /// Shown below the field at 12/600 in Red 700 with an alert glyph. Names the
  /// fix.
  final String? error;

  final bool required;
  final bool obscure;
  final bool enabled;
  final bool readOnly;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Label(label: label, required: required),
        const SizedBox(height: WsSpacing.sm),
        TextField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: obscure ? 1 : maxLines,
          onChanged: onChanged,
          onTap: onTap,
          style: context.text.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            // The error ring is drawn by the border; the message lives below,
            // so we suppress the built-in error text slot.
            errorText: null,
            fillColor: hasError ? context.ws.redTint : context.colors.surface,
            prefixIcon: leadingIcon == null
                ? null
                : Icon(leadingIcon, size: WsIconSize.field),
            suffixIcon: trailingIcon == null
                ? null
                : IconButton(
                    onPressed: onTrailingTap,
                    icon: Icon(trailingIcon, size: WsIconSize.field),
                    color: context.ws.placeholder,
                  ),
            enabledBorder: hasError
                ? OutlineInputBorder(
                    borderRadius: WsRadii.fieldR,
                    borderSide:
                        BorderSide(color: context.colors.error, width: 1.5),
                  )
                : null,
          ),
        ),
        if (hasError)
          _Message(text: error!, isError: true)
        else if (helper != null)
          _Message(text: helper!, isError: false),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.label, required this.required});

  final String label;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: label,
        style: context.text.labelLarge?.copyWith(color: context.ws.fieldLabel),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: context.text.labelLarge
                  ?.copyWith(color: context.ws.redOnSurface),
            ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? context.colors.error : context.ws.caption;
    return Padding(
      padding: const EdgeInsets.only(top: WsSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isError) ...[
            Icon(Icons.error_outline_rounded, size: 14, color: color),
            const SizedBox(width: WsSpacing.xs + 2),
          ],
          Expanded(
            child: Text(
              text,
              style: context.text.bodySmall?.copyWith(
                color: color,
                fontWeight: isError ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The phone field carries a country flag and dial code inline before the
/// input.
class WsPhoneField extends StatelessWidget {
  const WsPhoneField({
    required this.label,
    this.controller,
    this.dialCode = '+1',
    this.flag = '🇨🇦',
    this.error,
    this.required = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String dialCode;

  // TODO(assets): the client's country marks replace this glyph — section 7
  // says province and country marks are the only full-colour imagery allowed.
  final String flag;

  final String? error;
  final bool required;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Label(label: label, required: required),
        const SizedBox(height: WsSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: hasError ? context.ws.redTint : context.colors.surface,
            borderRadius: WsRadii.fieldR,
            border: Border.all(
              color: hasError
                  ? context.colors.error
                  : context.colors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: WsSpacing.lg,
                  right: WsSpacing.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(flag, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: WsSpacing.sm),
                    Text(dialCode, style: context.text.bodyMedium),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 24,
                color: context.colors.outlineVariant,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: context.text.bodyMedium,
                  decoration: const InputDecoration(
                    hintText: '000 000 0000',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) _Message(text: error!, isError: true),
      ],
    );
  }
}

/// A checkbox with its label as one 48 dp target.
class WsCheckboxRow extends StatelessWidget {
  const WsCheckboxRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: WsRadii.rowR,
      child: Container(
        constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
        padding: const EdgeInsets.symmetric(vertical: WsSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
            const SizedBox(width: WsSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(label, style: context.text.bodyMedium),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Monthly / Yearly toggle: a pill track in Grey 100 with the active
/// segment filled Settle Red.
class WsSegmentedToggle extends StatelessWidget {
  const WsSegmentedToggle({
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.trailing,
    super.key,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  /// The "Save 17%" badge sits beside the yearly option.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WsSpacing.xs),
      decoration: BoxDecoration(
        color: context.ws.verdictTintedSurface,
        borderRadius: WsRadii.pillR,
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: Semantics(
                selected: i == selectedIndex,
                button: true,
                child: InkWell(
                  onTap: () => onChanged(i),
                  borderRadius: WsRadii.pillR,
                  child: AnimatedContainer(
                    duration: WsMotion.duration(context, WsMotion.fast),
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i == selectedIndex
                          ? context.colors.primary
                          : Colors.transparent,
                      borderRadius: WsRadii.pillR,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            options[i],
                            overflow: TextOverflow.ellipsis,
                            style: context.text.labelLarge?.copyWith(
                              color: i == selectedIndex
                                  ? context.colors.onPrimary
                                  : context.ws.caption,
                            ),
                          ),
                        ),
                        if (trailing != null && i == options.length - 1) ...[
                          const SizedBox(width: WsSpacing.sm),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

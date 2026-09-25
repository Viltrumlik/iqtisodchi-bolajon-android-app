import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/student_profile.dart';
import '../services/game_state_service.dart';

/// First-launch welcome: the child picks an avatar and types their name.
/// Shown again from the home screen when they want to change it.
class OnboardingScreen extends StatefulWidget {
  /// True when reached from the home screen rather than at first launch —
  /// adds a back button and pre-fills the existing profile.
  final bool isEditing;

  const OnboardingScreen({super.key, this.isEditing = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  Gender? _gender;

  @override
  void initState() {
    super.initState();
    final p = context.read<GameStateService>().profile;
    _firstName = TextEditingController(text: p.firstName);
    _lastName = TextEditingController(text: p.lastName);
    _gender = p.isComplete ? p.gender : null;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _gender != null && _firstName.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (_gender == null) {
      _toast('Avval o\'g\'il yoki qiz bolani tanlang');
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await context.read<GameStateService>().saveProfile(
          firstName: _firstName.text,
          lastName: _lastName.text,
          gender: _gender!,
        );
    if (!mounted) return;
    if (widget.isEditing) Navigator.of(context).pop();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFEF6C00),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E), Color(0xFF1A1A6E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (widget.isEditing)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          '👋 Salom!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(
                              begin: const Offset(0.85, 0.85),
                              end: const Offset(1, 1),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 6),
                        Text(
                          widget.isEditing
                              ? 'Ma\'lumotlaringni yangilashing mumkin'
                              : 'Iqtisodchi Bolajonga xush kelibsan!\nO\'zingni tanishtir',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: Colors.white.withValues(alpha: 0.78),
                            fontWeight: FontWeight.w500,
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 380.ms),

                        const SizedBox(height: 26),

                        // ── Avatar choice ──────────────────────────────────
                        Text(
                          'Sen kimsan?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _AvatarChoice(
                                gender: Gender.boy,
                                selected: _gender == Gender.boy,
                                onTap: () =>
                                    setState(() => _gender = Gender.boy),
                              ).animate(delay: 260.ms).fadeIn().slideX(
                                    begin: -0.2,
                                    end: 0,
                                    curve: Curves.easeOut,
                                  ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _AvatarChoice(
                                gender: Gender.girl,
                                selected: _gender == Gender.girl,
                                onTap: () =>
                                    setState(() => _gender = Gender.girl),
                              ).animate(delay: 260.ms).fadeIn().slideX(
                                    begin: 0.2,
                                    end: 0,
                                    curve: Curves.easeOut,
                                  ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 26),

                        // ── Name fields ────────────────────────────────────
                        _NameField(
                          controller: _firstName,
                          label: 'Isming',
                          hint: 'Masalan: Alisher',
                          icon: Icons.person_rounded,
                          textInputAction: TextInputAction.next,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ismingni yozib qo\'y'
                              : null,
                          onChanged: (_) => setState(() {}),
                        ).animate(delay: 360.ms).fadeIn().slideY(
                              begin: 0.2,
                              end: 0,
                              curve: Curves.easeOut,
                            ),
                        const SizedBox(height: 13),
                        _NameField(
                          controller: _lastName,
                          label: 'Familiyang',
                          hint: 'Masalan: Karimov',
                          icon: Icons.badge_rounded,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          onChanged: (_) => setState(() {}),
                        ).animate(delay: 430.ms).fadeIn().slideY(
                              begin: 0.2,
                              end: 0,
                              curve: Curves.easeOut,
                            ),

                        const SizedBox(height: 26),

                        ElevatedButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC837),
                            foregroundColor: const Color(0xFF3A2B00),
                            disabledBackgroundColor:
                                Colors.white.withValues(alpha: 0.18),
                            disabledForegroundColor:
                                Colors.white.withValues(alpha: 0.45),
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            elevation: _canSubmit ? 6 : 0,
                            shadowColor: const Color(0xFFFFC837)
                                .withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.isEditing ? 'Saqlash' : 'Boshladik! 🚀',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ).animate(delay: 500.ms).fadeIn(),

                        const SizedBox(height: 12),
                        Text(
                          'Ma\'lumotlaring faqat shu qurilmada saqlanadi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.42),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Boy / girl card ───────────────────────────────────────────────────────────

class _AvatarChoice extends StatelessWidget {
  final Gender gender;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarChoice({
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: selected ? 0.96 : 0.13),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? const Color(0xFFFFC837)
                : Colors.white.withValues(alpha: 0.25),
            width: selected ? 3 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFC837).withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: selected ? 1.06 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Image.asset(
                gender.asset,
                width: 88,
                height: 88,
                filterQuality: FilterQuality.medium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              gender.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected
                    ? const Color(0xFF2C2C3E)
                    : Colors.white.withValues(alpha: 0.88),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF43A047),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Text field ────────────────────────────────────────────────────────────────

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final void Function(String)? onChanged;

  const _NameField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      textInputAction: textInputAction,
      textCapitalization: TextCapitalization.words,
      maxLength: 24,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C2C3E),
      ),
      decoration: InputDecoration(
        counterText: '',
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(
          color: Color(0xFF6C63FF),
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(color: Color(0xFFB6B6C8)),
        errorStyle: const TextStyle(
          color: Color(0xFFFFD180),
          fontWeight: FontWeight.w700,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFFC837), width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFFF8A80), width: 2.5),
        ),
      ),
    );
  }
}

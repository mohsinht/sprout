import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/auth_store.dart';
import '../../data/api/sprout_api_client.dart';
import '../../theme/sprout_theme.dart';
import '../../theme/sprout_tokens.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _registering = false;
  bool _saving = false;
  String? _error;
  String? _postAuthRoute;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final store = ref.read(authSessionProvider.notifier);
      if (_registering) {
        _postAuthRoute = '/onboarding';
        await store.register(
            email: _email.text, password: _password.text, name: _name.text);
      } else {
        _postAuthRoute = '/today';
        await store.login(email: _email.text, password: _password.text);
      }
      if (mounted) context.go(_postAuthRoute!);
    } on SproutApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted)
        setState(() => _error =
            'Could not sign in right now. You can still use Sprout offline.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final existingSession = ref.watch(authSessionProvider);
    if (existingSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(_postAuthRoute ?? '/today');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final colors = SproutColorScheme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Sprout',
                      style: Theme.of(context).textTheme.displaySmall,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                      'Your calm daily money picture. No bank connection needed.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: colors.muted),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  if (_registering) ...[
                    TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                            labelText: 'Name or nickname (optional)')),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 12),
                  TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password (8+ characters)')),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: const TextStyle(color: SproutColors.tomato)),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving ? null : _submit,
                    child: Text(_saving
                        ? 'One moment…'
                        : _registering
                            ? 'Create account'
                            : 'Log in'),
                  ),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _registering = !_registering;
                              _error = null;
                            }),
                    child: Text(_registering
                        ? 'I already have an account'
                        : 'Create an account'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/today'),
                    child: const Text('Continue without an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

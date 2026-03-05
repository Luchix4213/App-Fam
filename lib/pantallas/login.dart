import 'package:flutter/material.dart';
import 'package:fam_intento1/core/colors.dart';
import 'package:fam_intento1/core/text.dart';
import 'package:fam_intento1/services/auth_service.dart';
import 'package:fam_intento1/pantallas/register.dart';
import 'package:fam_intento1/services/sync_service.dart';
import 'package:fam_intento1/pantallas/Inicio.dart';
import 'package:fam_intento1/pantallas/public_main_screen.dart';
import 'package:fam_intento1/pantallas/admin/dashboard_screen.dart';
import 'package:fam_intento1/widgets/gradient_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (result['success']) {
      // Si el login es exitoso, sincronizar datos con privilegios de administrador
      // para obtener campos sensibles (telefono, correo personal, etc)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login exitoso. Actualizando base de datos...'),
            backgroundColor: Color.fromARGB(255, 72, 228, 33),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Sincronizar (esto usará el token recién guardado)
      try {
        await SyncService.syncAll();
      } catch (e) {
        print("Error sincronizando tras login: $e");
      }

      setState(() {
        _isLoading = false;
      });

      // Obtener rol para redirección
      final role = await AuthService.getUserRole();
      final isAdmin = role != null && (role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? const DashboardScreen() : const PublicMainScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // Mostrar error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.loginWithGoogle();

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login con Google exitoso. Sincronizando...'),
            backgroundColor: Color.fromARGB(255, 72, 228, 33),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      try {
        await SyncService.syncAll();
      } catch (e) {
        print("Error sincronizando tras login Google: $e");
      }

      setState(() {
        _isLoading = false;
      });

      final role = await AuthService.getUserRole();
      final isAdmin = role != null && (role.toLowerCase() == 'admin' || role.toLowerCase() == 'superadmin' || role.toLowerCase() == 'fam');

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? const DashboardScreen() : const PublicMainScreen(),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card Principal
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        const SizedBox(height: 10),
                        Image.asset(
                          "assets/images/famlogo.png",
                          height: 80,
                        ),
                        const SizedBox(height: 20),
                        
                        // Título
                        const Text(
                          "Bienvenido",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // Login con Google
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _loginWithGoogle,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Icono G simple colorido
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    'G',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Iniciar Sesión con Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Separador
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Cuenta de Empresa',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Campo Email
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'E-mail',
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Ingresa tu email';
                            if (!value.contains('@')) return 'Email inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Campo Password
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          ),
                          validator: (value) => (value == null || value.length < 6) 
                              ? 'Mínimo 6 caracteres' : null,
                        ),
                        const SizedBox(height: 30),

                        // Botón Login
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColores.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),


                        
                        const SizedBox(height: 20),
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

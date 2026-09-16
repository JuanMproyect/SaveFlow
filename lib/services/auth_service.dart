import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class ServicioAutenticacion {
  final FirebaseAuth _autenticacionFirebase = FirebaseAuth.instance;
  final FirebaseFirestore _baseDatos = FirebaseFirestore.instance;

  // Stream que escucha si hay un usuario con sesión activa o no
  Stream<User?> get estadoAutenticacion => _autenticacionFirebase.authStateChanges();

  // Usuario actualmente autenticado (si existe)
  User? get usuarioActual => _autenticacionFirebase.currentUser;

  // Registrar nuevo usuario con correo y contraseña
  Future<String?> registrarUsuario({
    required String correo,
    required String contrasena,
    required String nombreVisible,
    required String monedaBase,
  }) async {
    try {
      // 1. Crear el usuario en Firebase Auth
      final credencial = await _autenticacionFirebase.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      final idUsuario = credencial.user!.uid;

      // 2. Crear el documento del usuario en Firestore usando el mismo UID
      final nuevoUsuario = UsuarioModelo(
        idUsuario: idUsuario,
        correo: correo,
        nombreVisible: nombreVisible,
        monedaBase: monedaBase,
        fechaCreacion: DateTime.now(),
        ultimoInicioSesion: DateTime.now(),
      );

      await _baseDatos.collection('users').doc(idUsuario).set(nuevoUsuario.aMapa());

      return null; // null significa que no hubo error
    } on FirebaseAuthException catch (error) {
      return _traducirErrorFirebase(error.code);
    } catch (error) {
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    }
  }

  // Iniciar sesión con correo y contraseña
  Future<String?> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      final credencial = await _autenticacionFirebase.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      // Actualiza la fecha del último inicio de sesión en Firestore
      await _baseDatos.collection('users').doc(credencial.user!.uid).update({
        'lastLoginAt': DateTime.now(),
      });

      return null;
    } on FirebaseAuthException catch (error) {
      return _traducirErrorFirebase(error.code);
    } catch (error) {
      return 'Ocurrió un error inesperado. Intenta de nuevo.';
    }
  }

  // Cerrar sesión
  Future<void> cerrarSesion() async {
    await _autenticacionFirebase.signOut();
  }

  // Obtener los datos completos del usuario desde Firestore
  Future<UsuarioModelo?> obtenerDatosUsuario(String idUsuario) async {
    final documento = await _baseDatos.collection('users').doc(idUsuario).get();
    if (documento.exists) {
      return UsuarioModelo.desdeMapa(documento.id, documento.data()!);
    }
    return null;
  }

  // Traduce los códigos de error de Firebase a mensajes entendibles en español
  String _traducirErrorFirebase(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'invalid-email':
        return 'El correo ingresado no es válido.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'user-not-found':
        return 'No existe una cuenta con este correo.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }
}
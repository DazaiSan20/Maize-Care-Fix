import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Register with email/password and sync to backend
  /// MUST verify dengan backend - kalau backend reject, delete Firebase user
  Future<ApiResponse> register({required String email, required String password, required String name, String? phone}) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await credential.user?.updateDisplayName(name);

      // Get Firebase ID token and set in ApiService
      final token = await credential.user?.getIdToken();
      if (token != null) {
        ApiService.setAuthToken(token);
        
        // MUST sync user to backend - ini mandatory!
        final response = await ApiService.staticPost('/auth/login', {'idToken': token});
        
        // Kalau backend reject, delete dari Firebase juga
        if (!response.success) {
          await credential.user?.delete();
          await _auth.signOut();
          ApiService.setAuthToken(null);
          return ApiResponse(
            success: false,
            message: response.message,
          );
        }
        
        return response;
      }

      return ApiResponse(success: false, message: 'Failed to get auth token');
    } on FirebaseAuthException catch (e) {
      return ApiResponse(success: false, message: e.message ?? 'Registration error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  /// Login with email/password and get backend user
  /// MUST verify dengan backend - tidak boleh login kalau backend error
  Future<ApiResponse> login({required String email, required String password}) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Get Firebase ID token
      final token = await credential.user?.getIdToken();
      if (token != null) {
        ApiService.setAuthToken(token);

        // MUST call backend to verify user - ini mandatory!
        final response = await ApiService.staticPost('/auth/login', {'idToken': token});
        
        // Kalau backend reject (user tidak ada), logout dari Firebase juga
        if (!response.success) {
          await _auth.signOut();
          ApiService.setAuthToken(null);
          return ApiResponse(
            success: false,
            message: response.message,
          );
        }
        
        return response;
      }

      return ApiResponse(success: false, message: 'Failed to get auth token');
    } on FirebaseAuthException catch (e) {
      return ApiResponse(success: false, message: e.message ?? 'Login error');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  /// Login with Google and sync to backend
  /// MUST verify dengan backend - kalau reject, logout
  Future<ApiResponse> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return ApiResponse(success: false, message: 'Cancelled');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);

      // Get Firebase ID token
      final token = await userCred.user?.getIdToken();
      if (token != null) {
        ApiService.setAuthToken(token);

        // MUST call backend to verify user
        final response = await ApiService.staticPost('/auth/login', {'idToken': token});
        
        // Kalau backend reject, logout dari Firebase
        if (!response.success) {
          await _auth.signOut();
          ApiService.setAuthToken(null);
          return ApiResponse(
            success: false,
            message: response.message,
          );
        }
        
        return response;
      }

      return ApiResponse(success: false, message: 'Failed to get auth token');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return ApiResponse(success: true, message: 'Password reset email sent');
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    ApiService.setAuthToken(null);
  }

  Future<bool> isLoggedIn() async {
    final u = _auth.currentUser;
    return u != null;
  }
}
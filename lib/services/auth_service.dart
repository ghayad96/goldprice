import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/auth_config.dart';

class AuthService {
  static final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get Supabase client safely
  static supabase.SupabaseClient? get _supabase {
    try {
      return supabase.Supabase.instance.client;
    } catch (e) {
      print('Supabase not initialized: $e');
      return null;
    }
  }
  
  // Check if Firebase is properly initialized
  static bool get _isFirebaseInitialized {
    try {
      // Try to access Firebase app to see if it's initialized
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }
    // Current user stream
  static Stream<firebase_auth.User?> get firebaseAuthStateChanges => _firebaseAuth.authStateChanges();
  static Stream<supabase.AuthState> get supabaseAuthStateChanges {
    final client = _supabase;
    if (client != null) {
      return client.auth.onAuthStateChange;
    }
    return const Stream.empty();
  }
  
  // Get current user
  static firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;
  static supabase.User? get currentSupabaseUser {
    final client = _supabase;
    return client?.auth.currentUser;
  }
  
  // Check if user is logged in
  static bool get isLoggedIn {
    if (AuthConfig.primaryAuthProvider == 'firebase') {
      return currentFirebaseUser != null;
    } else {
      return currentSupabaseUser != null;
    }
  }
  
  // Get user email
  static String? get userEmail {
    if (AuthConfig.primaryAuthProvider == 'firebase') {
      return currentFirebaseUser?.email;
    } else {
      return currentSupabaseUser?.email;
    }
  }  // Register with email and password and additional user data
  static Future<AuthResult> registerWithEmailPassword({
    required String email,
    required String password,
    String? username,
    String? fullName,
    DateTime? dateOfBirth,
    String? birthplace,
    String? livingState,
  }) async {
    try {
      String primaryProvider = AuthConfig.primaryAuthProvider;
      AuthResult? primaryResult;
      
      // Register with primary provider
      if (primaryProvider == 'firebase' && AuthConfig.enableFirebase && _isFirebaseInitialized) {
        // Create Firebase user
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          // Update display name
          if (fullName != null || username != null) {
            await credential.user!.updateDisplayName(fullName ?? username);
          }
          
          primaryResult = AuthResult(
            success: true, 
            user: credential.user,
            message: 'Kayıt başarılı!',
          );
        } else {
          return AuthResult(success: false, message: 'Kullanıcı oluşturulamadı');
        }
      } else if (primaryProvider == 'supabase' && AuthConfig.enableSupabase) {
        final client = _supabase;
        if (client == null) {
          return AuthResult(success: false, message: 'Supabase not initialized');
        }
        
        // Create Supabase user
        final response = await client.auth.signUp(
          email: email,
          password: password,
        );
        
        if (response.user != null) {
          primaryResult = AuthResult(
            success: true, 
            user: response.user,
            message: 'Kayıt başarılı! Email adresinizi kontrol edin.',
          );
        } else {
          return AuthResult(success: false, message: 'Kayıt başarısız');
        }
      } else {
        return AuthResult(success: false, message: 'Auth provider not configured');
      }
      
      // Store user data in both providers if available
      if (primaryResult?.success == true) {
        String userId = '';
        
        if (primaryProvider == 'firebase') {
          userId = (_firebaseAuth.currentUser?.uid) ?? '';
        } else {
          userId = (_supabase?.auth.currentUser?.id) ?? '';
        }
        
        // Store in Firebase if available and initialized
        if (AuthConfig.enableFirebase && _isFirebaseInitialized && userId.isNotEmpty) {
          try {
            await _storeUserDataInFirestore(
              userId: userId,
              email: email,
              username: username,
              fullName: fullName,
              dateOfBirth: dateOfBirth,
              birthplace: birthplace,
              livingState: livingState,
            );
            print('User data stored in Firebase successfully');
          } catch (e) {
            print('Failed to store user data in Firebase: $e');
          }
        }
        
        // Store in Supabase if available
        if (AuthConfig.enableSupabase && _supabase != null && userId.isNotEmpty) {
          try {
            await _storeUserDataInSupabase(
              userId: userId,
              email: email,
              username: username,
              fullName: fullName,
              dateOfBirth: dateOfBirth,
              birthplace: birthplace,
              livingState: livingState,
            );
            print('User data stored in Supabase successfully');
          } catch (e) {
            print('Failed to store user data in Supabase: $e');
          }
        }
        
        return primaryResult;
      }
      
      return AuthResult(success: false, message: 'Registration failed');} catch (e) {
      print('Registration error: $e'); // Debug log
      
      // More specific error handling for common Supabase issues
      String errorMessage = _getErrorMessage(e);
      if (e.toString().contains('invalid input syntax for type bigint')) {
        errorMessage = 'Veritabanı şeması hatası. Lütfen geliştiriciyle iletişime geçin.';
      } else if (e.toString().contains('duplicate key value')) {
        errorMessage = 'Bu kullanıcı adı veya email zaten kullanımda.';
      }
      
      return AuthResult(success: false, message: errorMessage);
    }
  }
  
  // Login with email and password
  static Future<AuthResult> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && AuthConfig.enableFirebase) {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        
        return AuthResult(success: true, user: credential.user);
      }      else if (AuthConfig.primaryAuthProvider == 'supabase' && AuthConfig.enableSupabase) {
        final client = _supabase;
        if (client == null) {
          return AuthResult(success: false, message: 'Supabase not initialized');
        }
        
        final response = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (response.user != null) {
          return AuthResult(success: true, user: response.user);
        } else {
          return AuthResult(success: false, message: 'Giriş başarısız');
        }
      }
      
      return AuthResult(success: false, message: 'Auth provider not configured');
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }
  
  // Reset password
  static Future<AuthResult> resetPassword({required String email}) async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && AuthConfig.enableFirebase) {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        return AuthResult(success: true, message: 'Şifre sıfırlama emaili gönderildi');
      }      else if (AuthConfig.primaryAuthProvider == 'supabase' && AuthConfig.enableSupabase) {
        final client = _supabase;
        if (client == null) {
          return AuthResult(success: false, message: 'Supabase not initialized');
        }
        
        await client.auth.resetPasswordForEmail(email);
        return AuthResult(success: true, message: 'Şifre sıfırlama emaili gönderildi');
      }
      
      return AuthResult(success: false, message: 'Auth provider not configured');
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }
  
  // Logout
  static Future<AuthResult> logout() async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && AuthConfig.enableFirebase) {
        await _firebaseAuth.signOut();
      }      else if (AuthConfig.primaryAuthProvider == 'supabase' && AuthConfig.enableSupabase) {
        final client = _supabase;
        if (client != null) {
          await client.auth.signOut();
        }
      }
      
      // Clear any stored preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      return AuthResult(success: true, message: 'Başarıyla çıkış yapıldı');
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }
  }
  
  // Delete account
  static Future<AuthResult> deleteAccount() async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && AuthConfig.enableFirebase) {
        await currentFirebaseUser?.delete();
      } 
      else if (AuthConfig.primaryAuthProvider == 'supabase' && AuthConfig.enableSupabase) {
        // Note: Supabase doesn't have a direct delete user method from client
        // You'll need to implement this on your backend
        return AuthResult(success: false, message: 'Hesap silme özelliği henüz mevcut değil');
      }
      
      return AuthResult(success: true, message: 'Hesap başarıyla silindi');
    } catch (e) {
      return AuthResult(success: false, message: _getErrorMessage(e));
    }  }
    // Get user data methods - now retrieves from database
  static Future<String?> getUserUsername() async {
    final profile = await getUserProfile();
    if (profile != null) {
      return profile['username'];
    }
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_username');
  }
  
  static Future<String?> getUserFullName() async {
    final profile = await getUserProfile();
    if (profile != null) {
      return profile['fullName'] ?? profile['full_name']; // Handle both naming conventions
    }
    // Fallback to Firebase display name or SharedPreferences
    if (AuthConfig.primaryAuthProvider == 'firebase' && currentFirebaseUser != null) {
      return currentFirebaseUser!.displayName;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_fullname');
  }
  
  static Future<DateTime?> getUserDateOfBirth() async {
    final profile = await getUserProfile();
    if (profile != null) {
      final dobString = profile['dateOfBirth'] ?? profile['date_of_birth'];
      if (dobString != null) {
        try {
          return DateTime.parse(dobString);
        } catch (e) {
          return null;
        }
      }
    }
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final dobString = prefs.getString('user_dob');
    if (dobString != null) {
      try {
        return DateTime.parse(dobString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  static Future<String?> getUserBirthplace() async {
    final profile = await getUserProfile();
    if (profile != null) {
      return profile['birthplace'];
    }
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_birthplace');
  }
  
  static Future<String?> getUserLivingState() async {
    final profile = await getUserProfile();
    if (profile != null) {
      return profile['livingState'] ?? profile['living_state']; // Handle both naming conventions
    }
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_living_state');
  }
    // Clear user data from local storage
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_username');
    await prefs.remove('user_fullname');
    await prefs.remove('user_dob');
    await prefs.remove('user_birthplace');
    await prefs.remove('user_living_state');
  }
  // Store user data in Firestore
  static Future<void> _storeUserDataInFirestore({
    required String userId,
    required String email,
    String? username,
    String? fullName,
    DateTime? dateOfBirth,
    String? birthplace,
    String? livingState,
  }) async {
    // Check if Firebase is properly initialized
    if (!_isFirebaseInitialized) {
      throw Exception('Firebase is not properly initialized. Please configure Firebase first.');
    }
    
    try {
      final userData = {
        'email': email,
        'username': username,
        'fullName': fullName,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'birthplace': birthplace,
        'livingState': livingState,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('userProfiles').doc(userId).set(userData);
      print('User data stored in Firestore successfully'); // Debug log
    } catch (e) {
      print('Error storing user data in Firestore: $e'); // Debug log
      
      // Check if it's a configuration issue
      if (e.toString().contains('FAILED_PRECONDITION') || 
          e.toString().contains('not initialized') ||
          e.toString().contains('No Firebase App')) {
        throw Exception('Firebase not properly configured. Please run: flutterfire configure');
      }
      
      throw e;
    }
  }// Store user data in Supabase
  static Future<void> _storeUserDataInSupabase({
    required String userId,
    required String email,
    String? username,
    String? fullName,
    DateTime? dateOfBirth,
    String? birthplace,
    String? livingState,
  }) async {
    try {
      final client = _supabase;
      if (client == null) {
        throw Exception('Supabase not initialized');
      }
      
      // First check if profile already exists (could be created by trigger)
      final existingProfile = await client
          .from('user_profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();
      
      final userData = {
        'id': userId,
        'email': email,
        'username': username,
        'full_name': fullName,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'birthplace': birthplace,
        'living_state': livingState,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (existingProfile != null) {
        // Update existing profile
        await client
            .from('user_profiles')
            .update(userData)
            .eq('id', userId);
        print('User data updated in Supabase successfully'); // Debug log
      } else {
        // Insert new profile
        userData['created_at'] = DateTime.now().toIso8601String();
        await client.from('user_profiles').insert(userData);
        print('User data stored in Supabase successfully'); // Debug log
      }
    } catch (e) {
      print('Error storing user data in Supabase: $e'); // Debug log
      throw e;
    }
  }// Get user profile from database
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && currentFirebaseUser != null) {
        final doc = await _firestore.collection('userProfiles').doc(currentFirebaseUser!.uid).get();
        return doc.data();
      } else if (AuthConfig.primaryAuthProvider == 'supabase' && currentSupabaseUser != null) {
        final client = _supabase;
        if (client == null) {
          return null;
        }
        
        final response = await client
            .from('user_profiles')
            .select()
            .eq('id', currentSupabaseUser!.id)
            .maybeSingle();
        return response;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile in database
  static Future<AuthResult> updateUserProfile({
    String? username,
    String? fullName,
    DateTime? dateOfBirth,
    String? birthplace,
    String? livingState,
  }) async {
    try {
      if (AuthConfig.primaryAuthProvider == 'firebase' && currentFirebaseUser != null) {
        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        
        if (username != null) updateData['username'] = username;
        if (fullName != null) updateData['fullName'] = fullName;
        if (dateOfBirth != null) updateData['dateOfBirth'] = dateOfBirth.toIso8601String();
        if (birthplace != null) updateData['birthplace'] = birthplace;
        if (livingState != null) updateData['livingState'] = livingState;

        await _firestore.collection('userProfiles').doc(currentFirebaseUser!.uid).update(updateData);
        
        // Also update Firebase display name if fullName is provided
        if (fullName != null) {
          await currentFirebaseUser!.updateDisplayName(fullName);
        }
        
        return AuthResult(success: true, message: 'Profil başarıyla güncellendi');      } else if (AuthConfig.primaryAuthProvider == 'supabase' && currentSupabaseUser != null) {
        final client = _supabase;
        if (client == null) {
          return AuthResult(success: false, message: 'Supabase not initialized');
        }
        
        final updateData = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        if (username != null) updateData['username'] = username;
        if (fullName != null) updateData['full_name'] = fullName;
        if (dateOfBirth != null) updateData['date_of_birth'] = dateOfBirth.toIso8601String();
        if (birthplace != null) updateData['birthplace'] = birthplace;
        if (livingState != null) updateData['living_state'] = livingState;

        await client
            .from('user_profiles')
            .update(updateData)
            .eq('id', currentSupabaseUser!.id);
        
        return AuthResult(success: true, message: 'Profil başarıyla güncellendi');
      }
      
      return AuthResult(success: false, message: 'Auth provider not configured');
    } catch (e) {
      print('Error updating user profile: $e');
      return AuthResult(success: false, message: 'Profil güncellenirken hata oluştu: ${e.toString()}');
    }
  }
  // Error message helper
  static String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Bu email adresi ile kayıtlı kullanıcı bulunamadı';
        case 'wrong-password':
          return 'Yanlış şifre';
        case 'email-already-in-use':
          return 'Bu email adresi zaten kullanımda';
        case 'weak-password':
          return 'Şifre çok zayıf';
        case 'invalid-email':
          return 'Geçersiz email adresi';
        case 'too-many-requests':
          return 'Çok fazla deneme. Lütfen daha sonra tekrar deneyin';
        default:
          return 'Bir hata oluştu: ${error.message}';
      }
    } else if (error is supabase.AuthException) {
      return 'Supabase hatası: ${error.message}';
    }
    
    return 'Bilinmeyen hata: ${error.toString()}';
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final dynamic user;
  final String? message;
  
  AuthResult({
    required this.success,
    this.user,
    this.message,
  });
}

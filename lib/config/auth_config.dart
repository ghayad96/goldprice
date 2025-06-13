class AuthConfig {
  // Supabase Configuration
  static const String supabaseUrl = 'https://oxzlrsriuoexksohtlgs.supabase.co'; // Add your Supabase URL here
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im94emxyc3JpdW9leGtzb2h0bGdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg3OTQ1NjAsImV4cCI6MjA2NDM3MDU2MH0.Dq3UDmYVVGyryKeXMIb0RzqPYdpR5AjK8cXJll9GI3w'; // Add your Supabase anon key here
  
  // Firebase Configuration (will be set in firebase_options.dart)
  // Firebase config will be automatically generated when you run:
  // flutter pub get
  // flutterfire configure
  
  // Auth Settings
  static const bool enableSupabase = true;
  static const bool enableFirebase = true;
  
  // You can switch between auth providers here
  static const String primaryAuthProvider = 'supabase'; // 'supabase' or 'firebase'
}
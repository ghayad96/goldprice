# Firebase Setup Guide

## Current Status
Firebase is not yet properly configured with real project credentials. The app currently uses Supabase as the primary authentication provider, which is working correctly.

## Required Steps to Enable Firebase

### 1. Create a Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `gold-price-tracker` (or your preferred name)
4. Enable Google Analytics if desired
5. Create the project

### 2. Enable Authentication
1. In your Firebase project, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. Optionally enable other providers (Google, Facebook, etc.)

### 3. Create Firestore Database
1. Go to **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (for development)
4. Select a location (choose closest to your users)

### 4. Add Flutter App to Firebase Project
1. In Firebase project overview, click the **Flutter icon** or **Add app**
2. Select **Flutter** as the platform
3. Enter package name: `com.example.gold_price1` (or your preferred package name)
4. Follow the setup instructions

### 5. Configure FlutterFire
Run these commands in your project directory:

```bash
# Install FlutterFire CLI (if not already installed)
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure

# Follow the prompts to:
# - Select your Firebase project
# - Choose platforms (Android, iOS, Web, etc.)
# - This will generate firebase_options.dart with real credentials
```

### 6. Platform-Specific Configuration

#### For Android:
- The `google-services.json` file will be added to `android/app/`
- Update `android/app/build.gradle` to include Google Services plugin

#### For iOS:
- The `GoogleService-Info.plist` file will be added to `ios/Runner/`
- Update iOS configuration in Xcode

#### For Web:
- Web configuration will be added to `web/index.html`

### 7. Update Security Rules
Update Firestore security rules in Firebase Console:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // User profiles are readable by authenticated users
    match /user_profiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 8. Test Configuration
After completing the setup:
1. Run the app: `flutter run`
2. Try registering a new user
3. Check Firebase Console to verify user creation in Authentication and Firestore

## Current Fallback Configuration
Until Firebase is properly configured, the app will:
- Use Supabase as the primary authentication provider
- Store user data only in Supabase
- Show Firebase initialization errors in debug logs
- Continue working normally with Supabase authentication

## Environment Variables (Optional)
For production, consider using environment variables for sensitive configuration:
- Create `.env` file (add to `.gitignore`)
- Use `flutter_dotenv` package to load environment variables
- Store Firebase configuration in environment variables

## Troubleshooting
1. **"Firebase initialization error"**: Normal until real credentials are added
2. **"Default FirebaseOptions have not been configured"**: Run `flutterfire configure`
3. **Permission denied**: Update Firestore security rules
4. **Package name mismatch**: Ensure consistent package names across platforms

# Database Schema Setup Guide

## Supabase Setup

1. **Go to your Supabase dashboard** (https://app.supabase.com)
2. **Create a new table called `user_profiles`** with the following structure:

### Supabase SQL Schema

```sql
-- Create user_profiles table
CREATE TABLE public.user_profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    date_of_birth DATE,
    birthplace VARCHAR(100),
    living_state VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create an index on username for faster queries
CREATE INDEX idx_user_profiles_username ON public.user_profiles(username);

-- Create an index on email for faster queries
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for RLS
CREATE POLICY "Users can view own profile" ON public.user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Create a function to automatically create profile on user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, email, username, full_name)
    VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'username', ''), COALESCE(NEW.raw_user_meta_data->>'full_name', ''));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to call the function when a new user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
```

## Firebase Firestore Setup

1. **Go to your Firebase Console** (https://console.firebase.google.com)
2. **Navigate to Firestore Database**
3. **Create a collection called `userProfiles`**

### Firebase Firestore Structure

```
Collection: userProfiles
Document ID: {user_uid}
Fields:
- username: string
- fullName: string  
- email: string
- dateOfBirth: timestamp (optional)
- birthplace: string (optional)
- livingState: string (optional)
- createdAt: timestamp
- updatedAt: timestamp
```

### Firebase Security Rules

Add these rules to your Firestore Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read and write their own profile
    match /userProfiles/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Why Use Database Tables Instead of Auth Metadata?

1. **Data Integrity**: Proper database constraints and validation
2. **Querying**: Ability to search users by username, location, etc.
3. **Scalability**: Better performance for large datasets
4. **Relationships**: Can easily link to other tables (favorites, settings, etc.)
5. **Data Types**: Proper handling of dates, timestamps, and complex data
6. **Analytics**: Better reporting and user analytics capabilities

## Next Steps

1. Run the Supabase SQL commands in your Supabase SQL editor
2. Set up the Firebase Firestore collection and rules
3. The Flutter app will automatically use these tables when you register/login

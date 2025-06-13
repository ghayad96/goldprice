-- Test script to verify database schema
-- Run this AFTER running the fix_database_schema.sql

-- Check if the table exists and has correct structure
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Check if RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE tablename = 'user_profiles';

-- Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- Test insert (this should work with UUID)
-- Note: This will only work if you have a valid user ID from auth.users
-- SELECT auth.uid(); -- This shows your current user ID

-- Docu/database_schema/user_profiles.sql

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

--
-- Table structure for table `user_profiles`
-- 用户个人资料表
--

CREATE TABLE public.user_profiles (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id uuid UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    avatar_url text,
    display_name text,
    gender text,
    birthday date,
    language text DEFAULT 'en',
    timezone text DEFAULT 'UTC',
    bio text,
    role text NOT NULL DEFAULT 'customer',
    preferences jsonb DEFAULT '{
        "notification": {
            "push_enabled": true,
            "email_enabled": true,
            "sms_enabled": true
        },
        "privacy": {
            "profile_visible": true,
            "show_online": true
        }
    }',
    verification jsonb DEFAULT '{
        "is_verified": false,
        "documents": []
    }',
    service_preferences jsonb DEFAULT '{
        "favorite_categories": [],
        "preferred_providers": []
    }',
    social_links jsonb DEFAULT '{
        "facebook": null,
        "twitter": null,
        "instagram": null
    }',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Add indexes
CREATE INDEX idx_user_profiles_user_id ON public.user_profiles (user_id);
CREATE INDEX idx_user_profiles_display_name ON public.user_profiles (display_name);
CREATE INDEX idx_user_profiles_created_at ON public.user_profiles (created_at);
CREATE INDEX idx_user_profiles_role ON public.user_profiles (role);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS Policies
CREATE POLICY "Users can view their own profile"
    ON public.user_profiles
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own profile"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Create function to handle updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

--
-- Sample data for `user_profiles`
-- Note: user_id must exist in auth.users table
--

INSERT INTO public.user_profiles (user_id, display_name, gender, language, timezone, bio) VALUES
('b3c4d5e6-7890-1234-5678-901234567890', 'John Doe', 'male', 'en', 'America/New_York', 'Software developer and tech enthusiast'),
('c4d5e6f7-8901-2345-6789-012345678901', 'Jane Smith', 'female', 'en', 'America/Los_Angeles', 'Professional photographer and traveler'); 
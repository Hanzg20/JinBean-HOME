-- Docu/database_schema/users.sql

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Note: The auth.users table is automatically created by Supabase
-- This file documents the structure and adds any necessary modifications

-- Add additional columns to auth.users if needed
ALTER TABLE auth.users
ADD COLUMN IF NOT EXISTS phone text,
ADD COLUMN IF NOT EXISTS username text,
ADD COLUMN IF NOT EXISTS last_login timestamptz,
ADD COLUMN IF NOT EXISTS status text DEFAULT 'active',
ADD COLUMN IF NOT EXISTS auth_providers jsonb DEFAULT '[]',
ADD COLUMN IF NOT EXISTS device_info jsonb DEFAULT '{
    "last_device": null,
    "push_token": null,
    "app_version": null
}';

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_users_email ON auth.users (email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON auth.users (phone);
CREATE INDEX IF NOT EXISTS idx_users_username ON auth.users (username);
CREATE INDEX IF NOT EXISTS idx_users_status ON auth.users (status);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON auth.users (created_at);

-- Create function to handle last_login updates
CREATE OR REPLACE FUNCTION auth.handle_last_login()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_login = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for last_login
CREATE TRIGGER set_last_login
    BEFORE UPDATE ON auth.users
    FOR EACH ROW
    WHEN (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at)
    EXECUTE FUNCTION auth.handle_last_login();

-- Create function to handle user status
CREATE OR REPLACE FUNCTION auth.handle_user_status()
RETURNS TRIGGER AS $$
BEGIN
    -- Set default status if not provided
    IF NEW.status IS NULL THEN
        NEW.status := 'active';
    END IF;
    
    -- Validate status values
    IF NEW.status NOT IN ('active', 'disabled', 'banned') THEN
        RAISE EXCEPTION 'Invalid status value: %', NEW.status;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for user status
CREATE TRIGGER validate_user_status
    BEFORE INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION auth.handle_user_status();

-- Create function to handle auth_providers
CREATE OR REPLACE FUNCTION auth.handle_auth_providers()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure auth_providers is always an array
    IF NEW.auth_providers IS NULL THEN
        NEW.auth_providers := '[]'::jsonb;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for auth_providers
CREATE TRIGGER validate_auth_providers
    BEFORE INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION auth.handle_auth_providers();

-- Create function to handle device_info
CREATE OR REPLACE FUNCTION auth.handle_device_info()
RETURNS TRIGGER AS $$
BEGIN
    -- Ensure device_info has the correct structure
    IF NEW.device_info IS NULL THEN
        NEW.device_info := '{
            "last_device": null,
            "push_token": null,
            "app_version": null
        }'::jsonb;
    END IF;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for device_info
CREATE TRIGGER validate_device_info
    BEFORE INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION auth.handle_device_info();

-- Note: The following is for documentation purposes only
-- The actual auth.users table structure in Supabase includes:
/*
CREATE TABLE auth.users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    instance_id uuid,
    email text,
    encrypted_password text,
    email_confirmed_at timestamptz,
    invited_at timestamptz,
    confirmation_token text,
    confirmation_sent_at timestamptz,
    recovery_token text,
    recovery_sent_at timestamptz,
    email_change_token_new text,
    email_change text,
    email_change_sent_at timestamptz,
    last_sign_in_at timestamptz,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamptz,
    updated_at timestamptz,
    phone text,
    phone_confirmed_at timestamptz,
    phone_change text,
    phone_change_token text,
    phone_change_sent_at timestamptz,
    confirmed_at timestamptz,
    email_change_token_current text,
    banned_until timestamptz,
    reauthentication_token text,
    reauthentication_sent_at timestamptz,
    is_sso_user boolean DEFAULT false,
    deleted_at timestamptz
);
*/ 
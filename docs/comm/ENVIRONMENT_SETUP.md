# Environment Setup Guide

## Overview
This document explains how to configure environment variables for the JinBean app to ensure sensitive information is not exposed in the codebase.

## Environment Variables

### Required Variables

1. **Supabase Configuration**
   ```bash
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   ```

2. **API Configuration**
   ```bash
   API_BASE_URL=https://api.jinbean.com
   ```

3. **Third-party Services**
   ```bash
   MSG_NEXUS_API_KEY=your-msg-nexus-api-key
   MSG_NEXUS_BASE_URL=https://api.msgnexus.com/v1
   ```

4. **Image Service**
   ```bash
   IMAGE_SERVICE_URL=https://picsum.photos
   ```

### Optional Variables

1. **Development Configuration**
   ```bash
   IS_DEVELOPMENT=true
   ENABLE_DEBUG_LOGGING=true
   ```

## Setup Instructions

### For Development

1. Create a `.env` file in the project root
2. Copy the variables from the example above
3. Fill in your actual values
4. Never commit the `.env` file to version control

### For Production

1. Set environment variables in your deployment platform
2. Ensure all sensitive keys are properly configured
3. Use secure key management services

## Security Best Practices

1. **Never commit sensitive information** to version control
2. **Use environment variables** for all API keys and URLs
3. **Rotate keys regularly** for production environments
4. **Use different keys** for development and production
5. **Monitor access logs** for suspicious activity

## File Structure

```
project/
├── .env                    # Local environment variables (not committed)
├── .env.example           # Example environment variables
├── lib/
│   └── config/
│       └── app_config.dart # Environment variable definitions
└── ENVIRONMENT_SETUP.md   # This file
```

## Troubleshooting

If you encounter issues with environment variables:

1. Ensure the `.env` file exists in the project root
2. Check that variable names match exactly
3. Restart the Flutter app after making changes
4. Verify that the `.env` file is not being committed to git 
# Authentication Setup Guide

## Google OAuth Setup

To enable Google Sign-In functionality, you need to:

1. **Create a Google OAuth Client:**
   - Go to [Google Cloud Console]
   - Create a new project or select an existing one
   - Enable the Google+ API
   - Go to "Credentials" → "Create Credentials" → "OAuth client ID"
   - Choose "Web application"
   - Add authorized redirect URI: `http://localhost:4000/auth/google/callback`
   - Copy the Client ID and Client Secret

2. **Add to your `.env` file:**
   ```
   GOOGLE_CLIENT_ID=your-client-id-here
   GOOGLE_CLIENT_SECRET=your-client-secret-here
   SESSION_SECRET=your-random-secret-key-here
   ```

3. **Install dependencies:**
   ```powershell
   npm install
   ```

4. **Start the server:**
   ```powershell
   npm run dev
   ```

## Local Authentication

Local authentication (email + display name) works without any additional setup. Users can sign up or sign in using just their email and display name.

## Accessing the Application

- **Login page:** http://localhost:4000/login.html
- **Upload page:** http://localhost:4000/upload.html
- **Files page:** http://localhost:4000/files.html

All pages require authentication and will redirect to the login page if not authenticated.


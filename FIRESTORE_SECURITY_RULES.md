# Firestore Security Rules for Bohurupi Order CMS

## Overview
These security rules provide a comprehensive access control mechanism for the Bohurupi Order CMS application.

## Rule Breakdown

### Authentication
- All operations require user authentication
- Provides role-based access control

### Users Collection
- Users can only read and modify their own profile
- Admins can read and modify any user profile

### Orders Collections
- Create, Update, Delete: Admin-only
- Read: All authenticated users

### Sensitive Data
- Completely restricted access

## Key Security Principles
1. Least Privilege Access
2. Role-Based Authentication
3. Strict Write Permissions
4. Open Read Access for Authenticated Users

## Deployment
To apply these rules in Firebase Console:
1. Go to Firestore Database
2. Navigate to Rules tab
3. Replace existing rules with content from firestore.rules
4. Publish the rules

## Troubleshooting
- Ensure user roles are correctly set in the 'users' collection
- Verify Firebase Authentication is configured
- Check that user documents have a 'role' field

## Example User Document Structure
```json
{
  "users": {
    "userUID": {
      "role": "admin" // or "user"
    }
  }
}

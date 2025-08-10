Here’s your properly formatted **README.md** content with correct markdown syntax and indentation:

````markdown
# Stytch B2B API (Rails 8.0.2 API-only)

## Overview

This Rails API-only application implements a B2B signup and authentication system using Stytch magic links.

### Features

- **Signup**  
  - Magic link authentication only (no public signup).  
  - Users can belong to multiple organizations.  
  - Organizations can have multiple users.  
  - Atomic transactions with rollback on failure.

- **Public Magic Link Endpoint**  
  - Public endpoint to request magic links with user validation.  
  - Only sends magic links if the user exists in the system.  
  - Prevents sign-in if the user is not registered.  
  - Deletes existing Stytch user if already present to avoid duplicates.

---

## Tech Stack

- Ruby 3.2.2  
- Rails 8.0.2 (API only)  
- SQLite3 (development database)

---

## Setup Instructions

1. Clone the repository and install dependencies:

   ```bash
   bundle install
````

2. Setup the database:

   ```bash
   rails db:create
   rails db:migrate
   ```

3. Add your Stytch credentials to the `.env` file in the root directory:

   ```env
   STYTCH_ENV=test
   STYTCH_PUBLIC_TOKEN=public-token-test-xxxxxx
   ADMIN_TOKEN=secret-test-xxxxxx
   STYTCH_PROJECT_ID=project-test-xxxxxx
   STYTCH_SECRET=secret-test-xxxxxx
   ```

4. Start the Rails server:

   ```bash
   rails server
   ```

---

## API Usage Examples

### Create Admin User with Organization

```bash
curl -X POST http://localhost:3000/v1/admin/users \
  -H "Content-Type: application/json" \
  -d '{
    "email":"shrivasganesh57@gmail.com",
    "first_name":"ganesh",
    "last_name":"shrivas",
    "org_name":"ganesh-ror",
    "org_slug":"ganesh-ror"
  }'
```

### Request a Magic Link (Public Endpoint)

```bash
curl -X POST http://localhost:3000/v1/public/magic_links \
  -H "Content-Type: application/json" \
  -d '{
    "email":"shrivasganesh57@gmail.com",
    "organization_slug":"ganesh-ror"
  }'
```

### Authenticate Using Magic Link Token

```bash
curl -X GET http://localhost:3000/v1/public/magic_links/authenticate \
  -H "Content-Type: application/json" \
  -d '{
    "token":"<MAGIC_LINK_TOKEN_FROM_EMAIL>"
  }'
```
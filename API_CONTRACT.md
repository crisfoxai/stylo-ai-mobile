# Stylo AI — REST API Contract

**Version:** 1.0.0
**Base URL:** `https://api.stylo.ai`
**AI Service Base URL:** `http://ai-service:8000` (internal)
**Last Updated:** 2026-03-30

---

## Table of Contents

1. [Overview](#overview)
2. [Common Conventions](#common-conventions)
3. [Auth Module](#auth-module)
4. [Users Module](#users-module)
5. [Style Profile Module](#style-profile-module)
6. [Wardrobe Module](#wardrobe-module)
7. [Outfits Module](#outfits-module)
8. [Favorites Module](#favorites-module)
9. [Weather Module](#weather-module)
10. [Subscriptions Module](#subscriptions-module)
11. [Waitlist Module](#waitlist-module)
12. [AI Service (Internal)](#ai-service-internal)

---

## Overview

Stylo AI is a fashion assistant platform offering wardrobe scanning, outfit recommendations, and virtual try-on capabilities.

### Stack

| Layer | Technology |
|---|---|
| Backend Framework | NestJS |
| Database | MongoDB (Mongoose ODM) |
| Authentication | Firebase Auth + JWT |
| File Storage | S3-compatible (MinIO / Cloudflare R2) |
| AI Service | FastAPI (separate microservice) |
| Validation | class-validator |
| API Docs | Swagger / OpenAPI 3.0 |

---

## Common Conventions

### Authentication Header

All protected endpoints require a JWT access token in the Authorization header:

```
Authorization: Bearer {jwt_access_token}
```

### Response Envelope

All API responses follow a standard envelope format:

```json
{
  "success": true,
  "data": { },
  "error": null,
  "meta": null
}
```

| Field | Type | Description |
|---|---|---|
| `success` | `boolean` | Whether the request succeeded |
| `data` | `object \| array \| null` | Response payload |
| `error` | `object \| null` | Error details (null on success) |
| `meta` | `object \| null` | Pagination or additional metadata |

### Pagination Format

Paginated list endpoints return a `meta` object:

```json
{
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "totalPages": 8
  }
}
```

| Field | Type | Description |
|---|---|---|
| `page` | `integer` | Current page number (1-indexed) |
| `limit` | `integer` | Items per page |
| `total` | `integer` | Total number of matching items |
| `totalPages` | `integer` | Total number of pages |

### Error Format

```json
{
  "success": false,
  "data": null,
  "error": {
    "statusCode": 400,
    "message": "Validation failed",
    "error": "Bad Request",
    "details": [
      {
        "field": "email",
        "message": "email must be a valid email address"
      }
    ]
  },
  "meta": null
}
```

| Field | Type | Description |
|---|---|---|
| `statusCode` | `integer` | HTTP status code |
| `message` | `string` | Human-readable error message |
| `error` | `string` | Error type / HTTP reason phrase |
| `details` | `array \| null` | Field-level validation errors |

### Standard HTTP Status Codes

| Code | Meaning |
|---|---|
| `200` | OK |
| `201` | Created |
| `204` | No Content |
| `400` | Bad Request (validation error) |
| `401` | Unauthorized (missing or invalid token) |
| `403` | Forbidden (insufficient permissions) |
| `404` | Not Found |
| `409` | Conflict (duplicate resource) |
| `422` | Unprocessable Entity |
| `429` | Too Many Requests (rate limit) |
| `500` | Internal Server Error |

### Rate Limiting

Rate limit headers are returned on all responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 99
X-RateLimit-Reset: 1711836000
```

Unless stated otherwise, the default rate limit is **100 requests per 15-minute window** per authenticated user (or IP for unauthenticated routes).

---

## Auth Module

**Prefix:** `/api/v1/auth`

---

### 1. POST /api/v1/auth/register

Register a new user with email and password.

**Auth Required:** No
**Rate Limit:** 10 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "string",
  "password": "string",
  "firstName": "string",
  "lastName": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `email` | `string` | Yes | Valid email format, max 255 chars |
| `password` | `string` | Yes | Min 8 chars, at least 1 uppercase, 1 number |
| `firstName` | `string` | Yes | Min 1, max 50 chars |
| `lastName` | `string` | Yes | Min 1, max 50 chars |

#### Response — 201 Created

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "firstName": "Jane",
      "lastName": "Doe",
      "avatarUrl": null,
      "createdAt": "2026-03-30T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed (invalid email, weak password, missing fields) |
| `409` | Email already registered |

---

### 2. POST /api/v1/auth/login

Login with email and password.

**Auth Required:** No
**Rate Limit:** 20 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "string",
  "password": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `email` | `string` | Yes | Valid email format |
| `password` | `string` | Yes | Non-empty string |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@example.com",
      "firstName": "Jane",
      "lastName": "Doe",
      "avatarUrl": "https://cdn.stylo.ai/avatars/507f1f77bcf86cd799439011.jpg",
      "createdAt": "2026-03-30T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Invalid email or password |

---

### 3. POST /api/v1/auth/google

Login or register using Google OAuth ID token.

**Auth Required:** No
**Rate Limit:** 20 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "idToken": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `idToken` | `string` | Yes | Valid Firebase Google ID token |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@gmail.com",
      "firstName": "Jane",
      "lastName": "Doe",
      "avatarUrl": "https://lh3.googleusercontent.com/...",
      "isNewUser": false,
      "createdAt": "2026-03-30T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  },
  "error": null,
  "meta": null
}
```

| Field | Description |
|---|---|
| `isNewUser` | `true` if account was just created, `false` if existing |

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing or malformed idToken |
| `401` | Invalid or expired Google ID token |

---

### 4. POST /api/v1/auth/apple

Login or register using Apple Sign-In identity token.

**Auth Required:** No
**Rate Limit:** 20 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "identityToken": "string",
  "authorizationCode": "string",
  "firstName": "string",
  "lastName": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `identityToken` | `string` | Yes | Valid Apple identity token (JWT) |
| `authorizationCode` | `string` | Yes | Apple authorization code |
| `firstName` | `string` | No | Only present on first sign-in; max 50 chars |
| `lastName` | `string` | No | Only present on first sign-in; max 50 chars |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "507f1f77bcf86cd799439011",
      "email": "user@privaterelay.appleid.com",
      "firstName": "Jane",
      "lastName": "Doe",
      "avatarUrl": null,
      "isNewUser": true,
      "createdAt": "2026-03-30T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expiresIn": 3600
    }
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing or malformed tokens |
| `401` | Invalid or expired Apple identity token |

---

### 5. POST /api/v1/auth/refresh

Refresh the JWT access token using a valid refresh token.

**Auth Required:** No
**Rate Limit:** 30 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "refreshToken": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `refreshToken` | `string` | Yes | Non-empty string |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing refreshToken |
| `401` | Invalid, expired, or revoked refresh token |

---

### 6. POST /api/v1/auth/logout

Logout and invalidate the current refresh token.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "refreshToken": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `refreshToken` | `string` | Yes | Non-empty string |

#### Response — 204 No Content

```json
{
  "success": true,
  "data": null,
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

### 7. POST /api/v1/auth/forgot-password

Request a password reset email.

**Auth Required:** No
**Rate Limit:** 5 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `email` | `string` | Yes | Valid email format |

#### Response — 200 OK

Returns 200 regardless of whether the email exists (prevents user enumeration).

```json
{
  "success": true,
  "data": {
    "message": "If an account with that email exists, a reset link has been sent."
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid email format |
| `429` | Rate limit exceeded |

---

### 8. POST /api/v1/auth/reset-password

Reset password using a valid reset token.

**Auth Required:** No
**Rate Limit:** 10 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "token": "string",
  "newPassword": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `token` | `string` | Yes | Non-empty, valid reset token (UUID or signed JWT) |
| `newPassword` | `string` | Yes | Min 8 chars, at least 1 uppercase, 1 number |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Password reset successfully."
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed or password does not meet requirements |
| `401` | Invalid or expired reset token |

---

## Users Module

**Prefix:** `/api/v1/users`

---

### 9. GET /api/v1/users/me

Get the authenticated user's profile.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439011",
    "email": "user@example.com",
    "firstName": "Jane",
    "lastName": "Doe",
    "avatarUrl": "https://cdn.stylo.ai/avatars/507f1f77bcf86cd799439011.jpg",
    "bodyMeasurements": {
      "height": 168,
      "weight": 62,
      "bust": 88,
      "waist": 68,
      "hips": 94
    },
    "subscription": {
      "plan": "premium",
      "status": "active",
      "expiresAt": "2027-03-30T00:00:00.000Z"
    },
    "hasStyleProfile": true,
    "createdAt": "2026-03-30T10:00:00.000Z",
    "updatedAt": "2026-03-30T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

### 10. PATCH /api/v1/users/me

Update the authenticated user's profile.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

All fields are optional. Only provided fields are updated.

```json
{
  "firstName": "string",
  "lastName": "string",
  "bodyMeasurements": {
    "height": "number",
    "weight": "number",
    "bust": "number",
    "waist": "number",
    "hips": "number"
  }
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `firstName` | `string` | No | Min 1, max 50 chars |
| `lastName` | `string` | No | Min 1, max 50 chars |
| `bodyMeasurements.height` | `number` | No | 50–300 cm |
| `bodyMeasurements.weight` | `number` | No | 20–500 kg |
| `bodyMeasurements.bust` | `number` | No | 40–200 cm |
| `bodyMeasurements.waist` | `number` | No | 30–200 cm |
| `bodyMeasurements.hips` | `number` | No | 40–200 cm |

#### Response — 200 OK

Returns the updated user object (same schema as GET /me).

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |

---

### 11. DELETE /api/v1/users/me

Soft-delete the authenticated user's account. Data is retained for 30 days before permanent deletion.

**Auth Required:** Yes
**Rate Limit:** 5 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "password": "string",
  "reason": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `password` | `string` | Yes | User's current password for confirmation |
| `reason` | `string` | No | Optional deletion reason; max 500 chars |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Account scheduled for deletion. You have 30 days to cancel.",
    "deletionDate": "2026-04-29T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing or incorrect password |
| `401` | Missing or invalid access token |

---

### 12. PUT /api/v1/users/me/avatar

Upload or replace the user's avatar image.

**Auth Required:** Yes
**Rate Limit:** 10 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: multipart/form-data
```

#### Request Body (multipart/form-data)

| Field | Type | Required | Validation |
|---|---|---|---|
| `file` | `file` | Yes | JPEG, PNG, or WebP; max 5 MB; min 100x100 px |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "avatarUrl": "https://cdn.stylo.ai/avatars/507f1f77bcf86cd799439011.jpg"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid file type, file too large, or image too small |
| `401` | Missing or invalid access token |

---

### 13. GET /api/v1/users/me/stats

Get aggregated statistics for the authenticated user.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "wardrobe": {
      "totalGarments": 48,
      "byCategory": {
        "tops": 14,
        "bottoms": 10,
        "dresses": 6,
        "outerwear": 4,
        "shoes": 8,
        "accessories": 6
      },
      "totalValue": 3240.00
    },
    "outfits": {
      "totalSaved": 22,
      "totalWorn": 47,
      "mostWornOutfitId": "507f1f77bcf86cd799439055",
      "lastWornAt": "2026-03-28T08:00:00.000Z"
    },
    "favorites": {
      "total": 9
    },
    "joinedAt": "2026-03-30T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

## Style Profile Module

**Prefix:** `/api/v1/style-profile`

---

### 14. POST /api/v1/style-profile

Create the user's style profile from onboarding quiz results.

**Auth Required:** Yes
**Rate Limit:** 10 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "aesthetics": ["string"],
  "favoriteColors": ["string"],
  "avoidColors": ["string"],
  "occasions": ["string"],
  "fitPreferences": {
    "tops": "string",
    "bottoms": "string",
    "dresses": "string"
  },
  "budgetRange": {
    "min": "number",
    "max": "number",
    "currency": "string"
  },
  "favoriteBrands": ["string"],
  "climateZone": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `aesthetics` | `string[]` | Yes | 1–5 items from enum: `casual`, `classic`, `bohemian`, `streetwear`, `minimalist`, `romantic`, `athleisure`, `preppy`, `edgy`, `elegant` |
| `favoriteColors` | `string[]` | Yes | 1–10 items; valid CSS color names or hex codes |
| `avoidColors` | `string[]` | No | 0–10 items |
| `occasions` | `string[]` | Yes | 1–6 items from enum: `everyday`, `work`, `formal`, `sport`, `travel`, `party` |
| `fitPreferences.tops` | `string` | No | Enum: `fitted`, `relaxed`, `oversized` |
| `fitPreferences.bottoms` | `string` | No | Enum: `skinny`, `slim`, `straight`, `wide`, `flared` |
| `fitPreferences.dresses` | `string` | No | Enum: `fitted`, `a-line`, `flowy`, `structured` |
| `budgetRange.min` | `number` | No | >= 0 |
| `budgetRange.max` | `number` | No | >= min |
| `budgetRange.currency` | `string` | No | ISO 4217 currency code (e.g. `USD`) |
| `favoriteBrands` | `string[]` | No | 0–10 items; max 50 chars each |
| `climateZone` | `string` | No | Enum: `tropical`, `dry`, `temperate`, `continental`, `polar` |

#### Response — 201 Created

```json
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439022",
    "userId": "507f1f77bcf86cd799439011",
    "aesthetics": ["minimalist", "classic"],
    "favoriteColors": ["#FFFFFF", "#000000", "navy"],
    "avoidColors": ["neon-green"],
    "occasions": ["everyday", "work"],
    "fitPreferences": {
      "tops": "relaxed",
      "bottoms": "straight",
      "dresses": "a-line"
    },
    "budgetRange": {
      "min": 50,
      "max": 300,
      "currency": "USD"
    },
    "favoriteBrands": ["Zara", "COS"],
    "climateZone": "temperate",
    "createdAt": "2026-03-30T10:00:00.000Z",
    "updatedAt": "2026-03-30T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `409` | Style profile already exists for this user (use PATCH to update) |

---

### 15. GET /api/v1/style-profile

Get the authenticated user's style profile.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Response — 200 OK

Returns the style profile object (same schema as the POST response `data`).

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `404` | Style profile not found (user has not completed quiz) |

---

### 16. PATCH /api/v1/style-profile

Update the authenticated user's style preferences. All fields optional.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

Same schema as POST /style-profile but all fields optional. Only provided fields are updated.

#### Response — 200 OK

Returns the updated style profile object.

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `404` | Style profile not found |

---

## Wardrobe Module

**Prefix:** `/api/v1/wardrobe`

---

### 17. GET /api/v1/wardrobe/garments

List the authenticated user's garments with pagination and filtering.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `page` | `integer` | No | `1` | Page number |
| `limit` | `integer` | No | `20` | Items per page (max 100) |
| `category` | `string` | No | — | Filter by category enum: `tops`, `bottoms`, `dresses`, `outerwear`, `shoes`, `accessories`, `bags`, `activewear` |
| `color` | `string` | No | — | Filter by color name or hex |
| `season` | `string` | No | — | Enum: `spring`, `summer`, `autumn`, `winter`, `all-season` |
| `occasion` | `string` | No | — | Enum: `everyday`, `work`, `formal`, `sport`, `travel`, `party` |
| `brand` | `string` | No | — | Filter by brand name (partial match) |
| `minPrice` | `number` | No | — | Minimum purchase price |
| `maxPrice` | `number` | No | — | Maximum purchase price |
| `includeDeleted` | `boolean` | No | `false` | Include soft-deleted garments (trash view) |
| `sortBy` | `string` | No | `createdAt` | Sort field: `createdAt`, `updatedAt`, `name`, `price` |
| `sortOrder` | `string` | No | `desc` | `asc` or `desc` |

#### Response — 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439033",
      "name": "White Linen Shirt",
      "category": "tops",
      "subcategory": "shirts",
      "colors": ["white"],
      "brand": "COS",
      "size": "M",
      "material": "linen",
      "season": ["spring", "summer"],
      "occasion": ["everyday", "work"],
      "imageUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033.jpg",
      "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg",
      "price": 79.00,
      "currency": "USD",
      "purchaseDate": "2025-06-15",
      "tags": ["summer-staple", "work-ready"],
      "isDeleted": false,
      "timesWorn": 12,
      "lastWornAt": "2026-03-28T00:00:00.000Z",
      "createdAt": "2026-01-10T10:00:00.000Z",
      "updatedAt": "2026-03-28T10:00:00.000Z"
    }
  ],
  "error": null,
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 48,
    "totalPages": 3
  }
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid query parameter values |
| `401` | Missing or invalid access token |

---

### 18. POST /api/v1/wardrobe/garments

Add a new garment by uploading an image. AI classification is triggered automatically.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: multipart/form-data
```

#### Request Body (multipart/form-data)

| Field | Type | Required | Validation |
|---|---|---|---|
| `file` | `file` | Yes | JPEG, PNG, WebP, or HEIC; max 20 MB |
| `name` | `string` | No | Max 100 chars; auto-generated by AI if omitted |
| `category` | `string` | No | Enum (see above); auto-classified by AI if omitted |
| `brand` | `string` | No | Max 100 chars |
| `size` | `string` | No | Max 20 chars (e.g., `S`, `M`, `38`, `10`) |
| `price` | `number` | No | >= 0 |
| `currency` | `string` | No | ISO 4217 currency code |
| `purchaseDate` | `string` | No | ISO 8601 date (YYYY-MM-DD) |
| `tags` | `string` | No | Comma-separated list; max 10 tags; each max 30 chars |

#### Response — 201 Created

```json
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439033",
    "name": "White Linen Shirt",
    "category": "tops",
    "subcategory": "shirts",
    "colors": ["white", "off-white"],
    "brand": null,
    "size": null,
    "material": "linen",
    "season": ["spring", "summer"],
    "occasion": ["everyday", "work"],
    "imageUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033.jpg",
    "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg",
    "backgroundRemovedUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_nobg.png",
    "price": null,
    "currency": null,
    "purchaseDate": null,
    "tags": [],
    "aiClassification": {
      "confidence": 0.94,
      "rawLabels": ["shirt", "linen", "white", "formal"],
      "processedAt": "2026-03-30T10:00:05.000Z"
    },
    "isDeleted": false,
    "timesWorn": 0,
    "lastWornAt": null,
    "createdAt": "2026-03-30T10:00:00.000Z",
    "updatedAt": "2026-03-30T10:00:05.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid file type, file too large, or validation failed |
| `401` | Missing or invalid access token |
| `422` | AI classification service failed |

---

### 19. GET /api/v1/wardrobe/garments/:id

Get a single garment's full detail.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the garment |

#### Response — 200 OK

Returns the full garment object (same schema as the POST response `data`).

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `403` | Garment belongs to another user |
| `404` | Garment not found |

---

### 20. PATCH /api/v1/wardrobe/garments/:id

Update one or more attributes of a garment.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the garment |

#### Request Body

All fields optional. Only provided fields are updated.

```json
{
  "name": "string",
  "category": "string",
  "subcategory": "string",
  "colors": ["string"],
  "brand": "string",
  "size": "string",
  "material": "string",
  "season": ["string"],
  "occasion": ["string"],
  "price": "number",
  "currency": "string",
  "purchaseDate": "string",
  "tags": ["string"]
}
```

| Field | Type | Validation |
|---|---|---|
| `name` | `string` | Max 100 chars |
| `category` | `string` | Enum: `tops`, `bottoms`, `dresses`, `outerwear`, `shoes`, `accessories`, `bags`, `activewear` |
| `subcategory` | `string` | Max 50 chars |
| `colors` | `string[]` | 1–5 items |
| `brand` | `string` | Max 100 chars |
| `size` | `string` | Max 20 chars |
| `material` | `string` | Max 100 chars |
| `season` | `string[]` | Enum values: `spring`, `summer`, `autumn`, `winter`, `all-season` |
| `occasion` | `string[]` | Enum values: `everyday`, `work`, `formal`, `sport`, `travel`, `party` |
| `price` | `number` | >= 0 |
| `currency` | `string` | ISO 4217 |
| `purchaseDate` | `string` | ISO 8601 date |
| `tags` | `string[]` | Max 10 items; each max 30 chars |

#### Response — 200 OK

Returns the updated garment object.

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `403` | Garment belongs to another user |
| `404` | Garment not found |

---

### 21. DELETE /api/v1/wardrobe/garments/:id

Soft-delete a garment (moves to trash, recoverable for 30 days).

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the garment |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Garment moved to trash.",
    "deletionDate": "2026-04-29T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `403` | Garment belongs to another user |
| `404` | Garment not found |

---

### 22. POST /api/v1/wardrobe/garments/:id/restore

Restore a soft-deleted garment from trash.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the garment |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Garment restored successfully.",
    "garmentId": "507f1f77bcf86cd799439033"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `403` | Garment belongs to another user |
| `404` | Garment not found or not in trash |

---

### 23. GET /api/v1/wardrobe/garments/search

Search garments using natural language (e.g., "blue formal dress for summer").

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `q` | `string` | Yes | — | Natural language search query; max 200 chars |
| `page` | `integer` | No | `1` | Page number |
| `limit` | `integer` | No | `20` | Items per page (max 50) |

#### Response — 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439033",
      "name": "Navy Midi Dress",
      "category": "dresses",
      "colors": ["navy"],
      "imageUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033.jpg",
      "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg",
      "relevanceScore": 0.91
    }
  ],
  "error": null,
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 3,
    "totalPages": 1
  }
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing or empty `q` parameter |
| `401` | Missing or invalid access token |

---

### 24. GET /api/v1/wardrobe/garments/stats

Get aggregated wardrobe statistics for the authenticated user.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "totalGarments": 48,
    "totalInTrash": 3,
    "totalValue": 3240.00,
    "currency": "USD",
    "byCategory": {
      "tops": 14,
      "bottoms": 10,
      "dresses": 6,
      "outerwear": 4,
      "shoes": 8,
      "accessories": 6
    },
    "bySeason": {
      "spring": 20,
      "summer": 18,
      "autumn": 15,
      "winter": 10,
      "all-season": 12
    },
    "byColor": [
      { "color": "black", "count": 12 },
      { "color": "white", "count": 9 },
      { "color": "navy", "count": 6 }
    ],
    "mostWornGarmentId": "507f1f77bcf86cd799439033",
    "leastWornCount": 5,
    "neverWornCount": 11
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

## Outfits Module

**Prefix:** `/api/v1/outfits`

---

### 25. POST /api/v1/outfits/generate

Generate an AI outfit recommendation based on context (weather, occasion, style profile).

**Auth Required:** Yes
**Rate Limit:** 20 requests / 15 min per user (free); 60 / 15 min (premium)

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "occasion": "string",
  "weatherContext": {
    "temperature": "number",
    "condition": "string",
    "unit": "string"
  },
  "excludeGarmentIds": ["string"],
  "preferGarmentIds": ["string"],
  "count": "number"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `occasion` | `string` | No | Enum: `everyday`, `work`, `formal`, `sport`, `travel`, `party` |
| `weatherContext.temperature` | `number` | No | -60 to 60 |
| `weatherContext.condition` | `string` | No | Enum: `sunny`, `cloudy`, `rainy`, `snowy`, `windy`, `humid` |
| `weatherContext.unit` | `string` | No | Enum: `celsius`, `fahrenheit`; default `celsius` |
| `excludeGarmentIds` | `string[]` | No | Array of valid MongoDB ObjectIds |
| `preferGarmentIds` | `string[]` | No | Array of valid MongoDB ObjectIds (anchor items) |
| `count` | `integer` | No | 1–5; default `1` |

#### Response — 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "temp_rec_a1b2c3",
      "garments": [
        {
          "id": "507f1f77bcf86cd799439033",
          "name": "White Linen Shirt",
          "category": "tops",
          "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg"
        },
        {
          "id": "507f1f77bcf86cd799439044",
          "name": "Navy Slim Trousers",
          "category": "bottoms",
          "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439044_thumb.jpg"
        },
        {
          "id": "507f1f77bcf86cd799439055",
          "name": "White Leather Sneakers",
          "category": "shoes",
          "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439055_thumb.jpg"
        }
      ],
      "reasoning": "A clean, minimalist look suitable for a warm work day. The linen shirt provides breathability.",
      "occasion": "work",
      "score": 0.88,
      "isSaved": false
    }
  ],
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `402` | Free tier limit reached (upgrade required) |
| `422` | Insufficient wardrobe items to generate recommendation |

---

### 26. GET /api/v1/outfits

List saved outfits for the authenticated user.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `page` | `integer` | No | `1` | Page number |
| `limit` | `integer` | No | `20` | Items per page (max 50) |
| `occasion` | `string` | No | — | Filter by occasion |
| `sortBy` | `string` | No | `createdAt` | `createdAt`, `updatedAt`, `name`, `timesWorn` |
| `sortOrder` | `string` | No | `desc` | `asc` or `desc` |

#### Response — 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439066",
      "name": "Monday Work Look",
      "occasion": "work",
      "garments": [
        {
          "id": "507f1f77bcf86cd799439033",
          "name": "White Linen Shirt",
          "category": "tops",
          "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg"
        }
      ],
      "coverImageUrl": "https://cdn.stylo.ai/outfits/507f1f77bcf86cd799439066_cover.jpg",
      "isFavorited": true,
      "timesWorn": 4,
      "lastWornAt": "2026-03-28T00:00:00.000Z",
      "aiGenerated": true,
      "createdAt": "2026-03-10T10:00:00.000Z"
    }
  ],
  "error": null,
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 22,
    "totalPages": 2
  }
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

### 27. GET /api/v1/outfits/:id

Get full detail of a single saved outfit.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the outfit |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439066",
    "name": "Monday Work Look",
    "occasion": "work",
    "notes": "Great for warm weather office days",
    "garments": [
      {
        "id": "507f1f77bcf86cd799439033",
        "name": "White Linen Shirt",
        "category": "tops",
        "colors": ["white"],
        "imageUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033.jpg",
        "thumbnailUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_thumb.jpg"
      }
    ],
    "coverImageUrl": "https://cdn.stylo.ai/outfits/507f1f77bcf86cd799439066_cover.jpg",
    "isFavorited": true,
    "timesWorn": 4,
    "wornDates": ["2026-03-28", "2026-03-14", "2026-02-28", "2026-02-14"],
    "lastWornAt": "2026-03-28T00:00:00.000Z",
    "feedback": "liked",
    "aiGenerated": true,
    "aiReasoning": "Clean minimalist look for warm work days.",
    "createdAt": "2026-03-10T10:00:00.000Z",
    "updatedAt": "2026-03-28T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |

---

### 28. POST /api/v1/outfits

Save a custom outfit (manually curated by the user).

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "name": "string",
  "garmentIds": ["string"],
  "occasion": "string",
  "notes": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `name` | `string` | Yes | Min 1, max 100 chars |
| `garmentIds` | `string[]` | Yes | 2–10 valid MongoDB ObjectIds owned by the user |
| `occasion` | `string` | No | Enum: `everyday`, `work`, `formal`, `sport`, `travel`, `party` |
| `notes` | `string` | No | Max 500 chars |

#### Response — 201 Created

Returns the created outfit object (same schema as GET /:id response `data`).

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed or garmentIds reference garments not owned by user |
| `401` | Missing or invalid access token |

---

### 29. PATCH /api/v1/outfits/:id

Update an outfit's name, garments, occasion, or notes.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the outfit |

#### Request Body

All fields optional.

```json
{
  "name": "string",
  "garmentIds": ["string"],
  "occasion": "string",
  "notes": "string"
}
```

| Field | Type | Validation |
|---|---|---|
| `name` | `string` | Min 1, max 100 chars |
| `garmentIds` | `string[]` | 2–10 valid MongoDB ObjectIds owned by user |
| `occasion` | `string` | Enum values |
| `notes` | `string` | Max 500 chars |

#### Response — 200 OK

Returns the updated outfit object.

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |

---

### 30. DELETE /api/v1/outfits/:id

Permanently delete a saved outfit.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the outfit |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Outfit deleted successfully."
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |

---

### 31. POST /api/v1/outfits/:id/wear

Mark an outfit as worn today. Increments wear count and updates wear history.

**Auth Required:** Yes
**Rate Limit:** 10 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the outfit |

#### Request Body

```json
{
  "date": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `date` | `string` | No | ISO 8601 date (YYYY-MM-DD); defaults to today (UTC) |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "outfitId": "507f1f77bcf86cd799439066",
    "timesWorn": 5,
    "lastWornAt": "2026-03-30T00:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid date format or date in the future |
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |
| `409` | Outfit already marked as worn on the specified date |

---

### 32. POST /api/v1/outfits/:id/feedback

Submit like or dislike feedback on an outfit (used to improve AI recommendations).

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `id` | `string` | MongoDB ObjectId of the outfit |

#### Request Body

```json
{
  "feedback": "string",
  "reason": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `feedback` | `string` | Yes | Enum: `liked`, `disliked` |
| `reason` | `string` | No | Only when `disliked`; max 300 chars; free text or enum: `wrong_style`, `wrong_occasion`, `colors_clash`, `missing_item`, `other` |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "outfitId": "507f1f77bcf86cd799439066",
    "feedback": "liked",
    "updatedAt": "2026-03-30T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid feedback value |
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |

---

## Favorites Module

**Prefix:** `/api/v1/favorites`

---

### 33. GET /api/v1/favorites

List all outfits the authenticated user has favorited.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|---|---|---|---|---|
| `page` | `integer` | No | `1` | Page number |
| `limit` | `integer` | No | `20` | Items per page (max 50) |

#### Response — 200 OK

```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439077",
      "outfit": {
        "id": "507f1f77bcf86cd799439066",
        "name": "Monday Work Look",
        "occasion": "work",
        "coverImageUrl": "https://cdn.stylo.ai/outfits/507f1f77bcf86cd799439066_cover.jpg",
        "garmentCount": 3,
        "timesWorn": 4
      },
      "savedAt": "2026-03-15T10:00:00.000Z"
    }
  ],
  "error": null,
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 9,
    "totalPages": 1
  }
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

### 34. POST /api/v1/favorites

Add an outfit to favorites.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "outfitId": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `outfitId` | `string` | Yes | Valid MongoDB ObjectId |

#### Response — 201 Created

```json
{
  "success": true,
  "data": {
    "id": "507f1f77bcf86cd799439077",
    "outfitId": "507f1f77bcf86cd799439066",
    "savedAt": "2026-03-30T10:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid outfitId |
| `401` | Missing or invalid access token |
| `403` | Outfit belongs to another user |
| `404` | Outfit not found |
| `409` | Outfit already in favorites |

---

### 35. DELETE /api/v1/favorites/:outfitId

Remove an outfit from favorites.

**Auth Required:** Yes
**Rate Limit:** 30 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Path Parameters

| Parameter | Type | Description |
|---|---|---|
| `outfitId` | `string` | MongoDB ObjectId of the outfit to unfavorite |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Removed from favorites."
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `404` | Outfit not found in favorites |

---

## Weather Module

**Prefix:** `/api/v1/weather`

---

### 36. GET /api/v1/weather/current

Get the current weather for a given geographic coordinate. Used to provide context for outfit recommendations.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Query Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `lat` | `number` | Yes | Latitude (-90 to 90) |
| `lon` | `number` | Yes | Longitude (-180 to 180) |
| `unit` | `string` | No | `celsius` (default) or `fahrenheit` |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "location": {
      "city": "London",
      "country": "GB",
      "lat": 51.5074,
      "lon": -0.1278
    },
    "current": {
      "temperature": 14,
      "feelsLike": 12,
      "unit": "celsius",
      "condition": "cloudy",
      "conditionDescription": "Overcast clouds",
      "humidity": 78,
      "windSpeed": 15,
      "uvIndex": 2,
      "icon": "cloudy"
    },
    "forecast": [
      {
        "date": "2026-03-31",
        "high": 16,
        "low": 9,
        "condition": "rainy"
      },
      {
        "date": "2026-04-01",
        "high": 18,
        "low": 11,
        "condition": "sunny"
      }
    ],
    "clothingAdvice": {
      "recommendLayers": true,
      "umbrellaNeeded": false,
      "sunscreenNeeded": false
    }
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Missing or invalid `lat`/`lon` values |
| `401` | Missing or invalid access token |
| `503` | Weather provider unavailable |

---

## Subscriptions Module

**Prefix:** `/api/v1/subscriptions`

---

### 37. GET /api/v1/subscriptions

Get the authenticated user's current subscription status.

**Auth Required:** Yes
**Rate Limit:** 60 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
```

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "plan": "premium",
    "status": "active",
    "billingPeriod": "monthly",
    "currentPeriodStart": "2026-03-01T00:00:00.000Z",
    "currentPeriodEnd": "2026-04-01T00:00:00.000Z",
    "cancelAtPeriodEnd": false,
    "trialEnd": null,
    "provider": "apple",
    "features": {
      "outfitGenerationsPerDay": 999,
      "wardrobeItemLimit": 999,
      "virtualTryOn": true,
      "advancedAnalytics": true
    }
  },
  "error": null,
  "meta": null
}
```

| Field | Description |
|---|---|
| `plan` | `free`, `premium`, `premium_annual` |
| `status` | `active`, `trialing`, `past_due`, `canceled`, `expired` |
| `provider` | `stripe`, `apple`, `google` |

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |

---

### 38. POST /api/v1/subscriptions

Create or upgrade a subscription.

**Auth Required:** Yes
**Rate Limit:** 10 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "plan": "string",
  "provider": "string",
  "purchaseToken": "string",
  "productId": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `plan` | `string` | Yes | Enum: `premium`, `premium_annual` |
| `provider` | `string` | Yes | Enum: `stripe`, `apple`, `google` |
| `purchaseToken` | `string` | Yes | Provider-specific purchase/receipt token |
| `productId` | `string` | Yes | App Store / Play Store product ID |

#### Response — 201 Created

Returns the updated subscription object (same schema as GET /subscriptions `data`).

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Validation failed |
| `401` | Missing or invalid access token |
| `402` | Purchase verification failed |
| `409` | Active subscription already exists |

---

### 39. POST /api/v1/subscriptions/cancel

Cancel the current subscription (takes effect at end of billing period).

**Auth Required:** Yes
**Rate Limit:** 5 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "reason": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `reason` | `string` | No | Max 500 chars |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "message": "Subscription will be canceled at the end of the current billing period.",
    "cancelAtPeriodEnd": true,
    "currentPeriodEnd": "2026-04-01T00:00:00.000Z"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `401` | Missing or invalid access token |
| `404` | No active subscription found |
| `422` | Subscription managed by App Store or Play Store (must cancel there) |

---

### 40. POST /api/v1/subscriptions/restore

Restore a previous subscription purchase (iOS/Android restore purchases flow).

**Auth Required:** Yes
**Rate Limit:** 10 requests / 15 min per user

#### Request Headers

```
Authorization: Bearer {jwt_access_token}
Content-Type: application/json
```

#### Request Body

```json
{
  "provider": "string",
  "purchaseToken": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `provider` | `string` | Yes | Enum: `apple`, `google` |
| `purchaseToken` | `string` | Yes | Provider receipt or purchase token |

#### Response — 200 OK

```json
{
  "success": true,
  "data": {
    "restored": true,
    "subscription": {
      "plan": "premium",
      "status": "active",
      "currentPeriodEnd": "2026-04-01T00:00:00.000Z"
    }
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid provider or token |
| `401` | Missing or invalid access token |
| `404` | No restorable purchase found |

---

## Waitlist Module

**Prefix:** `/api/v1/waitlist`

---

### 41. POST /api/v1/waitlist

Join the Stylo AI waitlist.

**Auth Required:** No
**Rate Limit:** 5 requests / 15 min per IP

#### Request Headers

```
Content-Type: application/json
```

#### Request Body

```json
{
  "email": "string",
  "firstName": "string",
  "referralCode": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `email` | `string` | Yes | Valid email format; max 255 chars |
| `firstName` | `string` | No | Max 50 chars |
| `referralCode` | `string` | No | Alphanumeric; max 20 chars |

#### Response — 201 Created

```json
{
  "success": true,
  "data": {
    "message": "You're on the list! We'll notify you when Stylo AI is ready.",
    "position": 1247,
    "referralCode": "JANE2026"
  },
  "error": null,
  "meta": null
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid email format |
| `409` | Email already on waitlist |

---

## AI Service (Internal)

**Base URL:** `http://ai-service:8000`
**Note:** These endpoints are internal microservice calls made from the NestJS backend. They are NOT directly accessible by clients. Authentication between services uses a shared secret passed via the `X-Internal-Secret` header.

---

### 42. POST /ai/remove-background

Remove the background from a garment image using Rembg.

**Internal Auth:** `X-Internal-Secret` header

#### Request Headers

```
Content-Type: application/json
X-Internal-Secret: {shared_secret}
```

#### Request Body

```json
{
  "imageUrl": "string",
  "outputFormat": "string",
  "model": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `imageUrl` | `string` | Yes | Valid HTTPS URL to a JPEG, PNG, or WebP image |
| `outputFormat` | `string` | No | `png` (default) or `webp` |
| `model` | `string` | No | Rembg model name; default `u2net` |

#### Response — 200 OK

```json
{
  "success": true,
  "outputUrl": "https://cdn.stylo.ai/garments/507f1f77bcf86cd799439033_nobg.png",
  "processingTimeMs": 1240,
  "model": "u2net"
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid or unreachable imageUrl |
| `401` | Missing or invalid internal secret |
| `422` | Failed to process image (unsupported format or corrupt file) |
| `500` | Internal AI service error |

---

### 43. POST /ai/classify

Classify a garment image to extract category, subcategory, colors, material, season, and occasion using CLIP embeddings.

**Internal Auth:** `X-Internal-Secret` header

#### Request Headers

```
Content-Type: application/json
X-Internal-Secret: {shared_secret}
```

#### Request Body

```json
{
  "imageUrl": "string",
  "backgroundRemovedUrl": "string"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `imageUrl` | `string` | Yes | Valid HTTPS URL to original garment image |
| `backgroundRemovedUrl` | `string` | No | URL to the background-removed version for better classification |

#### Response — 200 OK

```json
{
  "success": true,
  "classification": {
    "name": "White Linen Button-Down Shirt",
    "category": "tops",
    "subcategory": "shirts",
    "colors": ["white", "off-white"],
    "material": "linen",
    "pattern": "solid",
    "fit": "relaxed",
    "season": ["spring", "summer"],
    "occasion": ["everyday", "work"],
    "style": ["minimalist", "classic"],
    "confidence": 0.94,
    "rawLabels": [
      { "label": "shirt", "score": 0.97 },
      { "label": "linen", "score": 0.91 },
      { "label": "white", "score": 0.99 },
      { "label": "casual", "score": 0.73 }
    ]
  },
  "processingTimeMs": 830,
  "model": "clip-vit-large-patch14"
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid or unreachable imageUrl |
| `401` | Missing or invalid internal secret |
| `422` | Classification confidence below threshold |
| `500` | Internal AI service error |

---

### 44. POST /ai/recommend

Generate outfit recommendations from a user's wardrobe embeddings and context.

**Internal Auth:** `X-Internal-Secret` header

#### Request Headers

```
Content-Type: application/json
X-Internal-Secret: {shared_secret}
```

#### Request Body

```json
{
  "userId": "string",
  "garments": [
    {
      "id": "string",
      "category": "string",
      "colors": ["string"],
      "occasion": ["string"],
      "season": ["string"],
      "style": ["string"],
      "embeddingVector": ["number"]
    }
  ],
  "context": {
    "occasion": "string",
    "weatherCondition": "string",
    "temperatureCelsius": "number",
    "userStyleProfile": {
      "aesthetics": ["string"],
      "favoriteColors": ["string"],
      "fitPreferences": {}
    }
  },
  "excludeGarmentIds": ["string"],
  "preferGarmentIds": ["string"],
  "count": "number"
}
```

| Field | Type | Required | Validation |
|---|---|---|---|
| `userId` | `string` | Yes | MongoDB ObjectId |
| `garments` | `array` | Yes | Min 3 garments |
| `garments[].id` | `string` | Yes | MongoDB ObjectId |
| `garments[].embeddingVector` | `number[]` | No | CLIP embedding (512-dim); used if available for better matching |
| `context.occasion` | `string` | No | Enum of occasions |
| `context.weatherCondition` | `string` | No | Enum: `sunny`, `cloudy`, `rainy`, `snowy`, `windy`, `humid` |
| `context.temperatureCelsius` | `number` | No | -60 to 60 |
| `count` | `integer` | No | 1–5; default `1` |

#### Response — 200 OK

```json
{
  "success": true,
  "recommendations": [
    {
      "garmentIds": [
        "507f1f77bcf86cd799439033",
        "507f1f77bcf86cd799439044",
        "507f1f77bcf86cd799439055"
      ],
      "score": 0.88,
      "reasoning": "Clean minimalist look. Linen shirt provides breathability for warm weather. Navy trousers offer a polished contrast.",
      "colorHarmony": "complementary",
      "occasionFit": 0.92,
      "weatherFit": 0.85
    }
  ],
  "processingTimeMs": 290,
  "model": "stylo-recommender-v2"
}
```

#### Error Responses

| Status | Condition |
|---|---|
| `400` | Invalid request body or fewer than 3 garments provided |
| `401` | Missing or invalid internal secret |
| `422` | Insufficient data to generate recommendation |
| `500` | Internal AI service error |

---

## Appendix

### Garment Category Enum

```
tops | bottoms | dresses | outerwear | shoes | accessories | bags | activewear
```

### Occasion Enum

```
everyday | work | formal | sport | travel | party
```

### Season Enum

```
spring | summer | autumn | winter | all-season
```

### Aesthetic / Style Enum

```
casual | classic | bohemian | streetwear | minimalist | romantic | athleisure | preppy | edgy | elegant
```

### Subscription Plan Enum

```
free | premium | premium_annual
```

### Subscription Status Enum

```
active | trialing | past_due | canceled | expired
```

### Climate Zone Enum

```
tropical | dry | temperate | continental | polar
```

### JWT Token Lifetimes

| Token | Lifetime |
|---|---|
| Access Token | 1 hour |
| Refresh Token | 30 days |
| Password Reset Token | 1 hour |

### File Upload Limits

| Resource | Max Size | Accepted Formats |
|---|---|---|
| User Avatar | 5 MB | JPEG, PNG, WebP |
| Garment Image | 20 MB | JPEG, PNG, WebP, HEIC |

### Storage URL Structure

```
https://cdn.stylo.ai/avatars/{userId}.{ext}
https://cdn.stylo.ai/garments/{garmentId}.{ext}
https://cdn.stylo.ai/garments/{garmentId}_thumb.{ext}
https://cdn.stylo.ai/garments/{garmentId}_nobg.png
https://cdn.stylo.ai/outfits/{outfitId}_cover.{ext}
```

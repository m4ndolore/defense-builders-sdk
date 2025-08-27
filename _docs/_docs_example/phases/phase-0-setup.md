# Phase 0: Setup - Ship Tonight! (2-3 hours)

## Overview

Get a working app deployed to Cloud Run TODAY. Focus only on the absolute essentials - authentication and a basic dashboard that proves the system works.

## Goals

- Working authentication with Google
- Deploy to Cloud Run immediately
- Basic dashboard showing user's name
- See it live on the web tonight

## Features & Tasks

### 1. Complete Firebase Auth (30 mins)

**Goal**: Finish the authentication setup already in progress

**Steps**:

1. Complete Google OAuth configuration
2. Test sign-in flow locally
3. Add sign-out button
4. Store user email/name in context

### 2. Basic Dashboard (30 mins)

**Goal**: Simple page that shows we have a working system

**Steps**:

1. Create dashboard route with protection
2. Display "Welcome, [User Name]!"
3. Show user email
4. Add sign-out button
5. Maybe add current date/time to prove it's live

### 3. Cloud Run Deployment (1-2 hours)

**Goal**: Get it live on the internet NOW

**Steps**:

1. Create Dockerfile for Next.js app
2. Set up Google Cloud project
3. Configure Cloud Build
4. Deploy to Cloud Run
5. Map to a domain (or use Cloud Run URL)

### 4. Environment & Security (30 mins)

**Goal**: Secure the deployment

**Steps**:

1. Set Firebase env vars in Cloud Run
2. Enable HTTPS only
3. Test authentication flow in production
4. Verify Firebase security rules

## Deliverables

- Live URL anyone can access
- Working Google sign-in
- Dashboard shows logged-in user's info
- Deployed on Cloud Run

## Success Criteria

- Can share URL with someone
- They can sign in with Google
- They see their name on dashboard
- It doesn't break

## Time Estimate

2-3 hours MAX - Ship tonight!

## Next Phase Preview

Tomorrow: Import the 100 companies and build profile editing

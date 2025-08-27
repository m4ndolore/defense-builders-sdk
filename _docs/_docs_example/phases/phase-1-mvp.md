# Phase 1: MVP Sprint - Get It Working! (3-5 days)

## Overview

Replace your Airtable/Sheets workflow ASAP. Import existing data, let companies view/edit profiles, submit check-ins, and browse the directory. Ship daily.

## Goals

- Import 100 companies from Sheets → Firestore
- Company profile view/edit functionality
- Simple check-in form that works
- Basic cohort directory (read-only)
- Companies can log in and update their info

## Features & Tasks

### Day 1: Data Import & Models

**Goal**: Get your existing data into Firebase

**Steps**:

1. Create Firestore collections (companies, users, checkins)
2. Build import script for Google Sheets data
3. Map existing fields to Firestore schema
4. Run import and verify data
5. Create TypeScript interfaces

### Day 2: Company Profiles

**Goal**: Companies can view and edit their information

**Steps**:

1. Profile page showing all company data
2. Simple edit form (no fancy inline editing yet)
3. Save changes to Firestore
4. Basic validation
5. Show success/error messages

### Day 3: Check-in Form

**Goal**: Replace your current check-in process

**Steps**:

1. Simple form with your existing questions
2. Save to Firestore on submit
3. Show previous check-ins list
4. Add timestamp and status
5. Test with a few companies

### Day 4: Cohort Directory

**Goal**: Browse all companies in the program

**Steps**:

1. List view with company cards
2. Basic search by name
3. Click to view full profile
4. Show key info (name, description, logo)
5. Make it mobile-friendly

### Day 5: Polish & Deploy

**Goal**: Clean up and ship the MVP

**Steps**:

1. Fix critical bugs
2. Add loading states
3. Improve error messages
4. Deploy updates to Cloud Run
5. Test with real users

## Quick Wins to Add If Time

- Profile completion percentage
- Export check-ins to CSV
- Filter directory by industry
- Basic admin view of all companies
- Email notification for check-ins

## NOT Doing Yet

- Fancy UI animations
- Complex permissions
- Analytics dashboards
- Networking features
- Resource center

## Deliverables

- All 100 companies imported
- Companies can sign in and edit profiles
- Check-in form replaces current process
- Directory shows all companies
- Daily deployments to Cloud Run

## Success Criteria

- You can stop using Airtable for check-ins
- Companies successfully update their profiles
- Data doesn't get lost
- It works on mobile
- Load time under 3 seconds

## Time Estimate

3-5 days of focused work

## Next Phase Preview

Week 2: Make it beautiful and add admin tools

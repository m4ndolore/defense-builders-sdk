# User Flow - Digital Incubator

## User Types

1. **Participants** - Company founders/representatives in the incubator
2. **Mentors** - Advisors assigned to companies
3. **Administrators** - Incubator staff managing the program
4. **Public Visitors** - External viewers of public profiles

## Authentication Flow

### First-Time Access

1. User receives invitation email with unique link
2. Clicks link → Landing page with program branding
3. "Sign in with Google" button
4. Google OAuth flow
5. Account verification against whitelist
6. Initial profile setup wizard
7. Redirect to dashboard

### Returning Users

1. Navigate to app URL
2. Auto-redirect to sign-in if not authenticated
3. Google OAuth (often automatic)
4. Direct to dashboard

## Main Navigation Structure

### Dashboard (Home)

- Welcome message with quick stats
- Action cards for common tasks
- Recent activity feed
- Upcoming deadlines/milestones
- Quick links to key features

### Profile Management

1. **View Mode**

   - Company information display
   - Progress indicators
   - Public/private toggle
   - Edit button

2. **Edit Mode**
   - Inline editing of fields
   - Image upload for logo
   - Save/cancel options
   - Validation feedback

### Check-in Process

1. Dashboard reminder/prompt
2. Click "Submit Check-in"
3. Multi-step form:
   - Current status
   - Challenges faced
   - Help needed
   - Milestone updates
4. Preview submission
5. Confirm and submit
6. Success confirmation

### Cohort Directory

1. Grid/list view toggle
2. Search bar
3. Filter options:
   - Industry
   - Stage
   - Location
   - Looking for connections
4. Company cards with:
   - Logo
   - Name
   - Quick info
   - "View Profile" button
5. Click to view detailed profile
6. "Connect" button (if logged in)

### Networking Features

1. **Connection Requests**

   - Send request with message
   - Receive notifications
   - Accept/decline flow
   - Connected companies list

2. **Collaboration Board**
   - Post opportunities
   - Browse requests
   - Filter by type
   - Respond to posts

### Resource Center

1. Category navigation
2. Search functionality
3. Resource cards:
   - Title
   - Type icon
   - Description
   - Access button
4. Download/view actions
5. Bookmark favorites

### Analytics View

1. Personal dashboard tab
2. Company metrics:
   - Progress charts
   - Milestone timeline
   - Engagement score
3. Cohort comparison (anonymous)
4. Export data option

## Key User Journeys

### Weekly Check-in Journey

1. Email reminder received
2. Click link in email
3. Auto-login (if cookie present)
4. Pre-filled check-in form
5. Update information
6. Submit
7. View confirmation
8. Optional: Update profile

### Finding a Collaborator Journey

1. Navigate to directory
2. Use filters to narrow search
3. Browse company profiles
4. Read detailed information
5. Send connection request
6. Wait for response
7. Exchange messages
8. Schedule meeting (external)

### Resource Access Journey

1. Receive notification about new resource
2. Navigate to Resource Center
3. Browse or search
4. Click to access
5. Download/view resource
6. Rate/feedback option
7. Share with team

## Mobile Considerations

- Responsive design throughout
- Touch-optimized controls
- Simplified navigation menu
- Swipe gestures for common actions
- Offline capability for viewing
- Progressive web app features

## Error States & Edge Cases

- Expired invitation links
- Non-whitelisted email attempts
- Form validation errors
- Network connectivity issues
- Concurrent editing conflicts
- Session timeouts
- Invalid data imports

## Notifications & Communications

1. **In-app notifications**

   - New connections
   - Check-in reminders
   - Resource updates
   - Milestone achievements

2. **Email notifications**

   - Weekly digests
   - Important updates
   - Connection requests
   - Admin announcements

3. **Push notifications** (future)
   - Urgent updates
   - Real-time alerts

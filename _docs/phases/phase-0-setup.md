# Phase 0: Foundation Setup - Ship Tonight (2-3 hours)

## Overview
Get the Defense Builders SDK marketplace foundation deployed and running with basic authentication and a simple landing page. This phase focuses on proving the deployment pipeline works and establishing the core infrastructure.

## Goals
- ✅ Deploy a working application to Vercel
- ✅ Set up basic authentication system
- ✅ Establish GitHub repository and CI/CD
- ✅ Create minimal viable landing page
- ✅ Deploy basic API server

## Features & Tasks

### 1. Repository & Project Setup (30 minutes)
**Steps:**
1. Initialize monorepo with Turborepo
2. Configure TypeScript and ESLint
3. Set up package.json scripts
4. Create basic README
5. Configure .gitignore and .env.example

**Success Criteria:**
- Repository created and pushed to GitHub
- Local development environment runs
- Linting and type checking work

### 2. Landing Page with Auth (60 minutes)
**Steps:**
1. Create Next.js app with TypeScript
2. Add Tailwind CSS and theme configuration
3. Implement hero section with value proposition
4. Add Auth0/Clerk for authentication
5. Create protected dashboard route

**Success Criteria:**
- Landing page displays at root URL
- Users can sign up and log in
- Dashboard route requires authentication
- Dark theme by default

### 3. Basic API Setup (45 minutes)
**Steps:**
1. Create Django REST API project
2. Configure CORS for frontend
3. Add health check endpoint
4. Implement JWT authentication
5. Connect to PostgreSQL (local)

**Success Criteria:**
- API responds to health checks
- Authentication endpoints work
- Frontend can call API
- Database migrations run

### 4. Vercel Deployment (30 minutes)
**Steps:**
1. Connect GitHub repo to Vercel
2. Configure environment variables
3. Set up preview deployments
4. Deploy production build
5. Configure custom domain (if available)

**Success Criteria:**
- Site accessible at Vercel URL
- Authentication works in production
- Preview deployments on PRs
- No console errors

### 5. Basic Monitoring (15 minutes)
**Steps:**
1. Add Vercel Analytics
2. Set up error tracking (Sentry)
3. Configure uptime monitoring
4. Add basic logging
5. Create status page

**Success Criteria:**
- Page views tracked
- Errors reported to Sentry
- Uptime monitoring active
- Logs accessible

## Deliverables
1. **Live Website**: https://defense-builders-sdk.vercel.app
2. **GitHub Repository**: Public repo with initial code
3. **Documentation**: Basic README with setup instructions
4. **Authentication**: Working signup/login flow
5. **API Health Check**: GET /api/health returns 200

## File Structure After Phase 0
```
defense-builders-sdk/
├── apps/
│   ├── web/                 # Next.js frontend
│   │   ├── app/
│   │   │   ├── page.tsx     # Landing page
│   │   │   ├── dashboard/   # Protected routes
│   │   │   └── api/         # API routes
│   │   └── package.json
│   └── api/                  # Django backend
│       ├── manage.py
│       ├── requirements.txt
│       └── core/
├── packages/
│   ├── ui/                  # Shared components
│   └── config/              # Shared config
├── .github/
│   └── workflows/
│       └── deploy.yml       # CI/CD pipeline
├── turbo.json               # Turborepo config
├── package.json             # Root package.json
└── README.md
```

## Success Criteria Checklist
- [ ] Website loads without errors
- [ ] Users can create accounts
- [ ] Users can log in/out
- [ ] Protected routes redirect to login
- [ ] API returns health status
- [ ] Deployments trigger on git push
- [ ] Mobile responsive design
- [ ] Dark mode enabled

## Time Breakdown
- **Total Time**: 3 hours
- **Setup & Config**: 45 minutes
- **Feature Development**: 2 hours
- **Deployment & Testing**: 15 minutes

## Tech Stack for Phase 0
- **Frontend**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Django REST Framework, PostgreSQL
- **Auth**: Auth0 or Clerk
- **Hosting**: Vercel (frontend), Railway/Render (backend)
- **Monitoring**: Vercel Analytics, Sentry

## NOT Doing Yet (Defer to Phase 1)
- Environment provisioning
- SDK integrations
- Payment processing
- User profiles
- Project management
- Team features
- Advanced UI components
- Email notifications
- File uploads
- Search functionality

## Common Issues & Solutions

### Issue: Auth0 redirect URLs
**Solution**: Add both localhost and production URLs to Auth0 settings

### Issue: CORS errors
**Solution**: Configure Django CORS headers for Vercel domain

### Issue: Database connection
**Solution**: Use DATABASE_URL environment variable

### Issue: TypeScript errors
**Solution**: Set "strict": false initially, fix incrementally

## Commands to Run
```bash
# Initial setup
npx create-turbo@latest defense-builders-sdk
cd defense-builders-sdk

# Install dependencies
npm install

# Run development
npm run dev

# Deploy to Vercel
vercel --prod

# Django setup
cd apps/api
python -m venv venv
source venv/bin/activate
pip install django djangorestframework django-cors-headers
python manage.py migrate
python manage.py runserver
```

## Environment Variables
```env
# Frontend (.env.local)
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_AUTH0_DOMAIN=your-domain.auth0.com
NEXT_PUBLIC_AUTH0_CLIENT_ID=your-client-id

# Backend (.env)
DATABASE_URL=postgresql://user:pass@localhost/defense_builders
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,defense-builders-sdk.vercel.app
```

## Next Phase Preview
Phase 1 will add:
- User profiles and settings
- Basic environment creation
- First SDK integration (TAK Server)
- Project creation and management
- Basic marketplace listing
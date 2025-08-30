# Defense Builders SDK - Quick Start Guide

## Prerequisites
- Node.js 18+ and pnpm
- Python 3.11+
- PostgreSQL (optional, uses SQLite by default)

## Setup Instructions

### 1. Install Dependencies

```bash
# Install pnpm packages for the monorepo
pnpm install

# Set up Python virtual environment for API
cd apps/api
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Database Setup

```bash
# Run Django migrations
cd apps/api
./venv/bin/python manage.py migrate
```

### 3. Running the Development Servers

#### Option A: Run Both Servers (Recommended)
Open two terminal windows:

**Terminal 1 - Frontend (Next.js):**
```bash
pnpm --filter @defense-builders/web dev
# Runs on http://localhost:3000
```

**Terminal 2 - Backend (Django):**
```bash
cd apps/api
./venv/bin/python manage.py runserver
# Runs on http://localhost:8000
```

#### Option B: Using Nix Shell (if you have Nix installed)
```bash
nix develop
# Then run the commands above
```

## Available URLs

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Health Check**: http://localhost:8000/api/health/
- **Django Admin**: http://localhost:8000/admin/

## Project Structure

```
defense-builders-sdk/
├── apps/
│   ├── web/          # Next.js frontend application
│   └── api/          # Django REST API backend
├── packages/         # Shared packages (future)
├── _docs/           # Project documentation
└── flake.nix        # Nix development environment
```

## Common Commands

```bash
# Install new packages
pnpm add <package> --filter @defense-builders/web  # For frontend
cd apps/api && ./venv/bin/pip install <package>    # For backend

# Run linters
pnpm lint

# Build for production
pnpm build
```

## Troubleshooting

1. **Module not found errors**: Run `pnpm install` in the root directory
2. **Django errors**: Make sure the virtual environment is activated
3. **Port already in use**: Check if another process is using ports 3000 or 8000

## Next Steps

- Create a superuser for Django admin: `./venv/bin/python manage.py createsuperuser`
- Set up environment variables in `.env` files
- Configure Clerk authentication keys
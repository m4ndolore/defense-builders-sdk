import { clerkMiddleware, createRouteMatcher } from '@clerk/nextjs/server';

const isProtectedRoute = createRouteMatcher([
  '/dashboard(.*)',
  '/projects(.*)',
  '/environments(.*)',
  '/settings(.*)',
]);

// Temporarily skip auth if no keys are configured
const middleware = process.env.CLERK_SECRET_KEY 
  ? clerkMiddleware((auth, req) => {
      if (isProtectedRoute(req)) auth().protect();
    })
  : (req: any) => {
      console.log('Clerk not configured, skipping auth');
      return;
    };

export default middleware;

export const config = {
  matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
};
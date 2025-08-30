import { SignInButton, SignUpButton, SignedIn, SignedOut, UserButton } from '@clerk/nextjs';
import { auth } from '@clerk/nextjs/server';

export default async function HomePage() {
  const { userId } = await auth();

  return (
    <main className="min-h-screen bg-gray-900">
      {/* Navigation */}
      <nav className="flex justify-between items-center p-6 max-w-7xl mx-auto">
        <div className="text-2xl font-bold text-white">Defense Builders</div>
        <div>
          <SignedOut>
            <SignInButton mode="modal">
              <button className="text-gray-300 hover:text-white mr-4">Sign In</button>
            </SignInButton>
            <SignUpButton mode="modal">
              <button className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded">
                Get Started
              </button>
            </SignUpButton>
          </SignedOut>
          <SignedIn>
            <UserButton afterSignOutUrl="/" />
          </SignedIn>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-6 py-20 text-center">
        <h1 className="text-5xl md:text-6xl font-bold mb-6 text-white">
          Defense Builders SDK Platform
        </h1>
        <p className="text-2xl mb-4 text-gray-300">
          The Uber for Defense Tech Builders
        </p>
        <p className="text-lg mb-12 text-gray-400 max-w-2xl mx-auto">
          Connect with government problem owners. Build with ready-to-use SDKs. 
          Get paid for your expertise.
        </p>

        {!userId && (
          <div className="flex justify-center gap-4">
            <SignUpButton mode="modal">
              <button className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-8 rounded-lg text-lg">
                Join as Builder
              </button>
            </SignUpButton>
            <SignUpButton mode="modal">
              <button className="bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-3 px-8 rounded-lg text-lg">
                Post a Project
              </button>
            </SignUpButton>
          </div>
        )}
      </div>

      {/* Feature Grid */}
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-20">
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-2 text-blue-400">Ready-to-Use SDKs</h3>
            <p className="text-gray-400">
              TAK Server, Palantir Foundry, Claude Code, and more - pre-configured and ready to deploy.
            </p>
          </div>
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-2 text-emerald-400">Instant Environments</h3>
            <p className="text-gray-400">
              Spin up development environments in minutes, not days. Focus on building, not configuring.
            </p>
          </div>
          <div className="bg-gray-800 p-6 rounded-lg">
            <h3 className="text-xl font-bold mb-2 text-purple-400">Secure Marketplace</h3>
            <p className="text-gray-400">
              Connect with verified builders and problem owners. Get paid securely through our platform.
            </p>
          </div>
        </div>
      </div>
    </main>
  );
}
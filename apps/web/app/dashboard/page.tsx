import { auth } from '@clerk/nextjs/server';
import { redirect } from 'next/navigation';

export default async function DashboardPage() {
  const { userId } = await auth();
  
  if (!userId) {
    redirect('/');
  }

  return (
    <div className="min-h-screen bg-gray-900">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h1 className="text-3xl font-bold text-white mb-8">Dashboard</h1>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Quick Actions */}
          <div className="bg-gray-800 rounded-lg p-6">
            <h2 className="text-xl font-semibold text-white mb-4">Quick Actions</h2>
            <div className="space-y-3">
              <button className="w-full text-left px-4 py-2 bg-blue-600 hover:bg-blue-700 rounded text-white">
                Create Environment
              </button>
              <button className="w-full text-left px-4 py-2 bg-emerald-600 hover:bg-emerald-700 rounded text-white">
                Browse Projects
              </button>
              <button className="w-full text-left px-4 py-2 bg-purple-600 hover:bg-purple-700 rounded text-white">
                Post a Project
              </button>
            </div>
          </div>

          {/* Active Environments */}
          <div className="bg-gray-800 rounded-lg p-6">
            <h2 className="text-xl font-semibold text-white mb-4">Active Environments</h2>
            <p className="text-gray-400">No active environments yet.</p>
            <button className="mt-4 text-blue-400 hover:text-blue-300">
              + Create your first environment
            </button>
          </div>

          {/* Recent Projects */}
          <div className="bg-gray-800 rounded-lg p-6">
            <h2 className="text-xl font-semibold text-white mb-4">Recent Projects</h2>
            <p className="text-gray-400">No projects yet.</p>
            <button className="mt-4 text-emerald-400 hover:text-emerald-300">
              Browse available projects
            </button>
          </div>

import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import { ClerkProvider } from '@clerk/nextjs';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Defense Builders SDK - Uber for Defense Tech',
  description: 'Marketplace platform connecting defense tech builders with government problem owners',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <ClerkProvider 
      appearance={{
        variables: {
          colorPrimary: '#0EA5E9',
          colorBackground: '#111827',
          colorText: '#ffffff',
          colorInputBackground: '#1f2937',
          colorInputText: '#ffffff',
        },
        elements: {
          formButtonPrimary: 
            'bg-blue-500 hover:bg-blue-600',
          card: 'bg-gray-800',
        }
      }}
    >
      <html lang="en">
        <body className={inter.className}>{children}</body>
      </html>
    </ClerkProvider>
  );
}
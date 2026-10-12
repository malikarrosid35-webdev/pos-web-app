import { useEffect, useState } from "react";

/**
 * Shows a slim top banner when the browser detects it is offline.
 * Disappears automatically once connectivity is restored.
 *
 * Uses an inline SVG (instead of importing an icon library) because this
 * component is rendered eagerly for every page — pulling in a shared
 * icon/UI vendor chunk here would force it to be preloaded before the
 * router even decides which route (e.g. the login page) to show.
 */
export default function OfflineBanner() {
  const [isOffline, setIsOffline] = useState(!navigator.onLine);

  useEffect(() => {
    const goOffline = () => setIsOffline(true);
    const goOnline = () => setIsOffline(false);

    window.addEventListener("offline", goOffline);
    window.addEventListener("online", goOnline);

    return () => {
      window.removeEventListener("offline", goOffline);
      window.removeEventListener("online", goOnline);
    };
  }, []);

  if (!isOffline) return null;

  return (
    <div
      role="alert"
      className="fixed top-0 inset-x-0 z-[100] flex items-center justify-center gap-2 bg-red-600 text-white text-sm font-medium py-2 px-4 shadow"
    >
      <WifiOffIcon size={15} className="shrink-0" />
      Tidak ada koneksi internet — beberapa fitur mungkin tidak tersedia
    </div>
  );
}

function WifiOffIcon({ size = 15, className }) {
  return (
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={className}
      aria-hidden="true"
    >
      <line x1="2" x2="22" y1="2" y2="22" />
      <path d="M8.5 16.5a5 5 0 0 1 7 0" />
      <path d="M2 8.82a15 15 0 0 1 4.17-2.65" />
      <path d="M10.66 5c4.01-.36 8.14.9 11.34 3.76" />
      <path d="M16.85 11.25a10 10 0 0 1 2.22 1.68" />
      <path d="M5 13a10 10 0 0 1 5.24-2.76" />
      <line x1="12" x2="12.01" y1="20" y2="20" />
    </svg>
  );
}
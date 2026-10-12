import { useState } from "react";
import { Download, X, Smartphone } from "lucide-react";
import { usePwaInstall } from "../hooks/usePwaInstall.js";

/**
 * Shows a compact install banner on the login screen when the browser supports
 * installing the app as a PWA.
 */
export default function PwaInstallBanner() {
  const { canInstall, promptInstall, isInstalled } = usePwaInstall();
  const [dismissed, setDismissed] = useState(false);

  const handleInstall = async () => {
    await promptInstall();
    setDismissed(true);
  };

  if (!canInstall || isInstalled || dismissed) {
    return null;
  }

  return (
    <div
      role="alert"
      className="flex items-start gap-3 rounded-xl border border-amber-200 bg-amber-50/95 px-4 py-3 text-sm text-amber-900 shadow-sm backdrop-blur"
    >
      <div className="mt-0.5 flex h-8 w-8 shrink-0 items-center justify-center rounded-full bg-amber-100 text-amber-700">
        <Smartphone size={16} />
      </div>

      <div className="flex-1">
        <p className="font-semibold">Pasang aplikasi ini</p>
        <p className="mt-1 leading-5 text-amber-800">
          Buka aplikasi lebih cepat dari layar utama dan gunakan fitur yang lebih
          stabil.
        </p>
      </div>

      <div className="flex shrink-0 items-center gap-2">
        <button
          type="button"
          onClick={handleInstall}
          className="inline-flex items-center gap-1 rounded-lg bg-amber-600 px-3 py-2 font-medium text-white transition hover:bg-amber-700"
        >
          <Download size={14} />
          Pasang
        </button>
        <button
          type="button"
          onClick={() => setDismissed(true)}
          className="rounded-lg p-2 text-amber-700 transition hover:bg-amber-100"
          aria-label="Tutup banner pemasangan aplikasi"
        >
          <X size={16} />
        </button>
      </div>
    </div>
  );
}

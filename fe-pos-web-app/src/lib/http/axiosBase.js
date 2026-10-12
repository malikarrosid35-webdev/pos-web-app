import axios from "axios";
import Swal from "sweetalert2";
import { useAuthStore } from "../../stores/useAuthStore.js";
import { toApiUrl } from "./apiOrigin.js";

let hasShownSessionExpired = false;

function handleSessionExpired() {
  if (hasShownSessionExpired) return;
  hasShownSessionExpired = true;

  try {
    useAuthStore.getState().clearUser();
  } catch (e) {
    console.error("Gagal clear user session:", e);
  }

  Swal.fire({
    icon: "warning",
    title: "Sesi Anda Kadaluarsa",
    text: "Sesi Anda telah habis, silahkan login kembali.",
    confirmButtonColor: "#3085d6",
    allowOutsideClick: false,
  }).then(() => {
    window.location.href = "/login";
    setTimeout(() => {
      hasShownSessionExpired = false;
    }, 1000);
  });
}

export function createAxios(roleBasePath) {
  const baseURL = toApiUrl(roleBasePath);
  const instance = axios.create({
    baseURL,
    withCredentials: true,
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "X-Requested-With": "XMLHttpRequest",
    },
  });

  instance.interceptors.request.use(
    (config) => {
      config.withCredentials = true;
      console.log(`[REQUEST] ${config.method.toUpperCase()} ${config.url}`);
      console.log("[REQUEST] Cookies:", document.cookie);
      console.log("[REQUEST] WithCredentials:", config.withCredentials);
      return config;
    },
    (error) => Promise.reject(error),
  );

  let refreshing = null;
  instance.interceptors.response.use(
    (res) => res,
    async (error) => {
      const original = error.config;
      if (error.response?.status !== 401 || original._retry) {
        return Promise.reject(error);
      }
      original._retry = true;
      if (!refreshing) {
        console.log("[REFRESH] Attempting token refresh...");
        refreshing = axios
          .post(
            toApiUrl(`${roleBasePath}/auth/refresh`),
            {},
            {
              withCredentials: true,
              headers: {
                Accept: "application/json",
                "Content-Type": "application/json",
              },
            },
          )
          .then((response) => {
            console.log("[REFRESH] Success");
            return response;
          })
          .catch((err) => {
            console.error("[REFRESH] Failed:", err.response?.status);
            throw err;
          })
          .finally(() => {
            refreshing = null;
          });
      }

      try {
        await refreshing;
        console.log("[REFRESH] Retrying original request...");
        original.withCredentials = true;
        return instance(original);
      } catch (refreshError) {
        console.error("[REFRESH] Error:", refreshError);

        const status = refreshError.response?.status;

        if (status === 401 || status === 403) {
          handleSessionExpired();
        }

        return Promise.reject(refreshError);
      }
    },
  );

  return instance;
}
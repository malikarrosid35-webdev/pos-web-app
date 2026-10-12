const rawApiOrigin = (import.meta.env.VITE_API_ORIGIN || "").trim();

const API_ORIGIN = rawApiOrigin.replace(/\/+$/, "");

export const toApiUrl = (path) => `${API_ORIGIN}${path}`;

export default API_ORIGIN;
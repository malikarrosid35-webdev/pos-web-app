import { create } from "zustand";

const STORAGE_KEY = "authStore";

const loadStoreSessions = () => {
  if (typeof window === "undefined") {
    return { admin: null, kasir: null, owner: null };
  }

  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    if (!raw) return { admin: null, kasir: null, owner: null };

    const parsed = JSON.parse(raw);
    return {
      admin: parsed.admin || null,
      kasir: parsed.kasir || null,
      owner: parsed.owner || null,
    };
  } catch {
    return { admin: null, kasir: null, owner: null };
  }
};

const saveStoreSessions = (sessions) => {
  if (typeof window === "undefined") return;
  localStorage.setItem(STORAGE_KEY, JSON.stringify(sessions));
};

const getInitialState = () => {
  const sessions = loadStoreSessions();

  if (typeof window === "undefined") {
    return {
      user: null,
      role: null,
      sessions,
    };
  }

  const path = window.location.pathname || "";
  let currentRole = null;
  let currentUser = null;

  if (path.startsWith("/admin") && sessions.admin?.user) {
    currentRole = "admin";
    currentUser = sessions.admin.user;
  } else if (path.startsWith("/kasir") && sessions.kasir?.user) {
    currentRole = "kasir";
    currentUser = sessions.kasir.user;
  } else if (path.startsWith("/owner") && sessions.owner?.user) {
    currentRole = "owner";
    currentUser = sessions.owner.user;
  }

  return {
    user: currentUser,
    role: currentRole,
    sessions,
  };
};

export const useAuthStore = create((set) => ({
  ...getInitialState(),

  setUser: (user) =>
    set((state) => {
      const role = user?.role;
      if (!role) return state;

      const currentSessions = loadStoreSessions();
      const newSessions = {
        ...currentSessions,
        [role]: { user, role },
      };

      saveStoreSessions(newSessions);

      return {
        ...state,
        user,
        role,
        sessions: newSessions,
      };
    }),

  clearUser: (roleToClear) =>
    set((state) => {
      const role = roleToClear || state.role;
      if (!role) return state;

      const currentSessions = loadStoreSessions();

      const newSessions = {
        ...currentSessions,
        [role]: null,
      };

      saveStoreSessions(newSessions);

      const isCurrentTabRole = state.role === role;

      return {
        ...state,
        user: isCurrentTabRole ? null : state.user,
        role: isCurrentTabRole ? null : state.role,
        sessions: newSessions,
      };
    }),
}));
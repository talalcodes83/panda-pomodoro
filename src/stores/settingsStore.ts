import { writable } from "svelte/store";
import { get } from "svelte/store";

interface Settings {
  studyTime: number; // minutes
  breakTime: number; // minutes
  totalRounds: number;
  soundEnabled: boolean;
}

function createSettingsStore() {
  const defaultSettings: Settings = {
    studyTime: 25,
    breakTime: 5,
    totalRounds: 4,
    soundEnabled: true,
  };

  const { subscribe, set, update } = writable<Settings>(defaultSettings);

  return {
    subscribe,
    load: async () => {
      try {
        const { Store } = await import("@tauri-apps/plugin-store");
        const store = new Store(".settings.dat");
        const saved = await store.get<Settings>("settings");
        if (saved) {
          set(saved);
        }
      } catch (error) {
        console.error("Failed to load settings:", error);
      }
    },
    save: async (settings: Settings) => {
      try {
        const { Store } = await import("@tauri-apps/plugin-store");
        const store = new Store(".settings.dat");
        await store.set("settings", settings);
        set(settings);
      } catch (error) {
        console.error("Failed to save settings:", error);
      }
    },
    updateSetting: <K extends keyof Settings>(key: K, value: Settings[K]) => {
      update((settings) => {
        const newSettings = { ...settings, [key]: value };
        const store = settingsStore as any;
        store.save(newSettings);
        return newSettings;
      });
    },
    get: () => get({ subscribe }),
  };
}

export const settingsStore = createSettingsStore();


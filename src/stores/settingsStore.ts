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
        const { invoke } = await import("@tauri-apps/api/tauri");
        const appDataDir = await invoke<string>("get_app_data_dir");
        const settingsPath = `${appDataDir}/settings.json`;
        
        try {
          const { readTextFile } = await import("@tauri-apps/api/fs");
          const content = await readTextFile(settingsPath, { encoding: "utf-8" });
          const saved: Settings = JSON.parse(content);
          set(saved);
        } catch (error) {
          // Settings file doesn't exist yet, use defaults
          console.log("Settings file doesn't exist, using defaults");
        }
      } catch (error) {
        console.error("Failed to load settings:", error);
      }
    },
    save: async (settings: Settings) => {
      try {
        const { invoke } = await import("@tauri-apps/api/tauri");
        const { writeTextFile } = await import("@tauri-apps/api/fs");
        const appDataDir = await invoke<string>("get_app_data_dir");
        const settingsPath = `${appDataDir}/settings.json`;
        
        await invoke("ensure_dir", { path: appDataDir });
        await writeTextFile(
          settingsPath,
          JSON.stringify(settings, null, 2),
          { encoding: "utf-8" }
        );
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


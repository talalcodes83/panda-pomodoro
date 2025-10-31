import { writable, get } from "svelte/store";
import { settingsStore } from "./settingsStore";
import { invoke } from "@tauri-apps/api/tauri";

export type TimerMode = "study" | "break" | "complete";
export type TimerState = "idle" | "running" | "paused";

interface Timer {
  mode: TimerMode;
  state: TimerState;
  remainingSeconds: number;
  currentRound: number;
  totalRounds: number;
  isPaused: boolean;
}

function createTimerStore() {
  const { subscribe, set, update } = writable<Timer>({
    mode: "study",
    state: "idle",
    remainingSeconds: 25 * 60,
    currentRound: 1,
    totalRounds: 4,
    isPaused: false,
  });

  let intervalId: number | null = null;

  const timerStore = {
    subscribe,
    loadSettings: () => {
      const settings = get(settingsStore);
      update((timer) => ({
        ...timer,
        remainingSeconds: settings.studyTime * 60,
        totalRounds: settings.totalRounds,
      }));
    },
    start: () => {
      update((timer) => {
        if (timer.state === "idle" || timer.state === "paused") {
          if (intervalId) clearInterval(intervalId);
          intervalId = window.setInterval(() => {
            update((current) => {
              if (current.remainingSeconds > 0) {
                return { ...current, remainingSeconds: current.remainingSeconds - 1 };
              } else {
                timerStore.completeSession();
                return current;
              }
            });
          }, 1000);
          
          invoke("play_sound", { soundType: "start" }).catch(console.error);
          
          return { ...timer, state: "running", isPaused: false };
        }
        return timer;
      });
    },
    pause: () => {
      update((timer) => {
        if (intervalId) {
          clearInterval(intervalId);
          intervalId = null;
        }
        return { ...timer, state: "paused", isPaused: true };
      });
    },
    reset: () => {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
      const settings = get(settingsStore);
      set({
        mode: "study",
        state: "idle",
        remainingSeconds: settings.studyTime * 60,
        currentRound: 1,
        totalRounds: settings.totalRounds,
        isPaused: false,
      });
    },
    completeSession: () => {
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }

      update((timer) => {
        const settings = get(settingsStore);
        
        if (timer.mode === "study") {
          if (timer.currentRound >= timer.totalRounds) {
            // All rounds complete
            invoke("play_sound", { soundType: "complete" }).catch(console.error);
            
            // Reset after 5 seconds
            setTimeout(() => {
              timerStore.reset();
            }, 5000);
            
            return {
              ...timer,
              mode: "complete",
              state: "idle",
            };
          } else {
            // Switch to break
            invoke("play_sound", { soundType: "round_complete" }).catch(console.error);
            
            // Auto-start break after a short delay
            setTimeout(() => {
              timerStore.start();
            }, 1000);
            
            return {
              ...timer,
              mode: "break",
              state: "idle",
              remainingSeconds: settings.breakTime * 60,
              currentRound: timer.currentRound + 1,
            };
          }
        } else {
          // Break complete, back to study
          invoke("play_sound", { soundType: "start" }).catch(console.error);
          
          return {
            ...timer,
            mode: "study",
            state: "idle",
            remainingSeconds: settings.studyTime * 60,
          };
        }
      });
    },
  };

  return timerStore;
}

export const timerStore = createTimerStore();

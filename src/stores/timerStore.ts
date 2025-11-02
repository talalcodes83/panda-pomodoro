import { writable, get } from "svelte/store";
import { settingsStore } from "./settingsStore";
import { invoke } from "@tauri-apps/api/tauri";
import successSound from "../assets/sounds/success-221935.mp3";

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
          if (intervalId) {
            clearInterval(intervalId);
            intervalId = null;
          }
          intervalId = window.setInterval(() => {
            update((current) => {
              if (current.remainingSeconds > 0) {
                return { ...current, remainingSeconds: current.remainingSeconds - 1 };
              } else {
                // Clear interval immediately and complete session
                if (intervalId) {
                  clearInterval(intervalId);
                  intervalId = null;
                }
                // Call completeSession asynchronously to avoid re-entry issues
                setTimeout(() => {
                  timerStore.completeSession();
                }, 0);
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
        
        // Play timer completion sound at normal volume
        const audio = new Audio(successSound);
        audio.volume = 1.0;
        audio.play().catch(console.error);
        
        if (timer.mode === "study") {
          // Study complete, switch to break (same round)
          const breakSeconds = settings.breakTime * 60;
          
          // Auto-start break after a short delay
          setTimeout(() => {
            timerStore.start();
          }, 1500);
          
          return {
            ...timer,
            mode: "break",
            state: "idle",
            remainingSeconds: breakSeconds,
            // Keep currentRound the same - round = study + break
          };
        } else {
          // Break complete
          if (timer.currentRound >= timer.totalRounds) {
            // Last break of last round - all rounds complete
            
            // Reset after 5 seconds
            setTimeout(() => {
              timerStore.reset();
            }, 5000);
            
            return {
              ...timer,
              mode: "complete",
              state: "idle",
              remainingSeconds: 0,
            };
          } else {
            // Break complete, start next round (next study session)
            const studySeconds = settings.studyTime * 60;
            
            // Auto-start next study session after a short delay
            setTimeout(() => {
              timerStore.start();
            }, 1500);
            
            return {
              ...timer,
              mode: "study",
              state: "idle",
              remainingSeconds: studySeconds,
              currentRound: timer.currentRound + 1, // Increment round here
            };
          }
        }
      });
    },
  };

  return timerStore;
}

export const timerStore = createTimerStore();

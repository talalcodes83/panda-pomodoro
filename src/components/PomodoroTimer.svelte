<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { timerStore } from "../stores/timerStore";
  import { settingsStore } from "../stores/settingsStore";
  import { invoke } from "@tauri-apps/api/tauri";
  import TimerDisplay from "./TimerDisplay.svelte";
  import Character from "./Character.svelte";
  import Controls from "./Controls.svelte";
  import SettingsPanel from "./SettingsPanel.svelte";

  export let hideWatermarks = false;
  let showSettings = false;
  let progress = 0;

  $: {
    // Calculate progress
    settingsStore.subscribe((settings) => {
      timerStore.subscribe((timer) => {
        const totalTime =
          timer.mode === "study"
            ? settings.studyTime * 60
            : settings.breakTime * 60;
        progress = ((totalTime - timer.remainingSeconds) / totalTime) * 100;
      })();
    })();
  }

  onMount(async () => {
    // Load settings first (in case App.svelte hasn't completed yet)
    await settingsStore.load();
    // Then update timer with loaded settings
    timerStore.loadSettings();
  });

  function toggleSettings() {
    showSettings = !showSettings;
  }

  function formatTime(seconds: number): string {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, "0")}:${secs.toString().padStart(2, "0")}`;
  }

  function handleComplete() {
    invoke("play_sound", { soundType: "complete" }).catch(console.error);
  }
</script>

<div class="timer-container" class:study-mode={$timerStore.mode === "study"} class:break-mode={$timerStore.mode === "break"} class:complete-mode={$timerStore.mode === "complete"}>
  <Character mode={$timerStore.mode} state={$timerStore.state} />
  
  <TimerDisplay 
    time={formatTime($timerStore.remainingSeconds)}
    mode={$timerStore.mode}
    currentRound={$timerStore.currentRound}
    totalRounds={$timerStore.totalRounds}
    progress={progress}
  />

  <Controls 
    state={$timerStore.state}
    on:start={() => timerStore.start()}
    on:pause={() => timerStore.pause()}
    on:reset={() => timerStore.reset()}
    on:settings={toggleSettings}
  />

  {#if showSettings}
    <SettingsPanel 
      on:close={toggleSettings}
      on:save={async (e) => {
        await settingsStore.save(e.detail);
        timerStore.loadSettings();
        toggleSettings();
      }}
    />
  {/if}

  {#if !hideWatermarks}
    <div class="watermark watermark-top-left">PANDA-POMODORO</div>
    <div class="watermark watermark-bottom-right">By Talal</div>
  {/if}
</div>

<style>
  .timer-container {
    width: 300px;
    height: 300px;
    background: #ffcbd7;
    border: none;
    border-radius: 8px;
    padding: 10px;
    box-shadow: 
      0 0 0 2px #222,
      inset 0 0 0 2px #fff,
      0 8px 16px rgba(0, 0, 0, 0.3);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    position: relative;
    transition: background 0.3s ease;
  }

  /* Make buttons and interactive elements non-draggable */
  .timer-container :global(button),
  .timer-container :global(input),
  .timer-container :global(.controls) {
    -webkit-app-region: no-drag;
  }

  .study-mode {
    background: #ffcbd7;
  }

  .break-mode {
    background: #ffa6ba;
  }

  .complete-mode {
    background: #ffcbd7;
  }

  .watermark {
    position: absolute;
    font-family: 'Press Start 2P', monospace;
    color: rgba(0, 0, 0, 0.7);
    text-shadow: 2px 2px 4px rgba(255, 255, 255, 1);
    pointer-events: none;
    z-index: 1;
    -webkit-app-region: no-drag;
  }

  .watermark-top-left {
    top: 8px;
    left: 8px;
    font-size: 8px;
  }

  .watermark-bottom-right {
    bottom: 8px;
    right: 8px;
    font-size: 6px;
  }
</style>


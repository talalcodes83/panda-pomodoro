<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { timerStore } from "../stores/timerStore";
  import { settingsStore } from "../stores/settingsStore";
  import { invoke } from "@tauri-apps/api/tauri";
  import TimerDisplay from "./TimerDisplay.svelte";
  import Character from "./Character.svelte";
  import Controls from "./Controls.svelte";
  import SettingsPanel from "./SettingsPanel.svelte";

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

  onMount(() => {
    settingsStore.load();
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
      on:save={(e) => {
        settingsStore.save(e.detail);
        timerStore.loadSettings();
        toggleSettings();
      }}
    />
  {/if}
</div>

<style>
  .timer-container {
    width: 300px;
    height: 300px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: 4px solid #333;
    border-radius: 8px;
    padding: 15px;
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

  .study-mode {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .break-mode {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }

  .complete-mode {
    background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
  }
</style>


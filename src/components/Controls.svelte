<script lang="ts">
  import type { TimerState } from "../stores/timerStore";
  import { createEventDispatcher } from "svelte";
  import { appWindow } from "@tauri-apps/api/window";
  import pauseIcon from "../assets/buttons/timer/pause.png";
  import playIcon from "../assets/buttons/timer/play.png";
  import resetIcon from "../assets/buttons/timer/reset.png";
  import settingsIcon from "../assets/buttons/timer/settings.png";
  import closeIcon from "../assets/buttons/timer/close.png";
  import clickSound from "../assets/sounds/click.mp3";

  export let state: TimerState;
  const dispatch = createEventDispatcher();

  // Play click sound at normal volume
  function playClickSound() {
    const audio = new Audio(clickSound);
    audio.volume = 1.0;
    audio.currentTime = 0.15; // Skip first 150ms
    audio.play().catch(console.error);
  }

  function handleStartPause() {
    playClickSound();
    if (state === "idle" || state === "paused") {
      dispatch("start");
    } else {
      dispatch("pause");
    }
  }

  function handleReset() {
    playClickSound();
    dispatch("reset");
  }

  function handleSettings() {
    playClickSound();
    dispatch("settings");
  }

  async function handleClose() {
    playClickSound();
    try {
      await appWindow.close();
    } catch (error) {
      console.error("Failed to close window:", error);
    }
  }
</script>

<div class="controls">
  <button class="control-btn" on:click={handleStartPause} title={state === "running" ? "Pause" : "Start"} class:running={state === "running"}>
    {#if state === "running"}
      <img src={pauseIcon} alt="Pause" class="btn-image" />
    {:else}
      <img src={playIcon} alt="Play" class="btn-image" />
    {/if}
  </button>
  <button class="control-btn" on:click={handleReset} title="Reset">
    <img src={resetIcon} alt="Reset" class="btn-image" />
  </button>
  <button class="control-btn" on:click={handleSettings} title="Settings">
    <img src={settingsIcon} alt="Settings" class="btn-image" />
  </button>
  <button class="control-btn close-btn" on:click={handleClose} title="Close">
    <img src={closeIcon} alt="Close" class="btn-image" />
  </button>
</div>

<style>
  .controls {
    display: flex;
    gap: 8px;
    -webkit-app-region: no-drag;
  }

  .control-btn {
    width: 35px;
    height: 35px;
    border: none;
    background: #fff;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    transition: all 0.2s;
    box-shadow: 
      0 3px 0 rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
    font-family: 'Press Start 2P', monospace;
  }

  .btn-image {
    width: 100%;
    height: 100%;
    object-fit: contain;
    pointer-events: none;
  }

  .control-btn:hover {
    background: #f0f0f0;
    transform: translateY(1px);
    box-shadow: 
      0 2px 0 rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .control-btn:active {
    transform: translateY(3px);
    box-shadow: 
      0 0 0 rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .control-btn.running {
    background: #4ade80;
  }

  .control-btn.running:hover {
    background: #22c55e;
  }

  .control-btn.close-btn {
    background: #f5576c;
  }

  .control-btn.close-btn:hover {
    background: #e63946;
  }
</style>


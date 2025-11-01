<script lang="ts">
  import type { TimerState } from "../stores/timerStore";
  import { createEventDispatcher } from "svelte";
  import { appWindow } from "@tauri-apps/api/window";

  export let state: TimerState;
  const dispatch = createEventDispatcher();

  function handleStartPause() {
    if (state === "idle" || state === "paused") {
      dispatch("start");
    } else {
      dispatch("pause");
    }
  }

  function handleReset() {
    dispatch("reset");
  }

  function handleSettings() {
    dispatch("settings");
  }

  async function handleClose() {
    try {
      await appWindow.close();
    } catch (error) {
      console.error("Failed to close window:", error);
    }
  }

  $: icon = state === "running" ? "⏸" : "▶";
</script>

<div class="controls">
  <button class="control-btn" on:click={handleStartPause} title={state === "running" ? "Pause" : "Start"} class:running={state === "running"}>
    <span class="btn-icon">{icon}</span>
  </button>
  <button class="control-btn" on:click={handleReset} title="Reset">
    <span class="btn-icon">↻</span>
  </button>
  <button class="control-btn" on:click={handleSettings} title="Settings">
    <span class="btn-icon">⚙</span>
  </button>
  <button class="control-btn close-btn" on:click={handleClose} title="Close">
    <span class="btn-icon">✕</span>
  </button>
</div>

<style>
  .controls {
    display: flex;
    gap: 10px;
    -webkit-app-region: no-drag;
  }

  .control-btn {
    width: 40px;
    height: 40px;
    border: 3px solid #333;
    background: #fff;
    border-radius: 6px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    transition: all 0.2s;
    box-shadow: 
      0 3px 0 rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
    font-family: 'Courier New', monospace;
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


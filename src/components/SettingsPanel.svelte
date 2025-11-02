<script lang="ts">
  import { createEventDispatcher, onMount } from "svelte";
  import { settingsStore } from "../stores/settingsStore";
  import type { Settings } from "../stores/settingsStore";
  import clickSound from "../assets/sounds/click.mp3";

  const dispatch = createEventDispatcher();
  let settings: Settings = {
    studyTime: 25,
    breakTime: 5,
    totalRounds: 4,
    soundEnabled: true,
  };

  onMount(() => {
    settingsStore.subscribe((s) => {
      settings = { ...s };
    })();
  });

  // Play click sound at normal volume
  function playClickSound() {
    const audio = new Audio(clickSound);
    audio.volume = 1.0;
    audio.currentTime = 0.12; // Skip first 120ms
    audio.play().catch(console.error);
  }

  function handleSave() {
    playClickSound();
    dispatch("save", settings);
  }

  function handleClose() {
    playClickSound();
    dispatch("close");
  }
</script>

<div class="settings-overlay" on:click={handleClose}>
  <div class="settings-panel" on:click|stopPropagation>
    <div class="settings-header">Settings</div>
    <div class="settings-content">
      <div class="setting-item">
        <label for="studyTime">Study Time (minutes):</label>
        <input
          type="number"
          id="studyTime"
          bind:value={settings.studyTime}
          min="1"
          max="60"
        />
      </div>
      <div class="setting-item">
        <label for="breakTime">Break Time (minutes):</label>
        <input
          type="number"
          id="breakTime"
          bind:value={settings.breakTime}
          min="1"
          max="30"
        />
      </div>
      <div class="setting-item">
        <label for="totalRounds">Total Rounds:</label>
        <input
          type="number"
          id="totalRounds"
          bind:value={settings.totalRounds}
          min="1"
          max="10"
        />
      </div>
      <div class="setting-item">
        <label>
          <input type="checkbox" bind:checked={settings.soundEnabled} on:change={playClickSound} />
          Enable Sound Effects
        </label>
      </div>
      <div class="buttons">
        <button class="save-btn" on:click={handleSave}>Save</button>
        <button class="close-btn" on:click={handleClose}>Close</button>
      </div>
    </div>
  </div>
</div>

<style>
  .settings-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .settings-panel {
    background: #ffcbd7;
    border: none;
    border-radius: 8px;
    padding: 20px;
    width: 90%;
    max-width: 280px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
  }

  .settings-header {
    font-size: 11px;
    font-weight: bold;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    text-align: center;
    margin-bottom: 15px;
  }

  .settings-content {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .setting-item {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .setting-item label {
    font-size: 10px;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    font-weight: bold;
  }

  .setting-item input[type="number"] {
    padding: 8px;
    border: 3px solid #333;
    border-radius: 4px;
    font-size: 11px;
    font-family: 'Press Start 2P', monospace;
    background: #fff;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.1);
  }

  .setting-item input[type="checkbox"] {
    width: 18px;
    height: 18px;
    cursor: pointer;
  }

  .setting-item label:has(input[type="checkbox"]) {
    display: flex;
    align-items: center;
    gap: 8px;
    cursor: pointer;
  }

  .buttons {
    display: flex;
    gap: 10px;
    margin-top: 10px;
  }

  .save-btn,
  .close-btn {
    flex: 1;
    padding: 10px;
    border: none;
    border-radius: 4px;
    background: #fff;
    cursor: pointer;
    font-weight: bold;
    font-family: 'Press Start 2P', monospace;
    font-size: 10px;
    transition: all 0.2s;
    box-shadow: 
      0 3px 0 rgba(0, 0, 0, 0.2),
      inset 0 1px 0 rgba(255, 255, 255, 0.5);
  }

  .save-btn:hover,
  .close-btn:hover {
    background: #f0f0f0;
    transform: translateY(1px);
  }

  .save-btn:active,
  .close-btn:active {
    transform: translateY(3px);
  }
</style>


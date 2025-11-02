<script lang="ts">
  import { onMount } from "svelte";
  import { appWindow } from "@tauri-apps/api/window";
  import PomodoroTimer from "./components/PomodoroTimer.svelte";
  import MusicPlayer from "./components/MusicPlayer.svelte";
  import { timerStore } from "./stores/timerStore";
  import { settingsStore } from "./stores/settingsStore";
  import clickSound from "./assets/sounds/click.mp3";

  let showMusicPlayer = false;
  let isDragging = false;

  onMount(async () => {
    // Load settings first, then update timer
    await settingsStore.load();
    timerStore.loadSettings();
  });

  // Play click sound at normal volume
  function playClickSound() {
    const audio = new Audio(clickSound);
    audio.volume = 1.0;
    audio.currentTime = 0.12; // Skip first 120ms
    audio.play().catch(console.error);
  }

  function toggleMusicPlayer() {
    playClickSound();
    showMusicPlayer = !showMusicPlayer;
  }

  async function handleMouseDown(e: MouseEvent) {
    // Only start dragging if not clicking on interactive elements
    const target = e.target as HTMLElement;
    if (target.tagName === 'BUTTON' || target.tagName === 'INPUT' || 
        target.closest('button') || target.closest('input') || 
        target.closest('.controls') || target.closest('.settings-panel') ||
        target.closest('.music-player')) {
      return;
    }
    
    isDragging = true;
    try {
      await appWindow.startDragging();
    } catch (error) {
      console.error("Failed to start dragging:", error);
    }
  }
</script>

<main class="app" on:mousedown={handleMouseDown} role="application">
  <div class="container">
    <PomodoroTimer hideWatermarks={showMusicPlayer} />
    <button class="music-toggle" on:click={toggleMusicPlayer} title="Toggle Music Player">
      {showMusicPlayer ? "🎵" : "🎶"}
    </button>
    <MusicPlayer visible={showMusicPlayer} />
  </div>
</main>

<style>
  .app {
    width: 300px;
    height: 550px;
    overflow: hidden;
    background: transparent !important;
    font-family: 'Press Start 2P', monospace;
    margin: 0;
    padding: 0;
    cursor: default;
  }

  .container {
    width: 100%;
    height: 100%;
    position: relative;
    background: transparent;
  }

  .music-toggle {
    position: absolute;
    top: 10px;
    right: 10px;
    width: 32px;
    height: 32px;
    border: none;
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.9);
    cursor: pointer;
    font-size: 18px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    z-index: 100;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
    -webkit-app-region: no-drag;
  }

  .music-toggle:hover {
    background: #fff;
    transform: scale(1.1);
  }

  .music-toggle:active {
    transform: scale(0.95);
  }
</style>


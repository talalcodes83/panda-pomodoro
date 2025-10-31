<script lang="ts">
  import { onMount } from "svelte";
  import PomodoroTimer from "./components/PomodoroTimer.svelte";
  import MusicPlayer from "./components/MusicPlayer.svelte";
  import { timerStore } from "./stores/timerStore";
  import { settingsStore } from "./stores/settingsStore";

  let showMusicPlayer = false;

  onMount(() => {
    // Initialize stores
    timerStore.loadSettings();
  });

  function toggleMusicPlayer() {
    showMusicPlayer = !showMusicPlayer;
  }
</script>

<main class="app">
  <div class="container">
    <PomodoroTimer />
    <button class="music-toggle" on:click={toggleMusicPlayer} title="Toggle Music Player">
      {showMusicPlayer ? "🎵" : "🎶"}
    </button>
    {#if showMusicPlayer}
      <MusicPlayer />
    {/if}
  </div>
</main>

<style>
  .app {
    width: 100vw;
    height: 100vh;
    overflow: hidden;
    background: transparent;
    font-family: 'Courier New', monospace;
  }

  .container {
    width: 300px;
    height: 400px;
    position: relative;
  }

  .music-toggle {
    position: absolute;
    top: 10px;
    right: 10px;
    width: 32px;
    height: 32px;
    border: 2px solid #333;
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
  }

  .music-toggle:hover {
    background: #fff;
    transform: scale(1.1);
  }

  .music-toggle:active {
    transform: scale(0.95);
  }
</style>


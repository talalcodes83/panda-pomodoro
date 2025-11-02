<script lang="ts">
  import type { TimerMode } from "../stores/timerStore";

  export let time: string;
  export let mode: TimerMode;
  export let currentRound: number;
  export let totalRounds: number;
  export let progress: number;

  $: modeText = mode === "study" ? "Study Time" : mode === "break" ? "Break Time" : "All Complete! 🎉";
</script>

<div class="timer-display">
  <div class="time-text">{time}</div>
  <div class="mode-text">{modeText}</div>
  
  <div class="rounds-info">
    <div class="rounds-text">
      Round: <span class="round-number">{currentRound}</span> / <span class="round-number">{totalRounds}</span>
    </div>
  </div>
</div>

<style>
  .timer-display {
    text-align: center;
    width: 100%;
  }

  .time-text {
    font-size: 28px;
    font-weight: bold;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    letter-spacing: 2px;
    font-family: 'Press Start 2P', monospace;
    margin-bottom: 5px;
  }

  .mode-text {
    font-size: 10px;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    margin-bottom: 10px;
    font-weight: bold;
  }

  .rounds-info {
    margin-top: 10px;
  }

  .rounds-text {
    font-size: 9px;
    color: #fff;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.3);
    margin-bottom: 5px;
    font-weight: bold;
  }

  .round-number {
    font-size: 10px;
    font-weight: bold;
  }
</style>


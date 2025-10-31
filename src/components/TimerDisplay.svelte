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
    <div class="progress-bar">
      <div class="progress-fill" style="width: {progress}%"></div>
    </div>
  </div>
</div>

<style>
  .timer-display {
    text-align: center;
    width: 100%;
  }

  .time-text {
    font-size: 36px;
    font-weight: bold;
    color: #fff;
    text-shadow: 
      2px 2px 0 #333,
      -1px -1px 0 #333,
      1px -1px 0 #333,
      -1px 1px 0 #333;
    letter-spacing: 2px;
    font-family: 'Courier New', monospace;
    margin-bottom: 5px;
  }

  .mode-text {
    font-size: 12px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-bottom: 10px;
    font-weight: bold;
  }

  .rounds-info {
    margin-top: 10px;
  }

  .rounds-text {
    font-size: 11px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-bottom: 5px;
    font-weight: bold;
  }

  .round-number {
    font-size: 13px;
    font-weight: bold;
  }

  .progress-bar {
    width: 100%;
    height: 8px;
    background: rgba(0, 0, 0, 0.3);
    border: 2px solid #333;
    border-radius: 4px;
    overflow: hidden;
    box-shadow: inset 0 2px 4px rgba(0, 0, 0, 0.3);
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #4ade80, #22c55e);
    transition: width 0.3s ease;
    box-shadow: 0 0 10px rgba(74, 222, 128, 0.5);
  }
</style>


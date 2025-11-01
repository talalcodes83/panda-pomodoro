<script lang="ts">
  import type { TimerMode } from "../stores/timerStore";
  import type { TimerState } from "../stores/timerStore";

  export let mode: TimerMode;
  export let state: TimerState;

  $: expression = mode === "break" ? "happy" : mode === "complete" ? "excited" : state === "running" ? "focused" : "idle";
</script>

<div class="character-container" class:animated={state === "running"}>
  <div class="character" class:expression-focused={expression === "focused"} class:expression-excited={expression === "excited"} class:expression-happy={expression === "happy"} class:expression-idle={expression === "idle"}>
    <div class="face">
      <div class="eye left-eye"></div>
      <div class="eye right-eye"></div>
      <div class="mouth" class:mouth-happy={expression === "happy"} class:mouth-excited={expression === "excited"} class:mouth-focused={expression === "focused"}></div>
    </div>
  </div>
</div>

<style>
  .character-container {
    width: 80px;
    height: 80px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
  }

  .character-container.animated {
    animation: float 3s ease-in-out infinite;
  }

  @keyframes float {
    0%, 100% {
      transform: translateY(0px);
    }
    50% {
      transform: translateY(-10px);
    }
  }

  .character {
    width: 60px;
    height: 60px;
    background: #ffdbac;
    border: 3px solid #333;
    border-radius: 50%;
    position: relative;
    box-shadow: 
      inset 0 -5px 0 rgba(0, 0, 0, 0.1),
      0 3px 0 rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease;
  }

  .character.expression-focused {
    animation: pulse 0.5s ease-in-out infinite alternate;
  }

  .character.expression-excited {
    animation: bounce 0.5s ease-in-out infinite;
  }

  .character.expression-happy {
    /* Happy expression styling */
  }

  .character.expression-idle {
    /* Idle expression styling */
  }

  @keyframes pulse {
    0% {
      transform: scale(1);
    }
    100% {
      transform: scale(1.05);
    }
  }

  @keyframes bounce {
    0%, 100% {
      transform: translateY(0) scale(1);
    }
    50% {
      transform: translateY(-8px) scale(1.1);
    }
  }

  .face {
    width: 100%;
    height: 100%;
    position: relative;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .eye {
    width: 8px;
    height: 8px;
    background: #333;
    border-radius: 50%;
    position: absolute;
    top: 20px;
    animation: blink 4s infinite;
  }

  @keyframes blink {
    0%, 90%, 100% {
      height: 8px;
    }
    92%, 98% {
      height: 1px;
    }
  }

  .left-eye {
    left: 18px;
  }

  .right-eye {
    right: 18px;
  }

  .mouth {
    width: 20px;
    height: 12px;
    border: 2px solid #333;
    border-top: none;
    border-radius: 0 0 20px 20px;
    position: absolute;
    bottom: 15px;
    transition: all 0.3s ease;
  }

  .mouth.mouth-happy {
    border-radius: 0 0 20px 20px;
    height: 15px;
    width: 24px;
  }

  .mouth.mouth-excited {
    width: 24px;
    height: 18px;
    border-radius: 0 0 24px 24px;
  }

  .mouth.mouth-focused {
    width: 18px;
    height: 10px;
  }
</style>


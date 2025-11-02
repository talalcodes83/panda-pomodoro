<script lang="ts">
  import type { TimerMode } from "../stores/timerStore";
  import type { TimerState } from "../stores/timerStore";

  import studyGif from "../assets/buttons/other/character-study-export.gif";
  import breakGif from "../assets/buttons/other/character-break-export.gif";
  
  let gifElement: HTMLImageElement;

  export let mode: TimerMode;
  export let state: TimerState;

  // Determine which animation to show
  $: characterImage = (() => {
    if (mode === "study") {
      return studyGif;
    } else if (mode === "break") {
      return breakGif;
    }
    // Complete mode - use study
    return studyGif;
  })();
  
  $: hasGif = characterImage !== undefined && characterImage !== null;

  // Ensure GIF loops infinitely - just keep src set and let GIF animate naturally
  $: if (gifElement && hasGif && characterImage) {
    // Ensure src is always set - GIF will loop infinitely on its own
    if (gifElement.src !== characterImage) {
      gifElement.src = characterImage;
    }
  }
</script>

<div class="character-container">
  {#if hasGif}
    <img 
      bind:this={gifElement} 
      src={characterImage} 
      alt="" 
      class="character-sprite character-gif"
    />
  {:else}
    <!-- Fallback to old CSS character -->
    <div class="character" class:expression-focused={state === "running"} class:expression-happy={mode === "break"}>
    <div class="face">
      <div class="eye left-eye"></div>
      <div class="eye right-eye"></div>
        <div class="mouth" class:mouth-happy={mode === "break"} class:mouth-focused={state === "running"}></div>
      </div>
    </div>
  {/if}
</div>

<style>
  .character-container {
    width: 180px;
    height: 180px;
    display: flex;
    align-items: center;
    justify-content: center;
    position: relative;
    flex-shrink: 0;
  }

  .character-sprite,
  .character-gif {
    width: 100%;
    height: 100%;
    display: block;
    object-fit: contain;
    image-rendering: pixelated;
    image-rendering: -moz-crisp-edges;
    image-rendering: crisp-edges;
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


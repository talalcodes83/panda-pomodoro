<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { invoke } from "@tauri-apps/api/tauri";
  import { open } from "@tauri-apps/plugin-dialog";
  import { readDir, readTextFile, writeTextFile, createDir } from "@tauri-apps/plugin-fs";

  interface PlaylistItem {
    id: string;
    title: string;
    url: string;
    path: string;
  }

  interface Playlist {
    name: string;
    items: PlaylistItem[];
  }

  let playlists: Playlist[] = [];
  let currentPlaylist: Playlist | null = null;
  let currentTrackIndex = 0;
  let isPlaying = false;
  let isDownloading = false;
  let downloadProgress = "";
  let youtubeUrl = "";
  let audioElement: HTMLAudioElement | null = null;
  let volume = 0.5;

  onMount(async () => {
    await loadPlaylists();
    if (playlists.length > 0) {
      currentPlaylist = playlists[0];
      loadCurrentTrack();
    }
  });

  onDestroy(() => {
    if (audioElement) {
      audioElement.pause();
      audioElement = null;
    }
  });

  async function loadPlaylists() {
    try {
      const appDataDir = await invoke<string>("get_app_data_dir");
      const playlistsDir = `${appDataDir}/playlists`;
      
      try {
        const entries = await readDir(playlistsDir);
        playlists = [];
        
        for (const entry of entries) {
          if (entry.name && entry.name.endsWith(".json")) {
            const content = await readTextFile(`${playlistsDir}/${entry.name}`);
            const playlist: Playlist = JSON.parse(content);
            playlists.push(playlist);
          }
        }
      } catch (error) {
        // Playlists directory doesn't exist yet
        console.log("Playlists directory doesn't exist, will create on first save");
      }
      
      if (playlists.length === 0) {
        // Create default playlist
        currentPlaylist = {
          name: "Study Music",
          items: [],
        };
        playlists.push(currentPlaylist);
        await savePlaylist(currentPlaylist);
      }
    } catch (error) {
      console.error("Failed to load playlists:", error);
    }
  }

  async function savePlaylist(playlist: Playlist) {
    try {
      const appDataDir = await invoke<string>("get_app_data_dir");
      const playlistsDir = `${appDataDir}/playlists`;
      
      try {
        await createDir(playlistsDir, { recursive: true });
      } catch (error) {
        // Directory might already exist
      }
      
      const filename = playlist.name.toLowerCase().replace(/\s+/g, "-") + ".json";
      await writeTextFile(
        `${playlistsDir}/${filename}`,
        JSON.stringify(playlist, null, 2)
      );
    } catch (error) {
      console.error("Failed to save playlist:", error);
    }
  }

  async function downloadFromYouTube() {
    if (!youtubeUrl.trim()) {
      alert("Please enter a YouTube URL");
      return;
    }

    isDownloading = true;
    downloadProgress = "Starting download...";

    try {
      const appDataDir = await invoke<string>("get_app_data_dir");
      const musicDir = `${appDataDir}/music`;
      
      try {
        await createDir(musicDir, { recursive: true });
      } catch (error) {
        // Directory might already exist
      }

      downloadProgress = "Downloading audio...";
      
      const result = await invoke<{ success: boolean; title?: string; path?: string; error?: string }>("download_youtube_audio", {
        url: youtubeUrl,
        outputDir: musicDir,
      });

      if (result.success && result.title && result.path) {
        // Add to current playlist
        if (currentPlaylist) {
          const newItem: PlaylistItem = {
            id: Date.now().toString(),
            title: result.title,
            url: youtubeUrl,
            path: result.path,
          };
          
          currentPlaylist.items.push(newItem);
          await savePlaylist(currentPlaylist);
          
          downloadProgress = `Downloaded: ${result.title}`;
          
          setTimeout(() => {
            downloadProgress = "";
            youtubeUrl = "";
          }, 2000);
        }
      } else {
        alert(`Download failed: ${result.error || "Unknown error"}`);
        downloadProgress = "";
      }
    } catch (error) {
      console.error("Download error:", error);
      alert(`Download failed: ${error}`);
      downloadProgress = "";
    } finally {
      isDownloading = false;
    }
  }

  function loadCurrentTrack() {
    if (!currentPlaylist || currentPlaylist.items.length === 0) return;
    
    if (audioElement) {
      audioElement.pause();
      audioElement = null;
    }

    const track = currentPlaylist.items[currentTrackIndex];
    if (track && track.path) {
      // In Tauri, we need to use a special protocol or load from filesystem
      // For now, we'll use the invoke command to get the audio data
      audioElement = new Audio();
      
      // Use Tauri's protocol handler or file path
      // This is a simplified version - you may need to adjust based on Tauri's file handling
      invoke<string>("get_audio_path", { path: track.path }).then((audioPath) => {
        if (audioElement) {
          audioElement.src = audioPath;
          audioElement.volume = volume;
          audioElement.onended = playNext;
          if (isPlaying) {
            audioElement.play();
          }
        }
      }).catch((error) => {
        console.error("Failed to load audio:", error);
      });
    }
  }

  function togglePlayPause() {
    if (!currentPlaylist || currentPlaylist.items.length === 0) return;
    
    if (!audioElement) {
      loadCurrentTrack();
    }
    
    if (audioElement) {
      if (isPlaying) {
        audioElement.pause();
      } else {
        audioElement.play();
      }
      isPlaying = !isPlaying;
    }
  }

  function playNext() {
    if (!currentPlaylist) return;
    
    currentTrackIndex = (currentTrackIndex + 1) % currentPlaylist.items.length;
    loadCurrentTrack();
    if (isPlaying && audioElement) {
      audioElement.play();
    }
  }

  function playPrevious() {
    if (!currentPlaylist) return;
    
    currentTrackIndex = currentTrackIndex === 0 
      ? currentPlaylist.items.length - 1 
      : currentTrackIndex - 1;
    loadCurrentTrack();
    if (isPlaying && audioElement) {
      audioElement.play();
    }
  }

  function selectTrack(index: number) {
    currentTrackIndex = index;
    loadCurrentTrack();
    if (isPlaying && audioElement) {
      audioElement.play();
    }
  }

  function removeTrack(index: number) {
    if (currentPlaylist) {
      currentPlaylist.items.splice(index, 1);
      if (currentTrackIndex >= currentPlaylist.items.length) {
        currentTrackIndex = Math.max(0, currentPlaylist.items.length - 1);
      }
      savePlaylist(currentPlaylist);
      loadCurrentTrack();
    }
  }

  function handleVolumeChange(e: Event) {
    const target = e.target as HTMLInputElement;
    volume = parseFloat(target.value);
    if (audioElement) {
      audioElement.volume = volume;
    }
  }
</script>

<div class="music-player">
  <div class="player-header">🎵 Music Player</div>
  
  <div class="download-section">
    <input
      type="text"
      class="youtube-input"
      placeholder="Enter YouTube URL..."
      bind:value={youtubeUrl}
      disabled={isDownloading}
    />
    <button
      class="download-btn"
      on:click={downloadFromYouTube}
      disabled={isDownloading || !youtubeUrl.trim()}
    >
      {isDownloading ? "⏳ Downloading..." : "⬇ Download"}
    </button>
    {#if downloadProgress}
      <div class="download-progress">{downloadProgress}</div>
    {/if}
  </div>

  {#if currentPlaylist && currentPlaylist.items.length > 0}
    <div class="playlist-section">
      <div class="playlist-header">
        <span>{currentPlaylist.name}</span>
        <span class="track-count">{currentPlaylist.items.length} tracks</span>
      </div>
      
      <div class="player-controls">
        <button class="control-btn" on:click={playPrevious} title="Previous">⏮</button>
        <button class="control-btn play-btn" on:click={togglePlayPause} title={isPlaying ? "Pause" : "Play"}>
          {isPlaying ? "⏸" : "▶"}
        </button>
        <button class="control-btn" on:click={playNext} title="Next">⏭</button>
      </div>

      <div class="volume-control">
        <span>🔊</span>
        <input
          type="range"
          min="0"
          max="1"
          step="0.01"
          bind:value={volume}
          on:input={handleVolumeChange}
        />
        <span>{Math.round(volume * 100)}%</span>
      </div>

      <div class="playlist">
        {#each currentPlaylist.items as item, index}
          <div
            class="playlist-item"
            class:active={index === currentTrackIndex}
            on:click={() => selectTrack(index)}
          >
            <span class="track-title">{item.title}</span>
            <button
              class="remove-btn"
              on:click|stopPropagation={() => removeTrack(index)}
              title="Remove"
            >
              ✕
            </button>
          </div>
        {/each}
      </div>
    </div>
  {:else}
    <div class="empty-playlist">
      <p>No tracks yet. Download some music from YouTube!</p>
    </div>
  {/if}
</div>

<style>
  .music-player {
    position: absolute;
    top: 50px;
    right: 0;
    width: 300px;
    max-height: 350px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: 4px solid #333;
    border-radius: 8px;
    padding: 15px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
    overflow-y: auto;
    z-index: 50;
  }

  .player-header {
    font-size: 16px;
    font-weight: bold;
    color: #fff;
    text-shadow: 2px 2px 0 #333;
    margin-bottom: 15px;
    text-align: center;
  }

  .download-section {
    margin-bottom: 15px;
  }

  .youtube-input {
    width: 100%;
    padding: 8px;
    border: 3px solid #333;
    border-radius: 4px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    margin-bottom: 8px;
    background: #fff;
  }

  .download-btn {
    width: 100%;
    padding: 10px;
    border: 3px solid #333;
    border-radius: 4px;
    background: #4ade80;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
    font-family: 'Courier New', monospace;
    font-size: 12px;
    transition: all 0.2s;
    box-shadow: 0 3px 0 rgba(0, 0, 0, 0.2);
  }

  .download-btn:hover:not(:disabled) {
    background: #22c55e;
    transform: translateY(1px);
  }

  .download-btn:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }

  .download-progress {
    font-size: 11px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-top: 5px;
    text-align: center;
  }

  .playlist-section {
    margin-top: 15px;
  }

  .playlist-header {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    font-weight: bold;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-bottom: 10px;
  }

  .track-count {
    font-size: 11px;
  }

  .player-controls {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 10px;
  }

  .control-btn {
    width: 36px;
    height: 36px;
    border: 3px solid #333;
    border-radius: 6px;
    background: #fff;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    box-shadow: 0 3px 0 rgba(0, 0, 0, 0.2);
  }

  .control-btn:hover {
    background: #f0f0f0;
    transform: translateY(1px);
  }

  .play-btn {
    width: 44px;
    height: 44px;
    font-size: 18px;
    background: #4ade80;
  }

  .play-btn:hover {
    background: #22c55e;
  }

  .volume-control {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 10px;
    font-size: 12px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
  }

  .volume-control input[type="range"] {
    flex: 1;
  }

  .playlist {
    max-height: 150px;
    overflow-y: auto;
  }

  .playlist-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px;
    margin-bottom: 5px;
    background: rgba(255, 255, 255, 0.1);
    border: 2px solid #333;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.2s;
  }

  .playlist-item:hover {
    background: rgba(255, 255, 255, 0.2);
  }

  .playlist-item.active {
    background: rgba(74, 222, 128, 0.3);
    border-color: #4ade80;
  }

  .track-title {
    font-size: 11px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .remove-btn {
    width: 20px;
    height: 20px;
    border: none;
    background: transparent;
    color: #fff;
    font-size: 14px;
    cursor: pointer;
    padding: 0;
    margin-left: 8px;
  }

  .remove-btn:hover {
    color: #f5576c;
    transform: scale(1.2);
  }

  .empty-playlist {
    text-align: center;
    padding: 20px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    font-size: 12px;
  }
</style>


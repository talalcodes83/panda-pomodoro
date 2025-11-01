<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { invoke } from "@tauri-apps/api/tauri";
  import { readTextFile, writeTextFile, readBinaryFile } from "@tauri-apps/api/fs";
  import { open } from "@tauri-apps/api/dialog";
  import { convertFileSrc } from "@tauri-apps/api/tauri";

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
  let currentTrackTitle = "No track";
  let isPlaying = false;
  let isDownloading = false;
  let downloadProgress = "";
  let youtubeUrl = "";
  let audioElement: HTMLAudioElement | null = null;
  let volume = 0.5;
  let currentTime = 0;
  let duration = 0;
  let progressInterval: number | null = null;
  let currentBlobUrl: string | null = null;
  let currentBlob: Blob | null = null; // Keep blob reference alive to prevent garbage collection
  let currentTrackPath: string | null = null;
  let isPlayingPending = false; // Prevent spam clicking play button
  let isTrackLoading = false; // Prevent concurrent track loads
  let loadingAbortController: AbortController | null = null; // Cancel ongoing loads
  let shouldAutoPlayAfterLoad = false; // Flag to auto-play after load (for track selection)
  
  // Blob URL cache for instant switching (preload tracks in background)
  let blobCache: Map<string, { blobUrl: string; blob: Blob }> = new Map();
  
  // Allow parent to control visibility without destroying component
  export let visible = true;

  onMount(async () => {
    await loadPlaylists();
    if (playlists.length > 0) {
      currentPlaylist = playlists[0];
      updateCurrentTrackTitle();
      // Preload all tracks in background for instant switching
      preloadAllTracks();
    }
    
    // Restore playback state if audio was playing before
    // Note: audioElement persists across component visibility changes
  });
  
  // Preload a single track in background
  async function preloadTrack(track: PlaylistItem) {
    if (!track.path || blobCache.has(track.path)) return;
    
    try {
      const fileData = await readBinaryFile(track.path);
      if (fileData.length === 0) return;
      
      const ext = track.path.toLowerCase().split('.').pop();
      const mimeType = ext === 'mp4' ? 'video/mp4' 
        : ext === 'm4a' ? 'audio/mp4'
        : ext === 'webm' ? 'audio/webm'
        : ext === 'opus' ? 'audio/opus'
        : ext === 'mp3' ? 'audio/mpeg'
        : undefined;
      
      const blob = mimeType ? new Blob([fileData], { type: mimeType }) : new Blob([fileData]);
      const blobUrl = URL.createObjectURL(blob);
      
      blobCache.set(track.path, { blobUrl, blob });
    } catch (error) {
      // Ignore - will load on-demand
    }
  }
  
  // Preload all tracks in background (create blob URLs for instant switching)
  async function preloadAllTracks() {
    if (!currentPlaylist?.items?.length) return;
    
    // Preload tracks in background (non-blocking, don't await)
    currentPlaylist.items.forEach((track) => {
      if (track.path) {
        preloadTrack(track);
      }
    });
  }

  onDestroy(() => {
    // Don't stop audio when component is destroyed - keep it playing in background
    // Only clear the progress interval
    if (progressInterval) {
      clearInterval(progressInterval);
      progressInterval = null;
    }
    // Don't pause or null audioElement - let it keep playing
    // Don't revoke blob URL - let it persist
  });

  async function loadPlaylists() {
    try {
      const appDataDir = await invoke<string>("get_app_data_dir");
      const playlistsDir = `${appDataDir}/playlists`;
      
      try {
        // List directory - using invoke for file operations
        const entries = await invoke<string[]>("list_files", { dir: playlistsDir });
        playlists = [];
        
        for (const filename of entries) {
          if (filename.endsWith(".json")) {
            const content = await readTextFile(`${playlistsDir}/${filename}`, { encoding: "utf-8" });
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
      
      // Preload all tracks in current playlist for instant switching
      if (currentPlaylist && currentPlaylist.items.length > 0) {
        preloadAllTracks();
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
        // Create directory if needed - using invoke
        await invoke("ensure_dir", { path: playlistsDir });
      } catch (error) {
        // Directory might already exist
      }
      
      const filename = playlist.name.toLowerCase().replace(/\s+/g, "-") + ".json";
      await writeTextFile(
        `${playlistsDir}/${filename}`,
        JSON.stringify(playlist, null, 2),
        { encoding: "utf-8" }
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
      // Use proper path joining for Windows (replace / with \ if on Windows)
      const musicDir = appDataDir.includes('\\') 
        ? `${appDataDir}\\music`
        : `${appDataDir}/music`;
      
      try {
        await invoke("ensure_dir", { path: musicDir });
      } catch (error) {
        // Directory might already exist
      }

      downloadProgress = "Downloading audio...";
      
      // Clean the URL before sending
      const cleanUrl = cleanYouTubeUrl(youtubeUrl);
      console.log("Starting download with URL:", cleanUrl);
      console.log("Original URL was:", youtubeUrl);
      console.log("Output directory:", musicDir);
      
      const result = await invoke<{ success: boolean; title?: string; path?: string; error?: string }>("download_youtube_audio", {
        url: cleanUrl,
        outputDir: musicDir,
      });

      console.log("Download result:", result);

      if (result.success && result.title && result.path) {
        // Verify the file actually exists
        console.log("Downloaded file path:", result.path);
        
        // Add to current playlist
        if (currentPlaylist) {
          // Check for duplicates by path or URL
          const existingByPath = currentPlaylist.items.find(item => item.path === result.path);
          const existingByUrl = currentPlaylist.items.find(item => {
            // Extract video ID from both URLs for comparison
            const cleanExistingUrl = cleanYouTubeUrl(item.url);
            const cleanNewUrl = cleanYouTubeUrl(youtubeUrl);
            return cleanExistingUrl === cleanNewUrl;
          });
          
          if (existingByPath || existingByUrl) {
            console.log("Track already exists in playlist, skipping duplicate");
            downloadProgress = `Already in playlist: ${result.title}`;
            setTimeout(() => {
              downloadProgress = "";
              youtubeUrl = "";
            }, 2000);
            return;
          }
          
          const newItem: PlaylistItem = {
            id: Date.now().toString(),
            title: result.title,
            url: youtubeUrl,
            path: result.path,
          };
          
          // Create a new array to trigger reactivity
          const updatedItems = [...currentPlaylist.items, newItem];
          
          // Update the playlist reference in the playlists array too
          const playlistIndex = playlists.findIndex(p => p.name === currentPlaylist.name);
          if (playlistIndex >= 0) {
            playlists[playlistIndex] = {
              ...currentPlaylist,
              items: updatedItems
            };
          }
          
          currentPlaylist = {
            ...currentPlaylist,
            items: updatedItems
          };
          
          await savePlaylist(currentPlaylist);
          
          
          downloadProgress = `Downloaded: ${result.title}`;
          
          setTimeout(() => {
            downloadProgress = "";
            youtubeUrl = "";
          }, 2000);
        } else {
          console.error("No playlist available");
          alert("No playlist available. Please create a playlist first.");
          downloadProgress = "";
        }
      } else {
        const errorMsg = result.error || "Unknown error";
        console.error("Download failed:", errorMsg);
        alert(`Download failed: ${errorMsg}`);
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

  // Clean up old audio element and resources - SYNCHRONOUS cleanup
  function stopAndCleanupAudioElement(element: HTMLAudioElement | null, blobUrl: string | null, blob: Blob | null) {
    if (!element) return;
    
    // CRITICAL: Stop playback IMMEDIATELY and synchronously
    try {
      element.pause();
      element.currentTime = 0;
    } catch (e) {
      // Ignore
    }
    
    // Remove ALL event listeners to prevent callbacks
    try {
      element.onerror = null;
      element.onended = null;
      element.ontimeupdate = null;
      element.onloadstart = null;
      element.onprogress = null;
      element.onloadedmetadata = null;
      element.oncanplay = null;
      element.oncanplaythrough = null;
      element.onplay = null;
      element.onpause = null;
      element.onload = null;
      element.onabort = null;
    } catch (e) {
      // Ignore
    }
    
    // Clear src to stop loading/playing
    try {
      element.src = '';
      element.load(); // Reset the element
    } catch (e) {
      // Ignore
    }
    
    // DON'T revoke blob URL if it's in cache (might be reused!)
    // Only revoke if it's not cached (old/temporary blob)
    if (blobUrl && blobUrl.startsWith('blob:')) {
      let isCached = false;
      blobCache.forEach((cached) => {
        if (cached.blobUrl === blobUrl) {
          isCached = true;
        }
      });
      
      // Only revoke if NOT in cache (it's a temporary blob)
      if (!isCached) {
        setTimeout(() => {
          try {
            URL.revokeObjectURL(blobUrl);
          } catch (e) {
            // Ignore
          }
        }, 2000);
      }
    }
  }

  async function loadCurrentTrack(autoPlay = false) {
    // Abort previous load instantly (no delay!)
    if (isTrackLoading && loadingAbortController) {
      loadingAbortController.abort();
    }
    
    // Set loading lock and auto-play flag
    isTrackLoading = true;
    shouldAutoPlayAfterLoad = autoPlay;
    loadingAbortController = new AbortController();
    const signal = loadingAbortController.signal;
    
    // Store old references for background cleanup (don't wait!)
    const oldAudioElement = audioElement;
    const oldBlobUrl = currentBlobUrl;
    const oldBlob = currentBlob;
    
    // Do cleanup in background - don't wait!
    if (oldAudioElement) {
      // Stop playback instantly (synchronous)
      try {
        oldAudioElement.pause();
        oldAudioElement.currentTime = 0;
      } catch (e) {
        // Ignore
      }
      
      // Clear src to stop loading
      try {
        oldAudioElement.src = '';
        oldAudioElement.load();
      } catch (e) {
        // Ignore
      }
      
      // Cleanup in background - don't await!
      setTimeout(() => {
        stopAndCleanupAudioElement(oldAudioElement, oldBlobUrl, oldBlob);
      }, 0);
    }
    
    // Clear references immediately
    const previousTrackPath = currentTrackPath;
    audioElement = null;
    currentBlobUrl = null;
    currentBlob = null;
    isPlaying = false;
    currentTime = 0;
    duration = 0;
    currentTrackPath = null;
    
    // Clear progress interval
    if (progressInterval) {
      clearInterval(progressInterval);
      progressInterval = null;
    }
    
    try {
      if (!currentPlaylist?.items?.length) return;
      if (currentTrackIndex >= currentPlaylist.items.length) {
        currentTrackIndex = 0;
      }

      const track = currentPlaylist.items[currentTrackIndex];
      if (!track?.path) return;
      
      if (signal.aborted) return;
      
      currentTrackPath = track.path;
      
      // Declare blob and blobUrl
      let blob: Blob | null = null;
      let blobUrl: string | null = null;
      let audioUrl: string;
      
      const oldBlobUrlForCleanup = oldBlobUrl;
      
      // Check if this track is already loaded (avoid reloading!)
      if (previousTrackPath === track.path && oldAudioElement && oldAudioElement.readyState >= 2) {
        audioElement = oldAudioElement;
        currentBlobUrl = oldBlobUrl;
        currentBlob = oldBlob;
        currentTrackPath = track.path;
        if (progressInterval) clearInterval(progressInterval);
        progressInterval = window.setInterval(() => {
          if (audioElement) {
            currentTime = audioElement.currentTime || 0;
            duration = audioElement.duration || 0;
          }
        }, 100);
        currentPlaylist = { ...currentPlaylist! };
        updateCurrentTrackTitle();
        return;
      }
      
      // Capture auto-play flag in closure
      const shouldAutoPlay = shouldAutoPlayAfterLoad;
      const wasPlayingBefore = isPlaying;
      
      // Create audio element immediately (don't wait for file!)
      audioElement = new Audio();
      audioElement.preload = "auto";
      audioElement.volume = volume;
      audioElement.muted = false;
      audioElement.onerror = () => { currentTrackPath = null; };
      
      // INSTANT SWITCHING: Check blob cache first (preloaded tracks = 0ms load time!)
      const cached = blobCache.get(track.path);
      if (cached) {
        // Track is preloaded - use cached blob URL instantly!
        currentBlobUrl = cached.blobUrl;
        currentBlob = cached.blob;
        
        if (audioElement && !signal.aborted) {
          audioElement.src = cached.blobUrl;
          audioElement.load();
          
          // Auto-play if track was explicitly selected or was playing
          if (shouldAutoPlay) {
            audioElement.play().then(() => {
              isPlaying = true;
            }).catch(() => {
              setTimeout(() => {
                if (audioElement && audioElement.src) {
                  audioElement.play().then(() => {
                    isPlaying = true;
                  }).catch(() => {});
                }
              }, 100);
            });
          } else if (wasPlayingBefore) {
            audioElement.play().then(() => {
              isPlaying = true;
            }).catch(() => {});
          }
        }
        return; // Track loaded instantly from cache!
      }
      
      // Track not cached - read file and create blob URL (slow - only for uncached tracks)
      readBinaryFile(track.path).then((fileData) => {
        if (signal.aborted) return;
        if (fileData.length === 0) return;
        
        // Determine MIME type instantly
        const ext = track.path.toLowerCase().split('.').pop();
        const mimeType = ext === 'mp4' ? 'video/mp4' 
          : ext === 'm4a' ? 'audio/mp4'
          : ext === 'webm' ? 'audio/webm'
          : ext === 'opus' ? 'audio/opus'
          : ext === 'mp3' ? 'audio/mpeg'
          : undefined;
        
        // Create blob and URL
        const blob = mimeType ? new Blob([fileData], { type: mimeType }) : new Blob([fileData]);
        const blobUrl = URL.createObjectURL(blob);
        
        if (signal.aborted) {
          URL.revokeObjectURL(blobUrl);
          return;
        }
        
        // Cache it for next time (instant switching)
        blobCache.set(track.path, { blobUrl, blob });
        
        // Set blob URL immediately
        currentBlobUrl = blobUrl;
        currentBlob = blob;
        
        if (audioElement && !signal.aborted) {
          audioElement.src = blobUrl;
          audioElement.load();
          
          // Auto-play if track was explicitly selected or was playing
          if (shouldAutoPlay) {
            audioElement.play().then(() => {
              isPlaying = true;
            }).catch(() => {
              setTimeout(() => {
                if (audioElement && audioElement.src) {
                  audioElement.play().then(() => {
                    isPlaying = true;
                  }).catch(() => {});
                }
              }, 100);
            });
          } else if (wasPlayingBefore) {
            audioElement.play().then(() => {
              isPlaying = true;
            }).catch(() => {});
          }
        }
      }).catch((error) => {
        console.error("Failed to read file:", error);
      });
      
      // Set up event handlers immediately
      audioElement.onended = () => {
        currentTime = 0;
        duration = 0;
        currentTrackPath = null;
        setTimeout(() => playNext(), 0);
      };
      
      audioElement.onloadedmetadata = () => {
        if (audioElement) duration = audioElement.duration || 0;
      };
      
      audioElement.ontimeupdate = () => {
        if (audioElement) {
          currentTime = audioElement.currentTime || 0;
          duration = audioElement.duration || 0;
        }
      };
      
      // Start progress tracking
      if (progressInterval) clearInterval(progressInterval);
      progressInterval = window.setInterval(() => {
        if (audioElement) {
          currentTime = audioElement.currentTime || 0;
          duration = audioElement.duration || 0;
        }
      }, 100);
      
      // Update UI immediately
      currentPlaylist = { ...currentPlaylist! };
      updateCurrentTrackTitle();
    } catch (error) {
      console.error("Failed to load track:", error);
    } finally {
      // Always release loading lock and reset auto-play flag
      isTrackLoading = false;
      shouldAutoPlayAfterLoad = false;
      loadingAbortController = null;
    }
  }

  async function togglePlayPause() {
    // Prevent spam clicking
    if (isPlayingPending) {
      console.log("Play/Pause already in progress, ignoring");
      return;
    }
    
    if (!currentPlaylist || currentPlaylist.items.length === 0) {
      console.log("No playlist available");
      return;
    }
    
    // Check if audio is currently playing
    if (audioElement && !audioElement.paused) {
      // Pause it
      console.log("Pausing audio");
      audioElement.pause();
      isPlaying = false;
      if (progressInterval) {
        clearInterval(progressInterval);
        progressInterval = null;
      }
      return;
    }
    
    // Need to play - load track if needed
    if (!audioElement || !audioElement.src) {
      console.log("No audio element or src, loading track...");
      isPlayingPending = true;
      try {
        await loadCurrentTrack();
    if (!audioElement) {
          console.error("Failed to create audio element");
          isPlayingPending = false;
          return;
        }
      } catch (err) {
        console.error("Failed to load track:", err);
        isPlayingPending = false;
        return;
      }
    }
    
    if (!audioElement) {
      console.error("No audio element available");
      return;
    }
    
    // Play audio
    console.log("Playing audio");
    isPlayingPending = true;
    try {
      // Ensure progress tracking is running
      if (!progressInterval) {
        progressInterval = window.setInterval(() => {
          if (audioElement) {
            currentTime = audioElement.currentTime || 0;
            duration = audioElement.duration || 0;
          }
        }, 100);
      }
      
      // INSTANT PLAYBACK: Play immediately - browser will buffer
      // No waiting for readyState - just play and let browser handle buffering
      try {
        await audioElement.play();
        isPlaying = true;
        console.log("✓ Audio playing instantly");
      } catch (playError) {
        // If play fails, try once more after a tiny delay
        console.log("Initial play failed, retrying...");
        try {
          await new Promise(resolve => setTimeout(resolve, 50));
          await audioElement.play();
          isPlaying = true;
          console.log("✓ Audio playing after retry");
        } catch (retryError) {
          console.error("Play failed after retry:", retryError);
          isPlaying = false;
          throw retryError;
        }
      }
    } catch (err) {
      console.error("Failed to play audio:", err);
      isPlaying = false;
    } finally {
      isPlayingPending = false;
    }
  }

  function formatTime(seconds: number): string {
    if (!seconds || isNaN(seconds)) return "0:00";
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  }

  function handleProgressClick(e: MouseEvent) {
    if (!audioElement || !duration) return;
    const progressBar = e.currentTarget as HTMLElement;
    const rect = progressBar.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const percent = x / rect.width;
    const newTime = percent * duration;
    audioElement.currentTime = newTime;
    currentTime = newTime;
  }

  function updateCurrentTrackTitle() {
    if (!currentPlaylist || !currentPlaylist.items || currentPlaylist.items.length === 0) {
      currentTrackTitle = "No track";
      return;
    }
    if (currentTrackIndex < 0 || currentTrackIndex >= currentPlaylist.items.length) {
      currentTrackTitle = "No track";
      return;
    }
    const track = currentPlaylist.items[currentTrackIndex];
    if (!track) {
      console.error("No track at index:", currentTrackIndex);
      currentTrackTitle = "No track";
      return;
    }
    currentTrackTitle = track.title || "Unknown track";
    console.log("Updated currentTrackTitle to:", currentTrackTitle);
  }

  function getCurrentTrackTitle(): string {
    return currentTrackTitle;
  }

  async function playNext() {
    // Prevent spam clicking
    if (isTrackLoading) {
      console.log("Already loading track, ignoring playNext");
      return;
    }
    
    if (!currentPlaylist) {
      console.error("Cannot play next: currentPlaylist is null");
      await loadPlaylists();
      if (playlists.length > 0) {
        currentPlaylist = playlists[0];
      } else {
        console.error("No playlists available");
        return;
      }
    }
    
    if (!currentPlaylist.items || currentPlaylist.items.length === 0) {
      console.error("Cannot play next: playlist has no items");
      return;
    }
    
    console.log("=== PLAYING NEXT TRACK ===");
    
    // CRITICAL: Stop current audio IMMEDIATELY
    const oldElement = audioElement;
    const oldBlobUrl = currentBlobUrl;
    const oldBlob = currentBlob;
    const wasPlaying = isPlaying && audioElement && !audioElement.paused;
    
    if (oldElement) {
      // Stop instantly (synchronous)
      try {
        oldElement.pause();
        oldElement.currentTime = 0;
        oldElement.src = '';
        oldElement.load();
      } catch (e) {}
      // Cleanup in background - don't await!
      setTimeout(() => stopAndCleanupAudioElement(oldElement, oldBlobUrl, oldBlob), 0);
    }
    
    // Clear state instantly
    audioElement = null;
    currentBlobUrl = null;
    currentBlob = null;
    isPlaying = false;
    currentTime = 0;
    duration = 0;
    currentTrackPath = null;
    if (progressInterval) {
      clearInterval(progressInterval);
      progressInterval = null;
    }
    
    // Move to next track
    currentTrackIndex = (currentTrackIndex + 1) % currentPlaylist.items.length;
    updateCurrentTrackTitle();
    
    // Load and play immediately
    await loadCurrentTrack();
    if (wasPlaying && audioElement) {
      try {
        await audioElement.play();
        isPlaying = true;
      } catch (err) {
        isPlaying = false;
      }
    }
  }

  async function playPrevious() {
    if (isTrackLoading) return;
    if (!currentPlaylist?.items?.length) return;
    
    // Stop current audio instantly (background cleanup)
    const oldElement = audioElement;
    const oldBlobUrl = currentBlobUrl;
    const oldBlob = currentBlob;
    const wasPlaying = isPlaying && audioElement && !audioElement.paused;
    
    if (oldElement) {
      try {
        oldElement.pause();
        oldElement.currentTime = 0;
        oldElement.src = '';
        oldElement.load();
      } catch (e) {}
      setTimeout(() => stopAndCleanupAudioElement(oldElement, oldBlobUrl, oldBlob), 0);
    }
    
    // Clear state instantly
    audioElement = null;
    currentBlobUrl = null;
    currentBlob = null;
    isPlaying = false;
    currentTime = 0;
    duration = 0;
    currentTrackPath = null;
    if (progressInterval) {
      clearInterval(progressInterval);
      progressInterval = null;
    }
    
    // Move to previous track
    currentTrackIndex = currentTrackIndex === 0 
      ? currentPlaylist.items.length - 1 
      : currentTrackIndex - 1;
    updateCurrentTrackTitle();
    
    // Load and play immediately
    await loadCurrentTrack();
    if (wasPlaying && audioElement) {
      try {
        await audioElement.play();
        isPlaying = true;
      } catch (err) {
        isPlaying = false;
      }
    }
  }

  async function selectTrack(index: number) {
    if (isTrackLoading) return;
    if (!currentPlaylist?.items || index < 0 || index >= currentPlaylist.items.length) return;
    
    // Stop current audio instantly (background cleanup)
    const oldElement = audioElement;
    const oldBlobUrl = currentBlobUrl;
    const oldBlob = currentBlob;
    
    if (oldElement) {
      try {
        oldElement.pause();
        oldElement.currentTime = 0;
        oldElement.src = '';
        oldElement.load();
      } catch (e) {}
      setTimeout(() => stopAndCleanupAudioElement(oldElement, oldBlobUrl, oldBlob), 0);
    }
    
    // Clear state instantly
    audioElement = null;
    currentBlobUrl = null;
    currentBlob = null;
    isPlaying = false;
    currentTime = 0;
    duration = 0;
    currentTrackPath = null;
    if (progressInterval) {
      clearInterval(progressInterval);
      progressInterval = null;
    }
    
    // Set new track and load immediately (with auto-play flag)
    currentTrackIndex = index;
    updateCurrentTrackTitle();
    
    // Load track with auto-play flag set
    await loadCurrentTrack(true); // true = auto-play after load
    
    // Also try to play immediately if blob URL is already ready
    // This handles the case where file reading completes before await resolves
    if (audioElement && audioElement.src && audioElement.readyState >= 1) {
      try {
        await audioElement.play();
        isPlaying = true;
      } catch (err) {
        // If play fails, the blob will auto-play when ready via the Promise callback
        // Don't set isPlaying = false here - let the Promise callback handle it
      }
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

  function handlePaste(e: ClipboardEvent) {
    // Prevent default paste behavior that might crash
    e.stopPropagation();
    if (e.clipboardData) {
      const pasteData = e.clipboardData.getData('text');
      if (pasteData) {
        // Clean the URL - take only the first line, remove duplicates, and trim whitespace
        let cleaned = pasteData.split('\n')[0].trim();
        // If URL appears twice (duplicated), take only the first occurrence
        const youtubeRegex = /https?:\/\/.*?youtube\.com\/watch\?v=[^\s&]+/gi;
        const matches = cleaned.match(youtubeRegex);
        if (matches && matches.length > 0) {
          cleaned = matches[0];
        }
        youtubeUrl = cleaned;
      }
    }
  }
  
  // Clean URL before sending to download - extract video ID and rebuild clean URL
  function cleanYouTubeUrl(url: string): string {
    if (!url) return '';
    
    // Extract video ID from URL (handles various formats)
    let videoId = '';
    
    // Try pattern: v=VIDEO_ID
    const videoIdMatch = url.match(/[?&]v=([a-zA-Z0-9_-]{11})/);
    if (videoIdMatch && videoIdMatch[1]) {
      videoId = videoIdMatch[1];
    } else {
      // Try shortened format: youtu.be/VIDEO_ID
      const shortMatch = url.match(/youtu\.be\/([a-zA-Z0-9_-]{11})/);
      if (shortMatch && shortMatch[1]) {
        videoId = shortMatch[1];
      } else {
        // Fallback: take first 11 character alphanumeric string after v=
        const fallbackMatch = url.match(/v=([a-zA-Z0-9_-]+)/);
        if (fallbackMatch && fallbackMatch[1]) {
          videoId = fallbackMatch[1].substring(0, 11);
        }
      }
    }
    
    if (videoId) {
      return `https://www.youtube.com/watch?v=${videoId}`;
    }
    
    // Last resort: try to extract first valid YouTube URL
    const youtubeRegex = /https?:\/\/[^\s]*youtube\.com\/watch\?v=[a-zA-Z0-9_-]+/i;
    const matches = url.match(youtubeRegex);
    if (matches && matches.length > 0) {
      const firstUrl = matches[0];
      const vidMatch = firstUrl.match(/v=([a-zA-Z0-9_-]{11})/);
      if (vidMatch && vidMatch[1]) {
        return `https://www.youtube.com/watch?v=${vidMatch[1]}`;
      }
      return firstUrl.split('&')[0]; // Take URL up to first &
    }
    
    return url.trim();
  }

  function handleKeyDown(e: KeyboardEvent) {
    // Prevent Enter from submitting if it somehow triggers a crash
    if (e.key === 'Enter' && !isDownloading) {
      e.preventDefault();
      downloadFromYouTube();
    }
  }
</script>

<div class="music-player" class:hidden={!visible}>
  <div class="player-header">🎵 Music Player</div>
  
  <div class="download-section">
    <div class="download-input-wrapper">
    <input
      type="text"
      class="youtube-input"
      placeholder="Enter YouTube URL..."
      bind:value={youtubeUrl}
      disabled={isDownloading}
        on:paste={handlePaste}
        on:keydown={handleKeyDown}
    />
    <button
        class="download-btn-square"
      on:click={downloadFromYouTube}
      disabled={isDownloading || !youtubeUrl.trim()}
        title={isDownloading ? "Downloading..." : "Download"}
    >
        {isDownloading ? "⏳" : "⬇"}
    </button>
    </div>
    {#if downloadProgress}
      <div class="download-progress">{downloadProgress}</div>
    {/if}
  </div>

    <div class="playlist-section">
      <div class="playlist-header">
      <span>{currentPlaylist ? currentPlaylist.name : "Study Music"}</span>
      <span class="track-count">{currentPlaylist?.items?.length || 0} tracks</span>
    </div>
    
    <div class="playlist">
      {#if currentPlaylist && currentPlaylist.items && currentPlaylist.items.length > 0}
        {#each currentPlaylist.items as item, index}
          <div
            class="playlist-item"
            class:active={index === currentTrackIndex}
            role="button"
            tabindex="0"
            on:click={() => selectTrack(index)}
            on:keydown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                selectTrack(index);
              }
            }}
            title="Click to play track"
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
      {:else}
        <div class="empty-playlist">
          <p>📀 Your tracks will appear here</p>
        </div>
      {/if}
    </div>

    {#if currentPlaylist && currentPlaylist.items && currentPlaylist.items.length > 0}
      <div class="current-track">
        <div class="track-name">{currentTrackTitle}</div>
        <div class="progress-container">
          <div 
            class="progress-bar" 
            role="slider"
            tabindex="0"
            aria-valuemin="0"
            aria-valuemax={duration || 0}
            aria-valuenow={currentTime || 0}
            aria-label="Audio progress"
            on:click={handleProgressClick}
            on:keydown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                handleProgressClick(e);
              }
            }}
          >
            <div class="progress-fill" style="width: {duration > 0 ? (currentTime / duration * 100) : 0}%"></div>
          </div>
          <div class="time-info">
            <span class="current-time">{formatTime(currentTime)}</span>
            <span class="total-time">{formatTime(duration)}</span>
          </div>
        </div>
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
  {:else}
      <div class="empty-state">
        <p>No tracks loaded. Download music to get started!</p>
      </div>
      
      <div class="player-controls">
        <button class="control-btn" disabled title="Previous">⏮</button>
        <button class="control-btn play-btn" disabled title="Play">▶</button>
        <button class="control-btn" disabled title="Next">⏭</button>
    </div>
  {/if}
  </div>
</div>

<style>
  .music-player {
    position: absolute;
    top: 50px;
    right: 0;
    width: 300px;
    height: 500px;
    max-height: 500px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border: 4px solid #333;
    border-radius: 8px;
    padding: 15px;
    box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
    overflow: hidden;
    display: flex;
    flex-direction: column;
    z-index: 50;
    -webkit-app-region: no-drag;
    transition: opacity 0.2s, visibility 0.2s;
  }

  .music-player.hidden {
    display: none;
  }

  .player-header {
    font-size: 16px;
    font-weight: bold;
    color: #fff;
    text-shadow: 2px 2px 0 #333;
    margin-bottom: 15px;
    text-align: center;
    flex-shrink: 0;
  }

  .download-section {
    margin-bottom: 15px;
    flex-shrink: 0;
  }

  .download-input-wrapper {
    display: flex;
    gap: 8px;
    align-items: stretch;
  }

  .youtube-input {
    flex: 1;
    padding: 8px;
    border: 3px solid #333;
    border-radius: 4px;
    font-size: 12px;
    font-family: 'Courier New', monospace;
    background: #fff;
    min-width: 0;
  }

  .download-btn-square {
    width: 40px;
    height: 40px;
    padding: 0;
    border: 3px solid #333;
    border-radius: 4px;
    background: #4ade80;
    color: #fff;
    font-weight: bold;
    cursor: pointer;
    font-family: 'Courier New', monospace;
    font-size: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    box-shadow: 0 3px 0 rgba(0, 0, 0, 0.2);
    flex-shrink: 0;
  }

  .download-btn-square:hover:not(:disabled) {
    background: #22c55e;
    transform: translateY(1px);
  }

  .download-btn-square:disabled {
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
    display: flex;
    flex-direction: column;
    flex: 1;
    min-height: 0;
    overflow: hidden;
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

  .current-track {
    margin-bottom: 15px;
    padding: 10px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    border: 2px solid rgba(255, 255, 255, 0.2);
    flex-shrink: 0;
  }

  .track-name {
    font-size: 13px;
    font-weight: bold;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-bottom: 8px;
    text-align: center;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .progress-container {
    width: 100%;
  }

  .progress-bar {
    width: 100%;
    height: 8px;
    background: rgba(255, 255, 255, 0.3);
    border-radius: 4px;
    cursor: pointer;
    position: relative;
    border: 2px solid #333;
    margin-bottom: 5px;
    overflow: hidden;
  }

  .progress-fill {
    height: 100%;
    background: linear-gradient(90deg, #4ade80 0%, #22c55e 100%);
    border-radius: 2px;
    transition: width 0.1s linear;
    box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.3);
  }

  .time-info {
    display: flex;
    justify-content: space-between;
    font-size: 10px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    margin-top: 3px;
  }

  .current-time, .total-time {
    font-family: 'Courier New', monospace;
  }

  .player-controls {
    display: flex;
    justify-content: center;
    gap: 10px;
    margin-bottom: 10px;
    flex-shrink: 0;
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
    flex-shrink: 0;
  }

  .volume-control input[type="range"] {
    flex: 1;
  }

  .playlist {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    min-height: 0;
    max-height: 350px;
    margin-bottom: 10px;
    border: 2px solid rgba(255, 255, 255, 0.2);
    border-radius: 6px;
    background: rgba(255, 255, 255, 0.05);
    padding: 5px;
  }
  
  .playlist::-webkit-scrollbar {
    width: 8px;
  }
  
  .playlist::-webkit-scrollbar-track {
    background: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
  }
  
  .playlist::-webkit-scrollbar-thumb {
    background: rgba(255, 255, 255, 0.3);
    border-radius: 4px;
  }
  
  .playlist::-webkit-scrollbar-thumb:hover {
    background: rgba(255, 255, 255, 0.5);
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

  .empty-state {
    padding: 20px;
    text-align: center;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    font-size: 12px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 6px;
    margin-bottom: 15px;
    border: 2px solid rgba(255, 255, 255, 0.2);
  }

  .empty-playlist {
    text-align: center;
    padding: 20px;
    color: #fff;
    text-shadow: 1px 1px 0 #333;
    font-size: 12px;
  }
</style>


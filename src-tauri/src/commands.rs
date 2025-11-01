use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use std::process::Command;
use tauri::AppHandle;

#[derive(Debug, Serialize, Deserialize)]
pub struct DownloadResult {
    pub success: bool,
    pub title: Option<String>,
    pub path: Option<String>,
    pub error: Option<String>,
}

#[tauri::command]
pub async fn get_app_data_dir(app: AppHandle) -> Result<String, String> {
    use tauri::api::path::app_data_dir;
    
    let config = app.config();
    let app_data = app_data_dir(&config)
        .ok_or("Failed to get app data directory")?;
    
    // Create the directory if it doesn't exist
    std::fs::create_dir_all(&app_data)
        .map_err(|e| format!("Failed to create app data directory: {}", e))?;
    
    let app_data_str = app_data.to_string_lossy().to_string();
    Ok(app_data_str)
}

#[tauri::command]
pub async fn download_youtube_audio(
    url: String,
    output_dir: String,
) -> Result<DownloadResult, String> {
    println!("[Download] Starting download for URL: {}", url);
    println!("[Download] Output directory: {}", output_dir);
    
    // Check if yt-dlp is available
    let yt_dlp_check = Command::new("yt-dlp")
        .arg("--version")
        .output();

    if yt_dlp_check.is_err() {
        println!("[Download] ERROR: yt-dlp not found!");
        return Ok(DownloadResult {
            success: false,
            title: None,
            path: None,
            error: Some(
                "yt-dlp not found. Please install yt-dlp first:\n\
                Windows: winget install yt-dlp\n\
                Mac: brew install yt-dlp\n\
                Linux: sudo apt install yt-dlp".to_string()
            ),
        });
    }
    
    println!("[Download] yt-dlp found, proceeding...");

    // Normalize the path - convert forward slashes to backslashes on Windows
    let normalized_output_dir = if cfg!(windows) {
        output_dir.replace('/', "\\")
    } else {
        output_dir.replace('\\', "/")
    };
    let output_path = PathBuf::from(&normalized_output_dir);
    
    println!("[Download] Normalized output path: {}", output_path.display());
    
    // Clean the URL - extract just the video ID and reconstruct a clean URL
    // This must be done BEFORE title extraction
    let clean_url = {
        // Try to extract video ID first
        if let Some(vid_pos) = url.find("v=") {
            let after_v = &url[vid_pos + 2..];
            if let Some(end_pos) = after_v.find(|c: char| c == '&' || c == ' ' || c == '\n' || c == '\r') {
                let video_id = &after_v[..end_pos];
                format!("https://www.youtube.com/watch?v={}", video_id)
            } else {
                let video_id = after_v.trim();
                format!("https://www.youtube.com/watch?v={}", video_id)
            }
        } else {
            // Fallback: take first valid YouTube URL
            url.trim().split('\n').next().unwrap_or(&url).trim().to_string()
        }
    };
    println!("[Download] Clean URL: {}", clean_url);
    
    // First, get the title using --print with the clean URL and Android client
    let title_output = Command::new("yt-dlp")
        .arg("--print")
        .arg("%(title)s")
        .arg("--no-playlist")
        .arg("--no-warnings")
        .arg("--extractor-args")
        .arg("youtube:player_client=android")
        .arg(&clean_url)
        .output();
    
    let title = if let Ok(title_result) = title_output {
        if title_result.status.success() {
            String::from_utf8_lossy(&title_result.stdout).trim().to_string()
        } else {
            println!("[Download] WARNING: Failed to get title, using default");
            "Unknown Title".to_string()
        }
    } else {
        println!("[Download] WARNING: Title command failed, using default");
        "Unknown Title".to_string()
    };
    
    println!("[Download] Video title: {}", title);
    
    let sanitized_title = sanitize_filename(&title);
    // Check for both .mp3 and .mp4 files (mp4 if ffmpeg not installed)
    let expected_filename_mp3 = format!("{}.mp3", sanitized_title);
    let expected_filename_mp4 = format!("{}.mp4", sanitized_title);
    let expected_path_mp3 = output_path.join(&expected_filename_mp3);
    let expected_path_mp4 = output_path.join(&expected_filename_mp4);
    
    println!("[Download] Expected file paths - MP3: {} | MP4: {}", 
        expected_path_mp3.display(), expected_path_mp4.display());
    
    // Use yt-dlp to download audio with Android client (most reliable)
    println!("[Download] Running yt-dlp download command...");
    let output = Command::new("yt-dlp")
        .arg("--extract-audio")
        .arg("--audio-format")
        .arg("mp3")
        .arg("--audio-quality")
        .arg("192K")
        .arg("-o")
        .arg(format!("{}/%(title)s.%(ext)s", normalized_output_dir))
        .arg("--no-playlist")
        .arg("--no-warnings")
        .arg("--extractor-args")
        .arg("youtube:player_client=android")
        .arg("--retries")
        .arg("3")
        .arg("--fragment-retries")
        .arg("3")
        .arg("--file-access-retries")
        .arg("3")
        .arg(clean_url)
        .output()
        .map_err(|e| format!("Failed to execute yt-dlp: {}", e))?;

    let stdout_msg = String::from_utf8_lossy(&output.stdout);
    println!("[Download] yt-dlp stdout: {}", stdout_msg);
    
    // Check if download actually succeeded even if exit code failed (often due to ffmpeg missing)
    let download_succeeded = stdout_msg.contains("100%") || stdout_msg.contains("Destination:");
    
    if !output.status.success() && !download_succeeded {
        let error_msg = String::from_utf8_lossy(&output.stderr);
        println!("[Download] ERROR: yt-dlp failed!");
        println!("[Download] stderr: {}", error_msg);
        
        // Provide helpful error message for different error types
        let user_error = if error_msg.contains("403") || error_msg.contains("Forbidden") {
            format!("YouTube is blocking the download (403 Forbidden). Try:\n1. Update yt-dlp: winget upgrade yt-dlp\n2. Wait a few minutes and try again\n3. Try a different video\n\nError: {}", error_msg)
        } else if error_msg.contains("Failed to extract") || error_msg.contains("player response") || error_msg.contains("yt-dlp -U") {
            format!("yt-dlp needs to be updated. Run this command in PowerShell:\n\nwinget upgrade yt-dlp\n\nOr if you installed it via pip:\n\npip install --upgrade yt-dlp\n\nAfter updating, try again.\n\nError: {}", error_msg)
        } else if error_msg.contains("ffmpeg") || error_msg.contains("ffprobe") {
            // Download might have succeeded but conversion failed - we'll check for files anyway
            println!("[Download] Warning: ffmpeg not found, but checking if download succeeded...");
            String::new() // Continue to file search
        } else {
            format!("yt-dlp error: {}\n\nTry updating yt-dlp: winget upgrade yt-dlp", error_msg)
        };
        
        if !user_error.is_empty() && !download_succeeded {
            return Ok(DownloadResult {
                success: false,
                title: None,
                path: None,
                error: Some(user_error),
            });
        }
    }
    
    println!("[Download] yt-dlp command completed successfully");
    
    // Wait for the file to be written - check multiple times with delays
    println!("[Download] Waiting for file to be written...");
    let mut attempts = 0;
    let max_attempts = 20; // Wait up to 10 seconds (20 * 500ms)
    let mut actual_path: Option<PathBuf> = None;
    
    while attempts < max_attempts {
        std::thread::sleep(std::time::Duration::from_millis(500));
        attempts += 1;
        
        // First check expected paths (mp3 and mp4)
        if expected_path_mp3.exists() {
            println!("[Download] Found expected MP3 file: {}", expected_path_mp3.display());
            actual_path = Some(expected_path_mp3.clone());
            break;
        }
        if expected_path_mp4.exists() {
            println!("[Download] Found expected MP4 file: {}", expected_path_mp4.display());
            actual_path = Some(expected_path_mp4.clone());
            break;
        }
        
        // If not found, search for any audio file (.mp3, .mp4, .m4a, etc.)
        if let Ok(dir_entries) = std::fs::read_dir(&output_path) {
            let mut audio_files: Vec<(PathBuf, std::time::SystemTime)> = Vec::new();
            for entry in dir_entries {
                if let Ok(entry) = entry {
                    let path = entry.path();
                    if let Some(ext) = path.extension() {
                        let ext_str = ext.to_string_lossy().to_lowercase();
                        // Accept mp3, mp4, m4a, webm, opus - common audio formats
                        if ext_str == "mp3" || ext_str == "mp4" || ext_str == "m4a" || 
                           ext_str == "webm" || ext_str == "opus" {
                            if let Ok(metadata) = entry.metadata() {
                                if let Ok(modified) = metadata.modified() {
                                    audio_files.push((path, modified));
                                }
                            }
                        }
                    }
                }
            }
            
            // Sort by modification time (newest first) and take the most recent
            audio_files.sort_by(|a, b| b.1.cmp(&a.1));
            
            if let Some((newest_file, modified)) = audio_files.first() {
                // Check if file was modified in the last 30 seconds (recent download)
                if let Ok(elapsed) = modified.elapsed() {
                    if elapsed.as_secs() < 30 {
                        println!("[Download] Found recently modified file: {} (modified {}s ago)", 
                            newest_file.display(), elapsed.as_secs());
                        actual_path = Some(newest_file.clone());
                        break;
                    }
                } else if attempts > 5 {
                    // If we can't check time but it's been a few attempts, use the newest file anyway
                    println!("[Download] Found file after {} attempts: {}", attempts, newest_file.display());
                    actual_path = Some(newest_file.clone());
                    break;
                }
            }
        }
        
        if attempts % 4 == 0 {
            println!("[Download] Still waiting for file... (attempt {}/{})", attempts, max_attempts);
        }
    }
    
    let actual_path = match actual_path {
        Some(path) => path,
        None => {
            println!("[Download] ERROR: File not found after {} attempts!", max_attempts);
            let expected_path_str = format!("{} or {}", expected_path_mp3.display(), expected_path_mp4.display());
            return Ok(DownloadResult {
                success: false,
                title: Some(title),
                path: None,
                error: Some(format!("Downloaded file not found after waiting. Expected: {}", expected_path_str)),
            });
        }
    };

    println!("[Download] SUCCESS: File path: {}", actual_path.display());
    Ok(DownloadResult {
        success: true,
        title: Some(title),
        path: Some(actual_path.to_string_lossy().to_string()),
        error: None,
    })
}


#[tauri::command]
pub async fn play_sound(_sound_type: String) -> Result<(), String> {
    // This can be implemented to play system sounds
    // For now, we'll let the frontend handle it
    Ok(())
}

#[tauri::command]
pub async fn ensure_dir(path: String) -> Result<(), String> {
    std::fs::create_dir_all(&path)
        .map_err(|e| format!("Failed to create directory: {}", e))?;
    Ok(())
}

#[tauri::command]
pub async fn list_files(dir: String) -> Result<Vec<String>, String> {
    let entries = std::fs::read_dir(&dir)
        .map_err(|e| format!("Failed to read directory: {}", e))?;
    
    let mut files = Vec::new();
    for entry in entries {
        if let Ok(entry) = entry {
            if let Some(name) = entry.file_name().to_str() {
                files.push(name.to_string());
            }
        }
    }
    
    Ok(files)
}

fn sanitize_filename(filename: &str) -> String {
    filename
        .chars()
        .map(|c| match c {
            '<' | '>' | ':' | '"' | '/' | '\\' | '|' | '?' | '*' => '_',
            _ => c,
        })
        .collect()
}


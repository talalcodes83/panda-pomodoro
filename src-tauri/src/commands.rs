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
    let app_data = app.path()
        .app_data_dir()
        .map_err(|e| format!("Failed to get app data directory: {}", e))?;
    
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
    // Check if yt-dlp is available
    let yt_dlp_check = Command::new("yt-dlp")
        .arg("--version")
        .output();

    if yt_dlp_check.is_err() {
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

    let output_path = PathBuf::from(&output_dir);
    
    // Use yt-dlp to download audio
    let output = Command::new("yt-dlp")
        .arg("--extract-audio")
        .arg("--audio-format")
        .arg("mp3")
        .arg("--audio-quality")
        .arg("192K")
        .arg("-o")
        .arg(format!("{}/%(title)s.%(ext)s", output_dir))
        .arg("--no-playlist")
        .arg(&url)
        .output()
        .map_err(|e| format!("Failed to execute yt-dlp: {}", e))?;

    if !output.status.success() {
        let error_msg = String::from_utf8_lossy(&output.stderr);
        return Ok(DownloadResult {
            success: false,
            title: None,
            path: None,
            error: Some(format!("yt-dlp error: {}", error_msg)),
        });
    }

    // Parse the output to get the filename
    let stdout = String::from_utf8_lossy(&output.stdout);
    let lines: Vec<&str> = stdout.lines().collect();
    
    // Try to find the downloaded file
    let title = extract_title_from_ytdlp_output(&stdout);
    let file_path = output_path.join(format!("{}.mp3", sanitize_filename(&title)));

    Ok(DownloadResult {
        success: true,
        title: Some(title),
        path: Some(file_path.to_string_lossy().to_string()),
        error: None,
    })
}

#[tauri::command]
pub async fn get_audio_path(path: String) -> Result<String, String> {
    // Return the path - Tauri will handle file access
    // For local files, we'll need to use Tauri's asset protocol or copy to a temp location
    // For now, return the path as-is
    Ok(path)
}

#[tauri::command]
pub async fn play_sound(sound_type: String) -> Result<(), String> {
    // This can be implemented to play system sounds
    // For now, we'll let the frontend handle it
    Ok(())
}

fn extract_title_from_ytdlp_output(output: &str) -> String {
    // yt-dlp typically outputs the title in the format:
    // [download] Destination: title.mp3
    // or similar formats
    
    for line in output.lines() {
        if line.contains("Destination:") || line.contains("[download]") {
            // Try to extract filename
            if let Some(start) = line.find("/") {
                if let Some(end) = line.rfind(".") {
                    let title = &line[start + 1..end];
                    return title.trim().to_string();
                }
            }
        }
    }
    
    // Fallback: generate a name based on timestamp
    format!("track_{}", std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_secs())
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


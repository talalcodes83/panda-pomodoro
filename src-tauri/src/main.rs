// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod commands;

use commands::*;

fn main() {
    tauri::Builder::default()
        .invoke_handler(tauri::generate_handler![
            get_app_data_dir,
            download_youtube_audio,
            get_audio_path,
            play_sound
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}


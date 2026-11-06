package com.hatkid.mkxpz;

import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowInsets;
import android.view.WindowInsetsController;
import android.view.WindowManager;
import android.widget.ProgressBar;
import android.widget.TextView;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class BootstrapActivity extends Activity {

    private static final String TAG = "TianJiang[Boot]";
    private static final String GAME_DIR = "game";
    static final String READY_FILE = ".ready_v28";
    private static final String GAME_ZIP = "game.zip";
    private static final String CORE_ZIP = "core.zip";
    private static final String SAVE_BACKUP = "game_save_backup";

    private TextView statusView;
    private TextView hintView;
    private ProgressBar progressView;
    private Thread extractThread;
    private volatile boolean extracting = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_bootstrap);
        applyImmersiveMode();

        statusView = findViewById(R.id.boot_status);
        hintView = findViewById(R.id.boot_hint);
        progressView = findViewById(R.id.boot_progress);

        File gameDir = new File(getFilesDir(), GAME_DIR);
        if (isReady(gameDir)) {
            refreshCoreFiles(gameDir);
            startGame();
            return;
        }

        statusView.setOnClickListener(v -> {
            if (!extracting) {
                statusView.setText(R.string.boot_loading);
                startExtraction();
            }
        });
        startExtraction();
    }

    private void applyImmersiveMode()
    {
        Window window = getWindow();
        if (window == null) return;

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            WindowManager.LayoutParams lp = window.getAttributes();
            lp.layoutInDisplayCutoutMode =
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            window.setAttributes(lp);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.setDecorFitsSystemWindows(false);
            WindowInsetsController controller = window.getInsetsController();
            if (controller != null) {
                controller.setSystemBarsBehavior(
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE);
                controller.hide(WindowInsets.Type.systemBars());
            }
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
            window.getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus)
    {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            applyImmersiveMode();
        }
    }

    private boolean isReady(File gameDir) {
        return new File(gameDir, READY_FILE).isFile();
    }

    /**
     * Refresh only the small core files (scripts/config) from assets/core.zip.
     * This lets script fixes apply on update without unpacking the whole 60MB
     * game archive again. If anything goes wrong the old files are kept.
     */
    private void refreshCoreFiles(File gameDir) {
        long start = System.currentTimeMillis();
        int count = 0;
        try (InputStream raw = getAssets().open(CORE_ZIP);
             ZipInputStream zip = new ZipInputStream(new BufferedInputStream(raw))) {
            String root = gameDir.getCanonicalPath();
            ZipEntry entry;
            while ((entry = zip.getNextEntry()) != null) {
                if (!entry.isDirectory()) {
                    File out = new File(gameDir, entry.getName());
                    String outPath = out.getCanonicalPath();
                    if (!outPath.equals(root) && !outPath.startsWith(root + File.separator)) {
                        throw new IOException("非法路径: " + entry.getName());
                    }
                    File parent = out.getParentFile();
                    if (parent != null && !parent.exists() && !parent.mkdirs()) {
                        throw new IOException("无法创建目录: " + parent.getAbsolutePath());
                    }
                    File tmpOut = new File(parent, out.getName() + ".refresh.tmp");
                    try (FileOutputStream fos = new FileOutputStream(tmpOut);
                         BufferedOutputStream bos = new BufferedOutputStream(fos, 16 * 1024)) {
                        byte[] buffer = new byte[16 * 1024];
                        int read;
                        while ((read = zip.read(buffer)) > 0) {
                            bos.write(buffer, 0, read);
                        }
                    }
                    if (!tmpOut.renameTo(out)) {
                        throw new IOException("无法替换文件: " + out.getAbsolutePath());
                    }
                    count++;
                }
                zip.closeEntry();
            }
            Log.i(TAG, "Core files refreshed: " + count + " in "
                    + (System.currentTimeMillis() - start) + "ms");
        } catch (Exception e) {
            Log.e(TAG, "Failed to refresh core files", e);
        }
    }

    private void startExtraction() {
        if (extracting) return;
        extracting = true;
        progressView.setIndeterminate(true);
        final File gameDir = new File(getFilesDir(), GAME_DIR);

        extractThread = new Thread(() -> {
            try {
                extractGame(gameDir);
                runOnUiThread(this::startGame);
            } catch (Exception e) {
                Log.e(TAG, "Failed to unpack game data", e);
                final String message = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
                runOnUiThread(() -> {
                    extracting = false;
                    progressView.setIndeterminate(false);
                    progressView.setProgress(0);
                    statusView.setText("载入失败，点此重试");
                    hintView.setText(message);
                });
            }
        }, "tianjiang-unpack");
        extractThread.start();
    }

    private void extractGame(File gameDir) throws IOException {
        File saveBackup = new File(getFilesDir(), SAVE_BACKUP);
        backupSaves(gameDir, saveBackup);
        deleteRecursive(gameDir);
        if (!gameDir.mkdirs() && !gameDir.isDirectory()) {
            throw new IOException("无法创建游戏目录");
        }

        String rootPath = gameDir.getCanonicalPath();
        int entries = 0;
        try (InputStream raw = getAssets().open(GAME_ZIP);
             ZipInputStream zip = new ZipInputStream(new BufferedInputStream(raw))) {
            byte[] buffer = new byte[16 * 1024];
            ZipEntry entry;
            while ((entry = zip.getNextEntry()) != null) {
                File out = new File(gameDir, entry.getName());
                String outPath = out.getCanonicalPath();
                if (!outPath.equals(rootPath) && !outPath.startsWith(rootPath + File.separator)) {
                    throw new IOException("非法压缩包路径: " + entry.getName());
                }
                if (entry.isDirectory()) {
                    if (!out.exists() && !out.mkdirs()) {
                        throw new IOException("无法创建目录: " + entry.getName());
                    }
                } else {
                    File parent = out.getParentFile();
                    if (parent != null && !parent.exists() && !parent.mkdirs()) {
                        throw new IOException("无法创建目录: " + parent.getAbsolutePath());
                    }
                    try (FileOutputStream fos = new FileOutputStream(out);
                         BufferedOutputStream bos = new BufferedOutputStream(fos, 16 * 1024)) {
                        int read;
                        while ((read = zip.read(buffer)) > 0) {
                            bos.write(buffer, 0, read);
                        }
                    }
                }
                zip.closeEntry();
                entries++;
                if (entries % 100 == 0) {
                    final int current = entries;
                    runOnUiThread(() -> hintView.setText("正在解包游戏资源… 已解包 " + current + " 个文件"));
                }
            }
        }

        restoreSaves(saveBackup, gameDir);
        File ready = new File(gameDir, READY_FILE);
        if (!ready.createNewFile()) {
            throw new IOException("无法写入完成标记");
        }
        Log.i(TAG, "Game data unpacked: " + entries + " entries");
    }

    private void backupSaves(File gameDir, File backupDir) throws IOException {
        deleteRecursive(backupDir);
        File[] saves = gameDir.listFiles((dir, name) -> name.startsWith("Save") && name.endsWith(".rxdata"));
        if (saves == null || saves.length == 0) return;
        if (!backupDir.mkdirs() && !backupDir.isDirectory()) {
            throw new IOException("无法创建存档备份目录");
        }
        for (File save : saves) {
            copyFile(save, new File(backupDir, save.getName()));
        }
    }

    private void restoreSaves(File backupDir, File gameDir) throws IOException {
        File[] saves = backupDir.listFiles();
        if (saves != null) {
            for (File save : saves) {
                copyFile(save, new File(gameDir, save.getName()));
            }
        }
        deleteRecursive(backupDir);
    }

    private void copyFile(File src, File dst) throws IOException {
        try (FileInputStream fis = new FileInputStream(src);
             FileOutputStream fos = new FileOutputStream(dst)) {
            byte[] buffer = new byte[16 * 1024];
            int read;
            while ((read = fis.read(buffer)) > 0) {
                fos.write(buffer, 0, read);
            }
        }
    }

    private void deleteRecursive(File file) {
        if (file == null || !file.exists()) return;
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) {
                for (File child : children) {
                    deleteRecursive(child);
                }
            }
        }
        file.delete();
    }

    private void startGame() {
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }
}

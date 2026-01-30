## Sebelum masukin perubahan ke repo ini:
1. Buat branch baru dengan `git branch <nama_branch>`. Nama branch merupakan judul fitur.
2. Masuk ke branch baru tersebut dengan `git checkout <nama_branch`
3. Buka Godot dan buka project-nya.

## Cara masukin perubahan ke repo ini:
1. Pastikan kamu berada di branch yang sesuai dengan fitur yang dikerjakan
2. Masukkan semua perubahan dengan `git add .` atau masukkan satu-satu dengan `git add <nama_file>`
3. Buat pesan commit (wajib) dengan `git commit -m "<pesan_commit>"`
4. Upload perubahan dengan `git push origin <nama_branch>`
5. Buat pull request dari branch tersebut ke branch `main`
6. Jika tidak ada conflict (berwarna hijau), langsung merge pull request. Jika ada conflict, kasih tau programmer yang lain.
7. Masuk ke branch `main` dengan `git branch main`
8. Lakukan update repo lokal dengan `git pull`
9. Kembali lagi ke `"sebelum masukin perubahan ke repo ini"`

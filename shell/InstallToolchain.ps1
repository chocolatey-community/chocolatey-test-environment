if (Get-Command "choco.exe" -ErrorAction SilentlyContinue) 
{ 
    "7zip", "bitvise-ssh-server", "git", "notepadplusplus" | ForEach-Object -Process {choco install $_}
} 
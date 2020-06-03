if (Get-Command "choco.exe" -ErrorAction SilentlyContinue) 
{ 
    "7zip", "git", "notepadplusplus" | ForEach-Object -Process {choco install $_}
} 
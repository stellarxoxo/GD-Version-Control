# Check for admin privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This installer must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator', then try again." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Starting installation..." -ForegroundColor Green

# Configuration
$repoUrl = "https://github.com/stellarxoxo/GD-Version-Control"
$zipUrl = "https://github.com/stellarxoxo/GD-Version-Control/raw/refs/heads/main/GD%20Version%20Control.zip"
$programName = "GD Version Control"

# Create installation directory
$installPath = "$env:ProgramFiles\GD Version Control"
$temp = "$env:TEMP\${programName}_installer_$(Get-Random)"
New-Item -ItemType Directory -Path $temp -Force | Out-Null

try {
    Write-Host "Downloading $programName..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $zipUrl -OutFile "$temp\package.zip" -UseBasicParsing
    
    Write-Host "Extracting files..." -ForegroundColor Cyan
    Expand-Archive -Path "$temp\package.zip" -DestinationPath "$temp\extracted" -Force
    
    Write-Host "Installing to $installPath..." -ForegroundColor Cyan
    # Create installation directory if it doesn't exist
    if (Test-Path $installPath) {
        Remove-Item -Path $installPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $installPath -Force | Out-Null
    
    # Copy extracted files to installation directory
    $extractedContent = Get-ChildItem -Path "$temp\extracted" -Recurse
    Copy-Item -Path "$temp\extracted\*" -Destination $installPath -Recurse -Force
    
    Write-Host "Looking for path_adder..." -ForegroundColor Cyan
    $batFile = Get-ChildItem -Path $installPath -Name "path_adder.*" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.bat', '.cmd', '.ps1') } | Select-Object -First 1
    
    if ($batFile -and $batFile.FullName) {
        $batPath = $batFile.FullName
        Write-Host "Found: $batPath" -ForegroundColor Gray
        Write-Host "Running path adder..." -ForegroundColor Green
        
        $batDir = Split-Path $batPath -Parent
        Push-Location $batDir
        
        if ($batFile.Extension -eq '.ps1') {
            Write-Host "Running PowerShell script..." -ForegroundColor Yellow
            $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "`"$batPath`"" -Wait -PassThru -WorkingDirectory $batDir
            Write-Host "Script completed with exit code: $($process.ExitCode)" -ForegroundColor Gray
        } else {
            & cmd.exe /c "`"$batPath`""
        }
        
        Pop-Location
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n✅ $programName installed successfully to $installPath!" -ForegroundColor Green
        } else {
            Write-Host "`n❌ Installation may have encountered issues." -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ Error: path_adder file not found!" -ForegroundColor Red
        Write-Host "Looking for: path_adder.bat, path_adder.cmd, or path_adder.ps1" -ForegroundColor Yellow
        Write-Host "Contents of installation directory:" -ForegroundColor Yellow
        Get-ChildItem -Path $installPath -Recurse | ForEach-Object { Write-Host "  $($_.FullName)" -ForegroundColor Gray }
        exit 1
    }
    
} catch {
    Write-Host "❌ Error during installation: $_" -ForegroundColor Red
    exit 1
} finally {
    # Cleanup only temporary files, keep the installation
    Write-Host "Cleaning up temporary files..." -ForegroundColor Gray
    Remove-Item -Path $temp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`nInstallation complete! You can now close this window." -ForegroundColor Green
Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# SHORT ONE-LINER (what users will run):
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing 'https://raw.githubusercontent.com/stellarxoxo/GD-Version-Control/main/install.ps1') }"

# ================================================================================================
# FULL INSTALLER SCRIPT (save this as "install.ps1" in your GitHub repo root):
# ================================================================================================

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

# Clean up old PATH entries first
Write-Host "Cleaning up old PATH entries..." -ForegroundColor Yellow

$currentSystemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Remove any existing "GD Version Control\GD Version Control" entries from system PATH
if ($currentSystemPath -like "*GD Version Control\GD Version Control*") {
    Write-Host "Removing old system PATH entry..." -ForegroundColor Gray
    $cleanSystemPath = $currentSystemPath -replace '[^;]*GD Version Control\\GD Version Control[^;]*;?', ''
    $cleanSystemPath = $cleanSystemPath -replace '^;|;$', ''  # Remove leading/trailing semicolons
    $cleanSystemPath = $cleanSystemPath -replace ';;', ';'    # Remove double semicolons
    [Environment]::SetEnvironmentVariable("Path", $cleanSystemPath, "Machine")
}

# Remove any existing "GD Version Control\GD Version Control" entries from user PATH
if ($currentUserPath -like "*GD Version Control\GD Version Control*") {
    Write-Host "Removing old user PATH entry..." -ForegroundColor Gray
    $cleanUserPath = $currentUserPath -replace '[^;]*GD Version Control\\GD Version Control[^;]*;?', ''
    $cleanUserPath = $cleanUserPath -replace '^;|;$', ''  # Remove leading/trailing semicolons
    $cleanUserPath = $cleanUserPath -replace ';;', ';'    # Remove double semicolons
    [Environment]::SetEnvironmentVariable("Path", $cleanUserPath, "User")
}

# Create installation directory in AppData
$installPath = "$env:APPDATA\GD Version Control"
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
    
    # Wait for antivirus to finish scanning
    Write-Host "Waiting for file system to settle..." -ForegroundColor Gray
    Start-Sleep -Milliseconds 500
    
    Write-Host "Setting up PATH..." -ForegroundColor Cyan
    
    # Use the actual installation directory for PATH
    $pathToAdd = "$installPath\GD Version Control"
    Write-Host "Adding directory to PATH: $pathToAdd" -ForegroundColor Gray
    
    # Get current PATH values (refreshed after cleanup)
    $currentSystemPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

    # Check if the directory is already in PATH
    $alreadyInPath = $false
    if ($currentSystemPath -like "*$pathToAdd*") {
        Write-Host "Directory is already in system PATH!" -ForegroundColor Green
        $alreadyInPath = $true
    } elseif ($currentUserPath -like "*$pathToAdd*") {
        Write-Host "Directory is already in user PATH!" -ForegroundColor Green
        $alreadyInPath = $true
    }

    if (-not $alreadyInPath) {
        # Add to PATH for current session
        $env:PATH = "$env:PATH;$pathToAdd"
        Write-Host "Added to PATH for current session." -ForegroundColor Green

        # Always add to PATH permanently (try system first, fallback to user)
        Write-Host "Adding to PATH permanently..." -ForegroundColor Yellow

        try {
            if ([string]::IsNullOrEmpty($currentSystemPath)) {
                $newSystemPath = $pathToAdd
            } else {
                $newSystemPath = "$currentSystemPath;$pathToAdd"
            }
            
            [Environment]::SetEnvironmentVariable("Path", $newSystemPath, "Machine")
            Write-Host "Successfully added to system PATH!" -ForegroundColor Green
            Write-Host "Please restart your command prompt or applications to see the changes." -ForegroundColor Yellow
            
        } catch {
            Write-Host "Failed to add to system PATH. Adding to user PATH instead..." -ForegroundColor Yellow
            
            try {
                if ([string]::IsNullOrEmpty($currentUserPath)) {
                    $newUserPath = $pathToAdd
                } else {
                    $newUserPath = "$currentUserPath;$pathToAdd"
                }
                
                [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
                Write-Host "Successfully added to user PATH!" -ForegroundColor Green
                Write-Host "Please restart your command prompt or applications to see the changes." -ForegroundColor Yellow
            } catch {
                Write-Host "Failed to add to PATH permanently. You may need to run as administrator." -ForegroundColor Red
            }
        }
    }

    Write-Host ""
    Write-Host "Installing Python package 'rich'..." -ForegroundColor Cyan

    try {
        $process = Start-Process -FilePath "pip3" -ArgumentList "install", "rich" -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$temp\pip_output.txt" -RedirectStandardError "$temp\pip_error.txt"
        
        if ($process.ExitCode -eq 0) {
            Write-Host "Successfully installed 'rich'!" -ForegroundColor Green
        } else {
            Write-Host "Failed to install 'rich'." -ForegroundColor Red
            if (Test-Path "$temp\pip_error.txt") {
                $errorContent = Get-Content "$temp\pip_error.txt" -Raw
                Write-Host "Error: $errorContent" -ForegroundColor Red
            }
            Write-Host "Make sure Python and pip3 are installed." -ForegroundColor Yellow
        }
        
    } catch {
        Write-Host "Failed to install 'rich'. Make sure Python and pip3 are installed." -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
    }

    Write-Host "`n✅ $programName installed successfully to $installPath!" -ForegroundColor Green
    
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

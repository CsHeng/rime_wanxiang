# Script to update Rime Wanxiang grammar file and git repository
# PowerShell equivalent of update.sh

# Constants
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MD5Url = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/md5sum.txt"
$MD5File = "$env:TEMP\wanxiang-lts-zh-hans.gram.md5sum.txt"
$GramUrl = "https://github.com/amzxyz/RIME-LMDG/releases/download/LTS/wanxiang-lts-zh-hans.gram"
$GramFile = Join-Path -Path (Split-Path -Parent $ScriptDir) -ChildPath "wanxiang-lts-zh-hans.gram"

# Log function with colored output
function Log-Message {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("info", "warn", "error")]
        [string]$Level,
        
        [Parameter(Mandatory=$true)]
        [string]$Message
    )
    
    switch ($Level) {
        "info" { Write-Host "[INFO] $Message" -ForegroundColor Green }
        "warn" { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
        "error" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
    }
}

# Download file function
function Download-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputFile,
        
        [Parameter(Mandatory=$true)]
        [string]$Description
    )
    
    Log-Message -Level "info" -Message "Downloading $Description..."
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputFile -ErrorAction Stop
        return $true
    }
    catch {
        Log-Message -Level "error" -Message "Failed to download $Description: $_"
        return $false
    }
}

# Get MD5 checksum of a file
function Get-MD5Checksum {
    param(
        [Parameter(Mandatory=$true)]
        [string]$File
    )
    
    try {
        $md5 = Get-FileHash -Path $File -Algorithm MD5 -ErrorAction Stop
        return $md5.Hash.ToLower()
    }
    catch {
        Log-Message -Level "error" -Message "Failed to calculate MD5: $_"
        return $null
    }
}

# Extract expected MD5 from MD5 file
function Get-ExpectedMD5 {
    param(
        [Parameter(Mandatory=$true)]
        [string]$MD5File
    )
    
    try {
        $content = Get-Content -Path $MD5File -TotalCount 1 -ErrorAction Stop
        if ($content -match "([0-9a-f]{32})") {
            return $matches[1].ToLower()
        }
        return $null
    }
    catch {
        Log-Message -Level "error" -Message "Failed to read MD5 file: $_"
        return $null
    }
}

# Check if grammar file needs to be updated
function Check-GrammarUpdate {
    if (-not (Download-File -Url $MD5Url -OutputFile $MD5File -Description "MD5 checksum")) {
        Log-Message -Level "error" -Message "Unable to download MD5 file, assuming update needed"
        return $true
    }
    
    if (-not (Test-Path -Path $GramFile)) {
        Log-Message -Level "info" -Message "Grammar file not found locally"
        return $true
    }
    
    Log-Message -Level "info" -Message "Checking MD5 checksums..."
    
    $expectedMD5 = Get-ExpectedMD5 -MD5File $MD5File
    $actualMD5 = Get-MD5Checksum -File $GramFile
    
    Log-Message -Level "info" -Message "Expected MD5: $expectedMD5"
    Log-Message -Level "info" -Message "Actual MD5:   $actualMD5"
    
    if ($expectedMD5 -eq $actualMD5) {
        Log-Message -Level "info" -Message "MD5 checksums match. No update needed."
        return $false
    }
    else {
        Log-Message -Level "info" -Message "MD5 checksums do not match. Update needed."
        return $true
    }
}

# Update grammar file
function Update-Grammar {
    if (-not (Download-File -Url $GramUrl -OutputFile $GramFile -Description "grammar file")) {
        Log-Message -Level "error" -Message "Failed to download grammar file"
        return $false
    }
    Log-Message -Level "info" -Message "Grammar file updated successfully"
    return $true
}

# Check for upstream git changes
function Check-GitUpdates {
    Log-Message -Level "info" -Message "Checking for upstream updates..."
    
    try {
        git fetch upstream
        $upstreamChanges = git rev-list --count HEAD..upstream/main
        
        if ([int]$upstreamChanges -gt 0) {
            Log-Message -Level "info" -Message "Found $upstreamChanges new commit(s)"
            return $true
        }
        else {
            Log-Message -Level "info" -Message "No upstream changes. Already up-to-date."
            return $false
        }
    }
    catch {
        Log-Message -Level "error" -Message "Failed to check git updates: $_"
        return $false
    }
}

# Update git repo by rebasing from upstream
function Update-GitRepo {
    Log-Message -Level "info" -Message "Rebasing with upstream..."
    try {
        git rebase --autostash upstream/main
        Log-Message -Level "info" -Message "Rebase complete"
        return $true
    }
    catch {
        Log-Message -Level "error" -Message "Failed to rebase: $_"
        return $false
    }
}

# Main execution
function Main {
    # Change to script directory
    try {
        Push-Location -Path $ScriptDir
        
        # Check and update grammar file if needed
        if (Check-GrammarUpdate) {
            Update-Grammar
        }
        
        # Check and update git repo if needed
        if (Check-GitUpdates) {
            Update-GitRepo
        }
        
        Log-Message -Level "info" -Message "Update process completed successfully"
    }
    finally {
        # Restore original location
        Pop-Location
    }
}

# Run the main function
Main

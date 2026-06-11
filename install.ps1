$ErrorActionPreference = 'Stop'

$repo = if ($env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REPO) {
    $env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REPO
} else {
    'JamesDBartlett3/claude-code-token-usage-dashboard'
}

$ref = if ($env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REF) {
    $env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_REF
} else {
    'main'
}

$archiveUrl = if ($env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_ARCHIVE_URL) {
    $env:CLAUDE_CODE_TOKEN_USAGE_DASHBOARD_ARCHIVE_URL
} else {
    "https://github.com/$repo/archive/refs/heads/$ref.zip"
}

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("claude-code-token-usage-dashboard-" + [System.Guid]::NewGuid().ToString('N'))
$archivePath = Join-Path $tempRoot 'repo.zip'

function Find-Python {
    foreach ($candidate in @('py', 'python', 'python3')) {
        if (Get-Command $candidate -ErrorAction SilentlyContinue) {
            return $candidate
        }
    }

    throw 'Python 3.10+ is required.'
}

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null

    Write-Host "Downloading $repo ($ref)..."
    if (Test-Path $archiveUrl) {
        Copy-Item -Path $archiveUrl -Destination $archivePath
    } else {
        Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
    }

    Write-Host 'Extracting installer...'
    Expand-Archive -Path $archivePath -DestinationPath $tempRoot -Force

    $installer = Get-ChildItem -Path $tempRoot -Filter install.py -Recurse | Select-Object -First 1
    if (-not $installer) {
        throw 'install.py was not found in the downloaded archive.'
    }

    $python = Find-Python
    Write-Host "Running installer with $python..."
    & $python $installer.FullName
} finally {
    if (Test-Path $tempRoot) {
        Remove-Item -Path $tempRoot -Recurse -Force
    }
}

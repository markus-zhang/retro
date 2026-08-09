param(
    [string]$SourceFile
)

$ErrorActionPreference = "Stop"

$Watcom = "C:\dev\OpenWATCOM"
$Bin = Join-Path $Watcom "BINNT"
$BinW = Join-Path $Watcom "BINW"

$Wasm = Join-Path $Bin "wasm.exe"
$Wlink = Join-Path $Bin "wlink.exe"

# ------------------------------------------------------------
# Validate active VSCode file
# ------------------------------------------------------------

if ([string]::IsNullOrWhiteSpace($SourceFile)) {
    Write-Host "No active file. Nothing to build."
    exit 0
}

$SourceFile = [System.IO.Path]::GetFullPath($SourceFile)

if ([System.IO.Path]::GetExtension($SourceFile) -ine ".asm") {
    Write-Host "Active file is not an .asm file:"
    Write-Host "  $SourceFile"
    Write-Host "Nothing to build."
    exit 0
}

if (-not (Test-Path $SourceFile)) {
    Write-Host "Source file does not exist:"
    Write-Host "  $SourceFile"
    exit 0
}

# ------------------------------------------------------------
# Project paths
# ------------------------------------------------------------

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

$BuildDirectory = Join-Path $Root "build"
$DeployDirectory = Join-Path $Root "deploy"

New-Item -ItemType Directory -Force $BuildDirectory | Out-Null
New-Item -ItemType Directory -Force $DeployDirectory | Out-Null

# ------------------------------------------------------------
# Determine target from directory containing the ASM file
#
# Example:
#   C:\dev\retro\dos-com\cga.asm
#                      ^^^^^^^
#                      target
# ------------------------------------------------------------

$Target = Split-Path (Split-Path $SourceFile -Parent) -Leaf

$ValidTargets = @(
    "dos-com",
    "dos16",
    "dos32",
    "win16",
    "win32"
)

if ($ValidTargets -notcontains $Target) {
    Write-Host "Cannot determine build target from active file."
    Write-Host ""
    Write-Host "ASM file must be directly inside one of:"
    Write-Host "  dos-com"
    Write-Host "  dos16"
    Write-Host "  dos32"
    Write-Host "  win16"
    Write-Host "  win32"
    Write-Host ""
    Write-Host "Active file:"
    Write-Host "  $SourceFile"
    exit 0
}

# ------------------------------------------------------------
# Derive all output names from the ASM filename
# ------------------------------------------------------------

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($SourceFile)

$Extension = switch ($Target) {
    "dos-com" { ".com" }
    default   { ".exe" }
}

$Object = Join-Path $BuildDirectory "$BaseName.obj"
$Output = Join-Path $BuildDirectory "$BaseName$Extension"

$LinkFile = Join-Path $Root "link\$Target.lnk"

if (-not (Test-Path $LinkFile)) {
    throw "Linker file not found: $LinkFile"
}

# ------------------------------------------------------------
# CPU target
# ------------------------------------------------------------

$CpuOption = switch ($Target) {
    "dos-com" { "-0" } # 8086/8088
    "dos16"   { "-0" } # 8086/8088
    "dos32"   { "-3" } # 80386
    "win16"   { "-2" } # 80286
    "win32"   { "-3" } # 80386
}

# ------------------------------------------------------------
# Open Watcom environment
# ------------------------------------------------------------

$env:WATCOM = $Watcom
$env:PATH = "$Bin;$BinW;$env:PATH"

if (-not (Test-Path $Wasm)) {
    throw "WASM not found: $Wasm"
}

if (-not (Test-Path $Wlink)) {
    throw "WLINK not found: $Wlink"
}

# ------------------------------------------------------------
# Build
# ------------------------------------------------------------

Write-Host ""
Write-Host "Target : $Target"
Write-Host "Source : $SourceFile"
Write-Host "Output : $Output"
Write-Host ""

Write-Host "Cleaning previous output..."

Remove-Item $Object -Force -ErrorAction SilentlyContinue
Remove-Item $Output -Force -ErrorAction SilentlyContinue

$MapFile = Join-Path $BuildDirectory "$BaseName.map"
$SymFile = Join-Path $BuildDirectory "$BaseName.sym"

Remove-Item $MapFile -Force -ErrorAction SilentlyContinue
Remove-Item $SymFile -Force -ErrorAction SilentlyContinue

# ------------------------------------------------------------
# Assemble
# ------------------------------------------------------------

Write-Host "Assembling..."

& $Wasm `
    $CpuOption `
    "-d1" `
    "-fo=$Object" `
    $SourceFile

if ($LASTEXITCODE -ne 0) {
    throw "Assembly failed with exit code $LASTEXITCODE."
}

# ------------------------------------------------------------
# Link
#
# NAME and FILE are supplied here dynamically instead of being
# hard-coded inside the .lnk file.
# ------------------------------------------------------------

Write-Host "Linking..."

Push-Location $Root

try {
    & $Wlink `
        "@$LinkFile" `
        "name" $Output `
        "file" $Object

    if ($LASTEXITCODE -ne 0) {
        throw "Linking failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

# ------------------------------------------------------------
# Deploy
# ------------------------------------------------------------

Write-Host "Deploying..."

Copy-Item $Output $DeployDirectory -Force

if (Test-Path $SymFile) {
    Copy-Item $SymFile $DeployDirectory -Force
}

if (Test-Path $MapFile) {
    Copy-Item $MapFile $DeployDirectory -Force
}

Write-Host ""
Write-Host "Build succeeded."
Write-Host "Executable : $Output"
Write-Host "Deployment : $(Join-Path $DeployDirectory "$BaseName$Extension")"
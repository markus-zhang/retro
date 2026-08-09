param(
    [Parameter(Mandatory)]
    [ValidateSet("dos-com", "dos16", "dos32", "win16", "win32")]
    [string]$Target
)

$ErrorActionPreference = "Stop"

$Watcom = "C:\dev\OpenWATCOM"
$Bin = Join-Path $Watcom "BINNT"

$Wasm = Join-Path $Bin "wasm.exe"
$Wlink = Join-Path $Bin "wlink.exe"

if (-not (Test-Path $Wasm)) {
    throw "WASM not found: $Wasm"
}

if (-not (Test-Path $Wlink)) {
    throw "WLINK not found: $Wlink"
}

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

$BuildDirectory = Join-Path $Root "build"
$DeployDirectory = Join-Path $Root "deploy"

New-Item -ItemType Directory -Force $BuildDirectory | Out-Null
New-Item -ItemType Directory -Force $DeployDirectory | Out-Null

$Source = Join-Path $Root "$Target\rep.asm"
$Object = Join-Path $BuildDirectory "$Target.obj"
$LinkFile = Join-Path $Root "link\$Target.lnk"

if (-not (Test-Path $Source)) {
    throw "Source file not found: $Source"
}

if (-not (Test-Path $LinkFile)) {
    throw "Linker file not found: $LinkFile"
}

$CpuOption = switch ($Target) {
    "dos-com" { "-0" } # 8086/8088
    "dos16"   { "-0" }
    "dos32"   { "-3" } # 386
    "win16"   { "-2" } # 286
    "win32"   { "-3" }
}

Write-Host "Cleaning previous $Target output..."

Remove-Item $Object -Force -ErrorAction SilentlyContinue

Write-Host "Assembling $Source..."

& $Wasm $CpuOption "-d1" "-fo=$Object" $Source

if ($LASTEXITCODE -ne 0) {
    throw "Assembly failed with exit code $LASTEXITCODE."
}

Write-Host "Linking with $LinkFile..."

Push-Location $Root

try {
    & $Wlink "@$LinkFile"

    if ($LASTEXITCODE -ne 0) {
        throw "Linking failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

Write-Host "Copying build output to deploy..."

Copy-Item (Join-Path $BuildDirectory "*") `
    $DeployDirectory `
    -Force

Write-Host ""
Write-Host "Build succeeded."
Write-Host "Executable: $BuildDirectory\hello.com"
Write-Host "Deployment: $DeployDirectory\hello.com"
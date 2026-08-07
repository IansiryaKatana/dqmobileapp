# Sets FCM_SERVICE_ACCOUNT_JSON on the Donate Quran Supabase project.
# Requires: supabase CLI logged in as an owner/admin of project mildsuuygbzgdunwmzuk
#
# Usage (PowerShell, from repo root):
#   .\scripts\set-fcm-supabase-secret.ps1

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$secretFile = Join-Path $root ".secrets\FCM_SERVICE_ACCOUNT_JSON.txt"
$envFile = Join-Path $root ".env"

function Read-FcmJson {
  if (Test-Path $secretFile) {
    $raw = (Get-Content $secretFile -Raw).Trim()
    if ($raw) { return $raw }
  }
  if (Test-Path $envFile) {
    foreach ($line in Get-Content $envFile) {
      if ($line -match '^\s*FCM_SERVICE_ACCOUNT_JSON=(.+)$') {
        return $Matches[1].Trim().Trim('"').Trim("'")
      }
    }
  }
  Write-Error "Missing FCM JSON. Put one-line JSON in .secrets\FCM_SERVICE_ACCOUNT_JSON.txt or FCM_SERVICE_ACCOUNT_JSON in .env"
}

$json = Read-FcmJson
$null = $json | ConvertFrom-Json
$projectRef = "mildsuuygbzgdunwmzuk"

Write-Host "Setting FCM_SERVICE_ACCOUNT_JSON on $projectRef ..."
$tmp = Join-Path $env:TEMP "supabase-fcm-secret.env"
[System.IO.File]::WriteAllText($tmp, "FCM_SERVICE_ACCOUNT_JSON=$json")
npx supabase secrets set --project-ref $projectRef --env-file $tmp
Remove-Item $tmp -Force -ErrorAction SilentlyContinue

Write-Host "Deploying push-broadcast..."
npx supabase functions deploy push-broadcast --project-ref $projectRef

Write-Host "Done. Test from CMS → Notifications."

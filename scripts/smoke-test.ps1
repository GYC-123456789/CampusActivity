param(
  [string]$BaseUrl = "http://124.220.81.104"
)

$ErrorActionPreference = "Stop"

$base = $BaseUrl.TrimEnd("/")
$apiUrl = "$base/api/v1/orders?page=1&size=1"

Write-Host "Checking $base/"
$homeResponse = Invoke-WebRequest -Uri "$base/" -UseBasicParsing -TimeoutSec 15
if ($homeResponse.StatusCode -lt 200 -or $homeResponse.StatusCode -ge 400) {
  throw "Home page returned HTTP $($homeResponse.StatusCode)"
}

Write-Host "Checking $apiUrl"
$api = Invoke-RestMethod -Uri $apiUrl -TimeoutSec 15
if ($api.code -ne 200) {
  throw "API smoke test failed. code=$($api.code), message=$($api.message)"
}

Write-Host "Smoke test passed: $base"

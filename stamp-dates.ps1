<#
.SYNOPSIS
  Stamps real publication dates into the posts and the Atom feed.

.DESCRIPTION
  The posts ship with @@DATE1@@ / @@HUMAN1@@ placeholders so that no wrong or
  invalid date can leak into a feed reader. Run this once, on publication day,
  after fovea 0.4.0 is on crates.io. Re-runnable only from a clean checkout —
  once stamped, the placeholders are gone.

.EXAMPLE
  ./stamp-dates.ps1 -Date1 2026-08-18 -Date2 2026-08-25 -Date3 2026-09-01

.EXAMPLE
  # all three live the same day (recommended: the series nav then always works)
  ./stamp-dates.ps1 -Date1 2026-08-18 -Date2 2026-08-18 -Date3 2026-08-18
#>
param(
  [Parameter(Mandatory)][datetime]$Date1,
  [Parameter(Mandatory)][datetime]$Date2,
  [Parameter(Mandatory)][datetime]$Date3
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$map = @{}
$i = 1
foreach ($d in @($Date1, $Date2, $Date3)) {
  # RFC 3339 / ISO 8601 in UTC — required by Atom and by og:article:published_time
  $map["@@DATE$i@@"]  = $d.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
  # human-readable, for the visible byline
  $map["@@HUMAN$i@@"] = $d.ToString('d MMMM yyyy', [cultureinfo]::InvariantCulture)
  $i++
}

$targets = Get-ChildItem -LiteralPath $here -Include '0*.html', 'feed.xml' -File
$touched = 0

foreach ($f in $targets) {
  $text = Get-Content -Raw -LiteralPath $f.FullName
  $orig = $text
  foreach ($k in $map.Keys) { $text = $text.Replace($k, $map[$k]) }
  if ($text -ne $orig) {
    Set-Content -LiteralPath $f.FullName -Value $text -NoNewline
    Write-Output "stamped: $($f.Name)"
    $touched++
  }
}

if ($touched -eq 0) { Write-Warning 'No placeholders found — already stamped?' }

$left = Select-String -Path (Join-Path $here '*.html'), (Join-Path $here 'feed.xml') -Pattern '@@(DATE|HUMAN)\d@@' -ErrorAction SilentlyContinue
if ($left) {
  Write-Warning "Placeholders still present:"
  $left | ForEach-Object { Write-Warning "  $($_.Filename):$($_.LineNumber)" }
} else {
  Write-Output 'All date placeholders resolved.'
}

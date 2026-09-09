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

# $PSScriptRoot, not $MyInvocation.MyCommand.Path. The latter is empty when the
# script is started with `powershell -Command ./stamp-dates.ps1`, which is what
# a scheduled run or a double-click on Windows PowerShell does, and the failure
# is a null-reference somewhere further down rather than anything that names the
# cause. $PSScriptRoot is filled in for every invocation of a script file.
$here = $PSScriptRoot

$map = @{}
$i = 1
foreach ($d in @($Date1, $Date2, $Date3)) {
  # One calendar day, written twice: RFC 3339 in UTC because Atom and
  # og:article:published_time want that, and in prose because the byline does.
  #
  # Both readings have to name the same day. Converting a local midnight to UTC
  # does not: anywhere east of Greenwich it lands in the previous day, so the
  # feed said the 14th while the byline said the 15th. Noon is far enough from
  # both edges of the day that every reader from UTC-11 to UTC+11 is told the
  # date that is printed. Any time of day passed on the command line is
  # dropped, since a publication date is a day and not a moment.
  $day = $d.Date
  $map["@@DATE$i@@"]  = $day.ToString('yyyy-MM-dd') + 'T12:00:00Z'
  $map["@@HUMAN$i@@"] = $day.ToString('d MMMM yyyy', [cultureinfo]::InvariantCulture)
  $i++
}

# Wildcards in -Path, not -LiteralPath with -Include. The second pair looks
# equivalent and is not: Windows PowerShell 5.1 ignores the -Include filter here
# and hands back every file in the directory, so the run rewrote this script's
# own documentation, where the placeholders are named as examples. Anything else
# in the folder holding a string that looks like a placeholder would have gone
# the same way. pwsh 7 filters correctly, which is why it never showed up
# interactively. A missing target throws, which is the outcome we want: better a
# stopped run than a published file nobody stamped.
$targets = Get-ChildItem -File -Path @(
  Join-Path $here '0*.html'
  Join-Path $here 'feed.xml'
  Join-Path $here 'sitemap.xml'
)
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

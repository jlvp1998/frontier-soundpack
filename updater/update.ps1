# Frontier soundpack updater.
# Gets new and changed files from GitHub (jlvp1998/frontier-soundpack).
#   -Mode check   : just see if there's an update (runs hidden when you connect)
#   -Mode update  : download what changed (the spupdate command)
# When it finishes it writes updater\status.txt so the soundpack can tell you what happened.
param([string]$Mode = "update")

$ErrorActionPreference = "Stop"
$Repo   = "jlvp1998/frontier-soundpack"
$Branch = "main"
$Here   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Root   = Split-Path -Parent $Here
$Status = Join-Path $Here "status.txt"
$Installed = Join-Path $Here "installed.txt"   # commit we last updated to
$FileList  = Join-Path $Here "files.txt"       # files that commit had (to remove deleted ones)
$SeenFile  = Join-Path $Here "seen.txt"        # newest commit whose "what's new" we already showed

# Your own settings. Downloaded only if you don't have them yet.
$KeepMine = @("mushclient_prefs.sqlite", "worlds/world.MCL", "spell/spell.sqlite", "spell/spell.sqlite-shm", "spell/spell.sqlite-wal", "spell/userdict.txt")

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Say($t) { if ($Mode -ne "check") { Write-Host $t } }

function Done($state, $lines) {
  [IO.File]::WriteAllLines($Status, [string[]](@($state) + @($lines)), $utf8)
}

function Api($path) {
  $wc = New-Object System.Net.WebClient
  $wc.Headers.Add("User-Agent", "frontier-soundpack-updater")
  $wc.Headers.Add("Accept", "application/vnd.github+json")
  $wc.Encoding = [Text.Encoding]::UTF8
  return ($wc.DownloadString("https://api.github.com/repos/$Repo/$path") | ConvertFrom-Json)
}

# Same id git gives a file, so we can tell if yours matches without downloading it.
$sha1 = [Security.Cryptography.SHA1]::Create()
function BlobSha($file) {
  $bytes = [IO.File]::ReadAllBytes($file)
  $head = [Text.Encoding]::ASCII.GetBytes("blob $($bytes.Length)`0")
  $sha1.Initialize()
  [void]$sha1.TransformBlock($head, 0, $head.Length, $null, 0)
  [void]$sha1.TransformFinalBlock($bytes, 0, $bytes.Length)
  return (($sha1.Hash | ForEach-Object { $_.ToString("x2") }) -join "")
}

function WhatsNew($old, $new) {
  if (-not $old) { return @() }
  try {
    $c = Api "compare/$old...$new"
    return @($c.commits | ForEach-Object { "- " + (($_.commit.message -split "`n")[0]).Trim() })
  } catch { return @() }
}

try {
  $latest = (Api "commits/$Branch").sha
  $mine = ""
  if (Test-Path -LiteralPath $Installed) { $mine = ([IO.File]::ReadAllText($Installed)).Trim() }
  $seen = $mine
  if (Test-Path -LiteralPath $SeenFile) { $seen = ([IO.File]::ReadAllText($SeenFile)).Trim() }

  if ($Mode -eq "check" -and $mine -eq $latest) { Done "uptodate" @(); exit 0 }

  Say "Frontier soundpack updater"
  Say "Checking your files. This can take a minute..."
  $tree = Api "git/trees/$latest`?recursive=1"
  $files = @($tree.tree | Where-Object { $_.type -eq "blob" })
  # Remembered checks: path -> "size|time|sha", so unchanged files aren't read again.
  $CacheFile = Join-Path $Here "hashes.txt"
  $cache = @{}
  if (Test-Path -LiteralPath $CacheFile) {
    foreach ($l in [IO.File]::ReadAllLines($CacheFile, $utf8)) {
      $i = $l.IndexOf("`t")
      if ($i -gt 0) { $cache[$l.Substring(0, $i)] = $l.Substring($i + 1) }
    }
  }
  $newcache = New-Object System.Collections.ArrayList
  $need = New-Object System.Collections.ArrayList
  foreach ($f in $files) {
    $local = Join-Path $Root ($f.path -replace "/", "\")
    if (Test-Path -LiteralPath $local) {
      if ($KeepMine -contains $f.path) { continue }
      $info = Get-Item -LiteralPath $local
      if ($info.Length -eq $f.size) {
        $stamp = "$($info.Length)|$($info.LastWriteTimeUtc.Ticks)"
        $c = $cache[$f.path]
        if ($c -and $c.StartsWith("$stamp|")) { $sha = $c.Substring($stamp.Length + 1) }
        else {
          # A file MUSHclient has open can't be read. Skip it; it's not one we can replace right now anyway.
          try { $sha = BlobSha $local } catch { continue }
        }
        if ($sha -eq $f.sha) { [void]$newcache.Add("$($f.path)`t$stamp|$sha"); continue }
      }
    }
    [void]$need.Add($f)
  }

  if ($Mode -eq "check") {
    # Only say there's an update if some of your files really are different or missing.
    [IO.File]::WriteAllLines($CacheFile, [string[]]$newcache, $utf8)
    if ($need.Count -eq 0) {
      [IO.File]::WriteAllText($Installed, $latest, $utf8)
      [IO.File]::WriteAllLines($FileList, [string[]]@($files | ForEach-Object { $_.path }), $utf8)
      Done "uptodate" @()
    } else { Done "available" (WhatsNew $seen $latest) }
    exit 0
  }

  # Clear out old copies left from files that were in use last time.
  Get-ChildItem -LiteralPath $Root -Recurse -Filter "*.old" -File -ErrorAction SilentlyContinue | ForEach-Object { try { Remove-Item -LiteralPath $_.FullName -Force } catch {} }
  $failed = New-Object System.Collections.ArrayList
  $n = 0
  $wc = New-Object System.Net.WebClient
  $wc.Headers.Add("User-Agent", "frontier-soundpack-updater")
  foreach ($f in $need) {
    $n++
    Say ("[{0}/{1}] {2}" -f $n, $need.Count, $f.path)
    $local = Join-Path $Root ($f.path -replace "/", "\")
    $url = "https://raw.githubusercontent.com/$Repo/$latest/" + (($f.path -split "/" | ForEach-Object { [Uri]::EscapeDataString($_) }) -join "/")
    try {
      $dir = Split-Path -Parent $local
      if (-not (Test-Path -LiteralPath $dir)) { [void](New-Item -ItemType Directory -Path $dir -Force) }
      $tmp = "$local.download"
      $wc.DownloadFile($url, $tmp)
      try { Move-Item -LiteralPath $tmp -Destination $local -Force }
      catch {
        # The file is in use (a sound playing). Windows lets us rename it out of the way.
        $old = "$local.old"
        if (Test-Path -LiteralPath $old) { Remove-Item -LiteralPath $old -Force -ErrorAction SilentlyContinue }
        Rename-Item -LiteralPath $local -NewName ([IO.Path]::GetFileName($old)) -Force
        Move-Item -LiteralPath $tmp -Destination $local -Force
      }
      $info = Get-Item -LiteralPath $local
      [void]$newcache.Add("$($f.path)`t$($info.Length)|$($info.LastWriteTimeUtc.Ticks)|$($f.sha)")
    } catch {
      [void]$failed.Add($f.path)
      if (Test-Path -LiteralPath "$local.download") { Remove-Item -LiteralPath "$local.download" -Force }
    }
  }

  # Remove files that were taken out of the pack (only ones the pack put there).
  $removed = 0
  if (Test-Path -LiteralPath $FileList) {
    $now = @{}
    foreach ($f in $files) { $now[$f.path] = 1 }
    foreach ($p in [IO.File]::ReadAllLines($FileList, $utf8)) {
      if ($p -and -not $now.ContainsKey($p) -and $KeepMine -notcontains $p) {
        $local = Join-Path $Root ($p -replace "/", "\")
        if (Test-Path -LiteralPath $local) {
          try { Remove-Item -LiteralPath $local -Force; $removed++; Say "Removed $p" } catch {}
        }
      }
    }
  }

  [IO.File]::WriteAllLines($CacheFile, [string[]]$newcache, $utf8)
  $news = WhatsNew $seen $latest
  [IO.File]::WriteAllText($SeenFile, $latest, $utf8)
  if ($failed.Count -gt 0) {
    Say ""
    Say "$($failed.Count) files couldn't be updated (probably in use). Close MUSHclient and run updater\update.bat."
    Done "error" (@("$($need.Count - $failed.Count) files updated, $($failed.Count) couldn't be. Close MUSHclient, then run update.bat in the updater folder.") + $news)
    exit 1
  }
  [IO.File]::WriteAllText($Installed, $latest, $utf8)
  [IO.File]::WriteAllLines($FileList, [string[]]@($files | ForEach-Object { $_.path }), $utf8)
  if ($need.Count -eq 0 -and $removed -eq 0) { $msg = "Your soundpack is already up to date." }
  else { $msg = "Soundpack updated: $($need.Count) files downloaded, $removed removed." }
  Say ""
  Say $msg
  Done "done" (@($msg) + $news)
  exit 0
} catch {
  $err = $_.Exception.Message
  if ($Mode -ne "check") { Write-Host "Update failed: $err" }
  Done "error" @("The update didn't work: $err")
  exit 1
}

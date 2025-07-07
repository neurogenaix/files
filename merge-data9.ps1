$fileA = 'A.txt'   # small lookup file (~40 KB)
$fileB = 'B.txt'   # large dataset (~500 MB)
$fileC = 'C.txt'   # output file

if (Test-Path $fileC) { Remove-Item $fileC }

# Load File A into memory
$aLines = Get-Content $fileA
Write-Host "Loaded File A with $($aLines.Count) lines."

# Build a hashtable: key = first field, value = full A line
$lookup = @{}
foreach ($aLine in $aLines) {
    $key = ($aLine -split ':', 2)[0]
    if ($key -ne '') {
        $lookup[$key] = $aLine
    }
}
Write-Host "Built lookup table with $($lookup.Count) keys."

# Prepare output stream
$writer = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)
$totalMatches = 0
$linesProcessed = 0

Write-Host "Begin streaming through File B..."
$sr = [System.IO.File]::OpenText($fileB)

while (-not $sr.EndOfStream) {
    $bLine = $sr.ReadLine()
    if ($bLine -eq $null) { continue }   # Skip nulls, avoids error :contentReference[oaicite:1]{index=1}

    $linesProcessed++
    if ($linesProcessed % 200000 -eq 0) {
        Write-Host "Processed $linesProcessed lines from File B..."
    }

    $parts = $bLine.Split(':', 6)
    if ($parts.Length -ge 4) {
        $key = $parts[3]
        if ($lookup.ContainsKey($key)) {
            $writer.WriteLine("$bLine$lookup[$key]")
            $totalMatches++
        }
    }
}

$sr.Close()
$writer.Close()

Write-Host "`nDONE."
Write-Host "Processed $linesProcessed lines from File B."
Write-Host "Wrote $totalMatches matching lines to $fileC."

# File paths
$fileA = 'A.txt'  # 40 KB (small)
$fileB = 'B.txt'  # 500 MB (large)
$fileC = 'C.txt'  # Output

# Clean up old output
if (Test-Path $fileC) { Remove-Item $fileC }

# Read small file A into memory
$aLines = Get-Content $fileA
Write-Host "Loaded File A: $($aLines.Count) lines"

# Build dictionary for File B: key = 4th field, value = list of lines
$Bdict = [System.Collections.Generic.Dictionary[string, System.Collections.Generic.List[string]]]::new()
Write-Host "Indexing File B (large, streaming)..."

$sr = [System.IO.File]::OpenText($fileB)
while (-not $sr.EndOfStream) {
    $line = $sr.ReadLine()
    $parts = $line.Split(':',6)
    if ($parts.Length -ge 4) {
        $key = $parts[3]
        if (-not $Bdict.ContainsKey($key)) {
            $Bdict[$key] = [System.Collections.Generic.List[string]]::new()
        }
        $Bdict[$key].Add($line)
    }
}
$sr.Close()
Write-Host "Built index of $($Bdict.Count) unique keys from File B"

# Prepare output stream
$out = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)
$total = 0

# Loop through File A, lookup in dictionary and write matches
Write-Host "Scanning File A keys against File B index..."
for ($i = 0; $i -lt $aLines.Count; $i++) {
    $aLine = $aLines[$i]
    $key = $aLine.Split(':',2)[0]
    Write-Host "[$($i+1)/$($aLines.Count)] Checking key '$key'..."
    if ($Bdict.ContainsKey($key)) {
        foreach ($bLine in $Bdict[$key]) {
            $out.WriteLine("$bLine$aLine")
            $total++
        }
        Write-Host "  → Found $($Bdict[$key].Count) matches"
    }
}

$out.Close()
Write-Host "✅ Done: $total total matches written to $fileC"

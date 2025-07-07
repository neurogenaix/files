$fileA = 'A.txt'   # small file
$fileB = 'B.txt'   # large file
$fileC = 'C.txt'   # output

if (Test-Path $fileC) { Remove-Item $fileC }
Write-Host "Counting File A..."
$aLines = Get-Content $fileA
Write-Host " -> File A has $($aLines.Count) lines"

# Build key lookup from File A
$lookup = @{}
$aLines | ForEach-Object {
    $key = ($_ -split ':',2)[0].Trim()
    if ($key -ne '') { $lookup[$key] = $_ }
}
Write-Host "Loaded $($lookup.Count) unique lookup keys from A"

# Index File B
$writer = [System.IO.StreamWriter]::new($fileC, $false, [System.Text.Encoding]::UTF8)
$total = 0
$linesB = 0

Write-Host "Scanning File B..."
$sr = [System.IO.File]::OpenText($fileB)
while (-not $sr.EndOfStream) {
    $bLine = $sr.ReadLine()
    $linesB++
    if ($linesB % 200000 -eq 0) {
        Write-Host "Processed $linesB lines from File B"
    }
    # Compare B's 4th field
    $parts = $bLine.Split(':',6)
    if ($parts.Length -ge 4) {
        $key = $parts[3]
        if ($lookup.ContainsKey($key)) {
            # concatenate B line + matching A line
            $writer.WriteLine("$bLine$lookup[$key]")
            $total++
        }
    }
}
$sr.Close()
$writer.Close()

Write-Host "`nDONE."
Write-Host "File B lines processed: $linesB"
Write-Host "Total matches written to C.txt: $total"

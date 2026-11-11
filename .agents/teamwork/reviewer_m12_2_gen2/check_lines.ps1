$files = Get-ChildItem -Recurse -Filter *.dart lib, test
$countOver = 0
foreach ($f in $files) {
    $c = (Get-Content $f.FullName | Measure-Object -Line).Lines
    if ($c -ge 200) {
        Write-Output "OVER 200: $($f.FullName) : $c lines"
        $countOver++
    }
}
Write-Output "Total files >= 200 lines: $countOver"

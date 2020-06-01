# ~/WindowsPowerShell
Set-PSReadlineOption -EditMode vi
function prompt {
    Write-Host -ForegroundColor Green (Get-Location).Path.Replace($HOME, "~")
    Write-Host -nonewline -ForegroundColor Gray "λ" 
    " "
}
function ycd {
    (pwd).PATH | CLIP
}
function cdp {
    Get-Clipboard | cd
}

$Host.PrivateData.DebugBackgroundColor = "Gray"
$Host.PrivateData.ErrorBackgroundColor = "Gray"

$tokenColors = @{
    'Command'   = 'White'
    'Comment'   = 'DarkGreen'
    'Keyword'   = 'Blue'
    'Member'    = 'Cyan'
    'Number'    =  'Yellow'
    'Operator'  = 'Magenta'
    'Parameter' = 'Cyan'
    'String'    = 'Yellow'
    'Type'      = 'Green'
    'Variable'  = 'White'
}

if((Get-Module -Name "PSReadline").Version.Major -gt 1) {
    Set-PSReadLineOption -Colors $tokenColors
} else { foreach ($tokenColor in $tokenColors.GetEnumerator()) {
    Set-PSReadlineOption -TokenKind $tokenColor.Name -ForegroundColor $tokenColor.Value
}}

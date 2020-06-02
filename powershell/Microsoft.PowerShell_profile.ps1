# ~/WindowsPowerShell
Set-PSReadlineOption -BellStyle Visual
Set-PSReadlineOption -EditMode vi
function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
function prompt {
    if( $? ){
        Write-Host -nonewline -ForegroundColor Green "0 "
    } else {
        Write-Host -nonewline -ForegroundColor Red "! "
    }
    Write-Host -nonewline " At "
    Write-Host -nonewline -ForegroundColor Magenta "$(Get-Date -Format %H:%m)"
    Write-Host -nonewline " by "
    Write-Host -nonewline -ForegroundColor Yellow "jaandrle"
    if ( Test-Administrator ){
        Write-Host -nonewline -ForegroundColor DarkRed " (root)"
    }
    Write-Host -nonewline " on "
    if( git rev-parse --is-inside-work-tree 2> $null ){
        $branch="$(git symbolic-ref -q HEAD)".replace("refs/heads/", "")
        Write-Host -nonewline -ForegroundColor Cyan "[$branch] "
    }
    Write-Host -ForegroundColor Cyan (Get-Location).Path.Replace($HOME, '~')
    Write-Host -nonewline -ForegroundColor Gray '>_:' 
    
    ' '
}
Set-PSReadLineOption -ViModeIndicator 2
function ycd {
    (pwd).PATH | CLIP
}
function cdp {
    Get-Clipboard | cd
}
function help_keybindings {
    Get-PSReadLineKeyHandler | more
}

$Host.PrivateData.DebugBackgroundColor = 'Gray'
$Host.PrivateData.ErrorBackgroundColor = 'Gray'

$tokenColors = @{
    'Command'   = 'White'
    'Comment'   = 'DarkGreen'
    'Keyword'   = 'Blue'
    'Member'    = 'Cyan'
    'Number'    = 'Yellow'
    'Operator'  = 'Magenta'
    'Parameter' = 'Cyan'
    'String'    = 'Yellow'
    'Type'      = 'Green'
    'Variable'  = 'White'
}

if((Get-Module -Name 'PSReadline').Version.Major -gt 1) {
    Set-PSReadLineOption -Colors $tokenColors
} else { foreach ($tokenColor in $tokenColors.GetEnumerator()) {
    Set-PSReadlineOption -TokenKind $tokenColor.Name -ForegroundColor $tokenColor.Value
}}

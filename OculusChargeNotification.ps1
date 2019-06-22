Function Send-Pushbullet
{
    ###CREDIT###
    ###https://github.com/dendory/Pushbullet-PowerShell-Module

    <#
    .SYNOPSIS
        Send-Pushbullet can be used with the Pushbullet service to send notifications to your devices.
    .DESCRIPTION
        This function requires an account at Pushbullet. Register at http://pushbullet.com and obtain your API Key from the account settings section.
        With this module you can send messages or links from a remote system to all of your devices.
   
    .EXAMPLE
        Send-Pushbullet -APIKey "XXXXXX" -Title "Hello World" -Message "This is a test of the notification service."
        Send a message to all your devices.
    .EXAMPLE
        Send-Pushbullet -APIKey "XXXXXX" -Title "Here is a link" -Link "http://pushbullet.com" -DeviceIden "XXXXXX"
        Send a link to one of your deivces. Use Get-PushbulletDevices to get a list of Iden codes.
    .EXAMPLE
        Send-Pushbullet -APIKey "XXXXXX" -Title "Hey there" -Message "Are you here?" -ContactEmail "user@example.com"
        Send a message to a remote user.
    #>
    param([Parameter(Mandatory=$True)][string]$APIKey=$(throw "APIKey is mandatory, please provide a value."), [Parameter(Mandatory=$True)][string]$Title=$(throw "Title is mandatory, please provide a value."), [string]$Message="", [string]$Link="", [string]$DeviceIden="", [string]$ContactEmail="")

    if($Link -ne "")
    {
        $Body = @{
            type = "link"
            title = $Title
            body = $Message
            url = $Link
            device_iden = $DeviceIden
            email = $ContactEmail
        }
    }
    else
    {
        $Body = @{
            type = "note"
            title = $Title
            body = $Message
            device_iden = $DeviceIden
            email = $ContactEmail
        }
    }

    $Creds = New-Object System.Management.Automation.PSCredential ($APIKey, (ConvertTo-SecureString $APIKey -AsPlainText -Force))
    Invoke-WebRequest -Uri "https://api.pushbullet.com/v2/pushes" -Credential $Creds -Method Post -Body $Body
}

###Variables###
$adblocation = "FILL ME IN"
$pushbulletkey = "FILL ME IN"

$chargeperect = 95
$sleep = 30
$title = "Quest"
$message = "Charged"
$charged = $false
$port = 5555

cd $adblocation
.\adb.exe disconnect
.\adb.exe kill-server

$ip = ((((.\adb.exe shell ip route) -split('src '))[1]) -replace " ","") + ":$port"
.\adb.exe tcpip $port
Read-Host "Disconnect device and hit enter:"
.\adb.exe connect $ip

while (!($charged)){
Get-Date
[int]$batterylevel = (((.\adb.exe shell dumpsys battery) | Select-String "level:") -split "level: ")[1]
if($batterylevel -ge $chargeperect){
$charged = $true
write-host "Charged"
Send-Pushbullet -APIKey $pushbulletkey -Title "$title" -Message "$message"
}else{
write-host "Needs more charged, current $batterylevel"
}
if(!($charged)){sleep $sleep}
}
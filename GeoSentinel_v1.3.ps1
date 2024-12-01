#Connect to Graph
Connect-MgGraph -Scopes "AuditLog.Read.All" -NoWelcome


$version = "GeoSentinel - Version 1.1 - by PB 30/11/24"
<#ChangeLog
v1.1 - Changed default to be last logs from last 1 hour, if not flags are used, if both -t and -d flags are used [error] msg shows.
#>
$allowedCountries =@("IN","AU","IE","GB","IN","NZ")
#$allowedCountries =@("BR")
$outOfScopeUsers = @("d8f30f13-21d4-42bb-af1e-d2a3b5c0ec2d")
$global:SuccessusersArray = @()
$global:FailedUsersArray = @()
function banner{
param(
[string]$patrolmsg = "",
[string]$color = "Cyan"
)
$art = @"
 
    *
   .                                   $patrolmsg
    <\    *        .       __        /
     \\                 .~~  ~~.    /           .
 .    \\     .         /|~|     |  /  .
       \\             /======\  |           *
      //\\           |>/_\_<_=' |       .         *
  *   ~\  \  .    *  `-`__  \\__|    _
     <<\ \ \    ___    \..'  `--'   / ~-.
    <<\\' )_) .+++++ _ (___.--'| _ /~-.  ~-.
    \_\' /   x||||||| `-._    _.' /~-. ~-.  ``.
     |   |  |X++++++|     \  /   /~-. ~-. ~-./
 .   |   `. .||||||||       []   /~-. ~-. ~-./
     |    |'  ++++++| :::  [] : `-. ~-. ~-.'
     |    ``.       '  :::  []:: _.-:-. ~-/ |
*    (_   /|     _.        []  |GEO|`-'  |
     ||`-'| |_.-' |         |\\/|SENTINEL|  ``.
  .   `.___.-'     `.        ||`'  \~~~/ >.  l

"@
Write-Host $art -ForegroundColor $color
}
function banner2{
param(
[string]$patrolmsg = "",
[string]$color = "Cyan"
)
$art2 = @"
                      ______
                   ,-~   _  ^^~-.,
                 ,^        -,____ ^,        
                /           (____)  |                                          
               ;  .---._    | | || _|       $patrolmsg           
               | |      ~-.,\ | |!/ |     /                                
               ( |    ~<-.,_^\|_7^ ,|    /                                 
               | |      ", 77>   (T/|   /  
               |  \_      )/<,/^\)i(|
               (    ^~-,  |________||
               ^!,_    / /, ,'^~^',!!_,..---.
                \_ "-./ /   (-~^~-))' =,__,..>-,
                  ^-,__/#w,_  '^' /~-,_/^\      )
               /\  ( <_    ^~~--T^ ~=, \  \_,-=~^\
  .-==,    _,=^_,.-"_  ^~*.(_  /_)    \ \,=\      )
 /-~;  \,-~ .-~  _,/ \    ___[8]_      \ T_),--~^^)
   _/   \,,..==~^_,.=,\   _.-~O   ~     \_\_\_,.-=}
 ,{       _,.-<~^\  \ \\      ()  .=~^^~=. \_\_,./
,{ ^T^ _ /  \  \  \  \ \)    [|   \GeoSentinel >
  ^T~ ^ { \  \ _\.-|=-T~\\    () ()\<||>,',  )
   +     \ |=~T  !       Y    [|()  \ ,' ,  /
"@
Write-Host $art2 -ForegroundColor $color
Start-Sleep -Seconds 4
}
function showHelp{
 banner -patrolmsg $version -color Gray
Write-Host $version  -ForegroundColor Gray
Write-Host "Flags:"  -ForegroundColor Gray
Write-Host "-o | -outPath         : Export the data as to a location specified, save the file as .csv"  -ForegroundColor Gray
Write-Host "-d | -days            : Choose how many days ago you want to fetch your logs for suspicious logins attempt"  -ForegroundColor Gray
Write-Host "-t | -time            : Choose how many hours ago you want to fetch your logs for suspicious logins attempt, this option is good for schedule taks (ie:check every hour)"  -ForegroundColor Gray
Write-Host "-f | -failedLogs      : Show All failed logs from users who did not meet the countries criteria on the allowedCountries list"  -ForegroundColor Gray
Write-Host "-s | -successfulLogs  : Show All Successfull logs from users who did not meet the countries criteria on the allowedCountries list"  -ForegroundColor Gray
Write-Host "-h | -help            : Show this help message"  -ForegroundColor Gray 
Write-Host "-v | -verbose         : Show more details on the output"  -ForegroundColor Gray
Write-Host ""
Write-Host "INFO"  -ForegroundColor Gray
Write-Host "By default if no flags are used it will search for successfull suspicious logins over the last day"  -ForegroundColor Gray
Write-Host "Usage"  -ForegroundColor Gray
Write-Host "Show Failed logins from users outside the allowed countries" -ForegroundColor Gray
Write-Host "GeoSentinel -verbose -f`n" -ForegroundColor Yellow
Write-Host "Show Successful logins from users outside the allowed countries" -ForegroundColor Gray
Write-Host "GeoSentinel -s -v`n" -ForegroundColor Yellow
Write-Host "Show Successful logins from users outside the allowed countries over the last 10 days" -ForegroundColor Gray
Write-Host "GeoSentinel -s -v -d 10`n" -ForegroundColor Yellow
Write-Host "Show UNsuccessful logins from users outside the allowed countries over the last 5 hours" -ForegroundColor Gray
Write-Host "GeoSentinel -f -v -t 5`n" -ForegroundColor Yellow
Write-Host "Show and Export Successful logins from users outside the allowed countries over the last 12 hours" -ForegroundColor Gray
Write-Host "GeoSentinel -successfulLog -verbose -time 12 -outPath 'C:\temp\Sussessful_hour.csv'`n" -ForegroundColor Yellow
Write-Host "Show and Export Successful logins from users outside the allowed countries over the last 1 hours" -ForegroundColor Gray
Write-Host "GeoSentinel -s -t 1 -v -o 'C:\temp\Sussessful_hour.csv'"-ForegroundColor Yellow
break
}
function WY($text){
Write-Host $text -NoNewline -ForegroundColor Yellow
}
function WG($text){
Write-Host $text -NoNewline -ForegroundColor Gray
}

#LOGIC FUNCTIONS
function Get-CustomDate {
    param (
        [int]$days = 0,  # Changed to [int] to ensure proper numerical operations
        [datetime]$InputDate = (Get-Date)
    )
    $fromDate = $InputDate.AddDays(-$days)  # Subtract the number of days
    $from = $fromDate.ToUniversalTime().ToString("yyyy-MM-ddT00:00:00Z")
    $to = $InputDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")  # Ensure consistent format for $to
    return @($from, $to)
}
function Get-CustomHour {
    param (
        [int]$hours = 0,  # Changed to [int] to ensure proper numerical operations
        [datetime]$InputDate = (Get-Date)
    )
    $fromTime = $InputDate.AddHours(-$hours)  # Subtract the number of days
    $from = $fromTime.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $to = $InputDate.ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    return @($from, $to)
}

function fetchLoginData{
[CmdletBinding(SupportsShouldProcess=$true)]
param(
[switch]$h = $false,
[switch]$help = $false,
[array]$data = "",
[array]$outArray = ""
)

if($s){$successfulLogs = $s}
if($f){$failedLogs = $f}
if($o){$outPath = $o}
if($t){$time = $t}
if($d){$days = $d}



    forEach($r in $res1){
    $country       = $r.location.countryOrRegion
    $city          = $r.location.city
    $loginMethod   = $r.clientAppUsed 
    $app           = $r.appDisplayName
    $resourceName  = $r.resourceDisplayName
    $isInteractive = $r.isInteractive
        if($isInteractive -eq "TRUE"){$isInteractive = "Interactive sign-in"}else{$isInteractive = "Not interactive sing-in"}
    $ip            = $r.ipAddress
    $user          = $r.userDisplayName
    $email         = $r.userPrincipalName
    $device        = $r.deviceDetail.displayName
    $timeLogin     = $r.createdDateTime
    $failureCode   = $r.status.errorCode
    $failureDetails = $r.status.additionalDetails
    $failureReason = $r.status.failureReason
        if($failureCode -eq 0){$signinStatus = "SUCCESSFUL"}else{$signinStatus = "FAILED"}

        Write-Debug $email
        $record = New-Object -TypeName PSObject -Property @{
        Email           = $email
        Device          = $device
        Country         = $country
        City            = $city
        IP              = $ip
        Time            = $timeLogin 
        LoginMethod     = $loginMethod
        App             = $app
        AppResourceName = $resourceName
        IsInteractive   = $isInteractive
        SignInStatus    = $signinStatus
        SignInCode      = $failureCode
        FailureDetails  = $failureDetails
        FailureReason   = $failureReason

        }


#-----DEBUG AREA
 #Write-Host "--------------- Value for Successful is $successfulLogs" -ForegroundColor Magenta
 #Write-Host "--------------- Value for failedLogs is $failedLogs" -ForegroundColor Magenta
 #.................

 if($successfulLogs -eq $true){

         if($country -notin $allowedCountries -and $failureCode -eq 0 -and $email -notin $outOfScopeUsers){
            Write-Host "$signinStatus to sign-in" -ForegroundColor Red
            WG "[$timeLogin] Suspicious login for "; WY $email;WG " from: "; WY "$country $city" ;WY " [$ip] ";  WG "App:";  WY " $app`n" -ForegroundColor Yellow 
            Write-Verbose "$loginMethod  using $app ($resourceName) - Interactive login : $isInteractive"
            Write-Verbose "Device : $device"
            Write-Verbose "Reason: $failureDetails"
            Write-Verbose "Failure Code: $failureCode"
            Write-Host "`n-------------------"
            $global:SuccessusersArray += $record
            $success = $global:SuccessusersArray.Email | Sort-Object -Unique | Measure-Object
            $successCount = $success.Count
                }
            }
 elseif($failedLogs -eq $true){
            
         if($country -notin $allowedCountries -and $failureCode -ne 0 -and $email -notin $outOfScopeUsers){
            Write-Host "$signinStatus to sign-in" -ForegroundColor Magenta
            WG "[$timeLogin] Suspicious login for "; WY $email;WG " from: "; WY "$country $city" ;WY " [$ip] ";  WG "App:";  WY " $app`n" -ForegroundColor Yellow 
            Write-Verbose "$loginMethod  using $app ($resourceName) - Interactive login : $isInteractive"
            Write-Verbose "Device : $device"
            Write-Verbose "Reason: $failureDetails"
            Write-Verbose "Failure Code: $failureCode"
            Write-Host "`n-------------------"
            $global:FailedUsersArray += $record
            $failed = $global:FailedUsersArray.Email | Sort-Object -Unique | Measure-Object
            $failedCount = $failed.Count 
                }
            }
 else{
            Write-Host "Exception fell under default..."
            Write-Host "$signinStatus to  sign-in" -ForegroundColor Red
            WG "[$timeLogin] Suspicious login for "; WY $email;WG " from: "; WY "$country $city" ;WY " [$ip] ";  WG "App:";  WY " $app`n" -ForegroundColor Yellow 
            Write-Verbose "$loginMethod  using $app ($resourceName) - Interactive login : $isInteractive"
            Write-Verbose "Device : $device"
            Write-Verbose "Reason: $failureDetails"
            Write-Verbose "Failure Code: $failureCode"
            Write-Host "`n-------------------"
            $global:SuccessusersArray += $record
            $success = $global:SuccessusersArray.Email | Sort-Object -Unique | Measure-Object
            $successCount = $success.Count
             }
      } #cls --- forEach

} #cls fetchLoginData

#---- MAIN FUNCTION --------

function GeoSentinel{
[CmdletBinding(SupportsShouldProcess=$true)]
param(
[switch]$f = $false,
[switch]$failedLogs = $false,
[switch]$s = $false,
[switch]$successfulLogs = $false,
[switch]$h = $false,
[switch]$help = $false,
[array]$data = "",
[int]$d = "",
[int]$days = "",
[int]$t = "",
[int]$time = 1,
[string]$o = "",
[string]$outPath = ""
)
#If user calls GeoSentinel with -h or -help 
if($h -eq $true -or $help -eq $true){showHelp}
if($s){$successfulLogs = $s}
if($f){$failedLogs = $f}
if($o){$outPath = $o}
if($t){$time = $t}
if($d){$days = $d}


#Check if the Days or Hours flag was used -------------------------
if(($t -gt 1 -or $time -gt 1)-and ($d -gt 0 -or $days -gt 0)){banner -patrolmsg "YOU CANNOT USE DAYS AND TIME FLAG AT THE SAME TIME SOLDIER!!! -____-''" -color Red;break}
if(($successfulLogs -eq $true -or $s -eq $true) -and ($failedLogs -eq $true -or $f -eq $true)){banner -patrolmsg "YOU CANNOT SEARCH BOTH SUCCESSFUL AND FAILED `n                                       LOGS AT THE SAME TIME SOLDIER!   -____-''" -color Red;break}



#If no flags are use than use default flag of time, with default value
if($t){$time = $t}
elseif($time){}
$timeHour = Get-CustomHour -hours $time
$from = $timeHour[0] #from valueThis will get the current date but will decreases based on the input value for the hour, this is useful if running the function hourly    $to = $timeHour[1]   #to value will be the current time the function is run
$to = $timeHour[1]

if($d -ne "" -or $days -ne ""){

    if($d -gt 0){$days =$d}
    elseif($days){}
    $dates = Get-CustomDate -days $days
    $from  = $dates[0]
    $to   = $dates[1]
    Write-Debug "From: $from"
    Write-Debug "To:   $to"

}

########## DISPLAY BANNERS WITH INFORMATION ON SEARCH HERE ####################
#Write-Host "------------------" -ForegroundColor Magenta
#Write-Host "value of `$successfulLogs $successfulLogs" -ForegroundColor Magenta
#Write-Host "value of `$failedLogs $failedLogs" -ForegroundColor Magenta
Start-Sleep -Milliseconds 100

if($days -ne "" -and $successfulLogs -eq $true){
    if($days -eq 1){banner2 -patrolmsg "Fetching SUCCESSFUL Sign-in Logs From $days day ago ($from) untill NOW!!!($to)`n                                             From Countries not in the Allowed List $allowedCountries" -color Yellow }
    else{banner2 -patrolmsg "Fetching SUCCESSFUL Sign-in Logs From $days days ago ($from) untill NOW!!!($to)`n                                             From Countries not in the Allowed List $allowedCountries"  -color Yellow}
    
}
elseif($days -ne "" -and $failedLogs -eq $true){
    if($days -eq 1){banner -patrolmsg "Fetching FAILED Sign-in Logs From $days day ago ($from) untill NOW!!!($to)`n                                             From Countries not in the Allowed List $allowedCountries" -color Gray}
    else{banner -patrolmsg "Fetching FAILED Sign-in Logs From $days days ago ($from) untill NOW!!!($to)`n                                             From Countries not in the Allowed List $allowedCountries" -color Gray}
    }

elseif($time -ne "" -and $successfulLogs -eq $true){
    if($time -eq 1)
    {    banner2 -patrolmsg "Fetching SUCCESSFUL Sign-in Logs From $time hour ago...`n                                             From Countries not in the Allowed List $allowedCountries"  -color Yellow}else{banner2 -patrolmsg "Fetching SUCCESFULL Sign-in Logs From $time hours ago...`n                                             From Countries not in the Allowed List $allowedCountries"  -color Yellow} 
   #uri https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge ge yyyy-MM-ddT00:00:00Z and createdDateTime le yyyy-MM-ddT00:00:00Z
$uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge $from and createdDateTime le $to"
}
elseif($time -ne "" -and $failedLogs -eq $true){
    if($time -eq 1)
    {    banner -patrolmsg "Fetching FAILED Sign-in Logs From $time hour ago...`n                                             From Countries not in the Allowed List $allowedCountries" -color Gray }else{banner -patrolmsg "Fetching FAILED Sign-in Logs From $time hours ago...`n                                             From Countries not in the Allowed List $allowedCountries" -color Gray} 
   #uri https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge ge yyyy-MM-ddT00:00:00Z and createdDateTime le yyyy-MM-ddT00:00:00Z
$uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge $from and createdDateTime le $to"
}
else{
Write-Host "[INFO] - Searching using default settings, Succesful logs" -ForegroundColor Gray
 if($time -eq 1)
    {    banner2 -patrolmsg "Fetching SUCCESFULL Sign-in Logs From $time hour ago...`n                                             From Countries not in the Allowed List $allowedCountries"  -color Yellow }else{banner2 -patrolmsg "Fetching SUCCESFULL Sign-in Logs From $time hours ago...`n                                             From Countries not in the Allowed List $allowedCountries"  -color Yellow} 
   #uri https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge ge yyyy-MM-ddT00:00:00Z and createdDateTime le yyyy-MM-ddT00:00:00Z
$uri = "https://graph.microsoft.com/v1.0/auditLogs/signIns?`$filter=createdDateTime ge $from and createdDateTime le $to"
}
########## DISPLAY BANNERS END HERE ####################
########################################################
#Write-Host $uri -ForegroundColor Magenta
#sleep -Seconds 10 # debug sleep here -------------------------------------------< DEBUG HERE >


$res = Invoke-MgGraphRequest -Method Get $uri
sleep 12
$res1 = $res.value
$nextLink = $res.'@odata.nextLink'

####FIRST PASSS

fetchLoginData -data $res1


####NEXT PAGES

if($nextLink){
    While ($nextLink -ne "" -or $nextLink -ne $null){
        $res = Invoke-MgGraphRequest -Method Get $nextLink
        $res1 = $res.value
        $nextLink = $res.'@odata.nextLink'
        Write-Host "[INFO] - Fetching next page...`n" -foregroundColor Gray #-                                                                   ------debug
        #-------logic goes here--------#

        fetchLoginData -data $res1
        

        #-------logic goes here--------#


        
        if(!($nextLink)){break} #if there isnt a next page break out of WhileLoop
    }
}

if($outPath -ne ""){
    Try{
       if($failedLogs){
          Write-Host "[INFO] - Exporting Successful Logs from Countries outside the Allowed List" -ForegroundColor Gray
          $failedLogsFile = "Failed_" + $outPath
          $global:FailedUsersArray | Export-Csv $failedLogsFile -NoTypeInformation   
            }
       if($successfulLogs){
          Write-Host "[INFO] - Exporting Successful Logs from Countries outside the Allowed List" -ForegroundColor Gray
          $successLogsFile = "Success_" + $outPath
          $global:SuccessusersArray | Export-Csv $successLogsFile -NoTypeInformation
        }

    }
    Catch{Write-Host "[ERROR] - Could not export results to $outPath" -ForegroundColor Red}
    } #cls flag if -o

if($successfulLogs){
    $userResult = $global:SuccessusersArray.Email | sort -Unique |Measure-Object
}
else{
    $userResult = $global:FailedUsersArray.Email | sort -Unique |Measure-Object}
$count = $userResult.Count

if($count -eq 1){banner -patrolmsg "FETCHED COMPLETED!`n                                      $count USER WITH SUSPICIOUS LOGIN!" -color Cyan}
else{banner -patrolmsg "FETCHED COMPLETED!`n                                                  $count USERS WITH SUSPICIOUS LOGIN!!" -color Cyan}

}

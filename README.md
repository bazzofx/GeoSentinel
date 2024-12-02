# GeoSentinel PowerShell Script

**GeoSentinel** is a PowerShell module designed to enhance the security of your Azure account by detecting and flagging suspicious sign-in activities. It identifies both successful logins and failed sign-in attempts originating from countries not included in your predefined `$allowedCountries` list. This approach helps you monitor unauthorized access and focus only on the logs you care about, helping you redue noise and speed up defenses. 
This script is ideal for configuring as a scheduled task to run at regular intervals (e.g: every hour). It allows you to receive timely notifications whenever a suspicious successful sign-in event is detected, enabling quick responses to potential security threats.
* * *

## Features

- **Filter Logs by Time and Date**:

    - Specify a custom time range in hours or days.
- **Analyze Sign-In Data**:

    - Classifies logins as `SUCCESSFUL` or `FAILED`.
    - Highlights logins from untrusted countries.
    - Differentiates between interactive and non-interactive sign-ins.
- **Customizable Parameters**:
- 
    - Search successful or failed logins with appropriate flags.
    - Specify output file paths to export results.
- **Suspicious Login Detection**:
- 
    - Detects and highlights logins from unapproved countries or devices.
    - Provides detailed login metadata for further analysis.

* * *

## Prerequisites

- **Microsoft Graph PowerShell SDK**: Required to interact with the Microsoft Graph API.
- **PowerShell**: Version 5.1 or later is recommended.

* * *

## Installation

1. Install the Microsoft Graph PowerShell SDK:

       Install-Module Microsoft.Graph -Scope CurrentUser
2. Clone or download the script file to your system.

        import-module .\GeoSentinel.ps1
* * *

## Usage

### Running the Script

Load the script into your PowerShell session:

    import-module .\Module\GeoSentinel.psm1

### Parameters

| Parameter | Type | Description |
| --- | --- | --- |
| `-h`, `-help`           | Switch | Displays help information. |
| `-v`, `-verbose`        | Switch | Show more details on the output
| `-s`, `-successfulLogs` | Switch | Fetches only successful login attempts. |
| `-f`, `-failedLogs`     | Switch | Fetches only failed login attempts. |
| `-t`, `-time`           | Integer | Specify the time range in hours (default: 1). |
| `-d`, `-days`           | Integer | Specify the time range in days. |
| `-o`, `-outPath`        | String | File path for exporting logs. |

* * *

## Examples

### Default Catch the Successful sign in from the last 1 hour
    GeoSentinel

### Show Successful logins from users outside the allowed countries

    GeoSentinel -s -v

### Show Successful logins from users outside the allowed countries over the last 10 days

    GeoSentinel -s -v -d 10

### Show Unsuccessful logins from users outside the allowed countries over the last 5 hours

    GeoSentinel -f -v -t 5

### Show and Export Successful logins from users outside the allowed countries over the last 12 hours

    GeoSentinel -successfulLog -verbose -time 12 -outPath 'C:\temp\Sussessful_hour.csv"
    

### Show and Export Successful logins from users outside the allowed countries over the last 1 hours
    GeoSentinel -s -t 1 -v -o 'C:\temp\Sussessful_hour.csv
* * *

## Output

- **Console Output**: Summary and detailed insights on suspicious logins.
- **CSV Export**: Includes metadata such as:
    - `Email`
    - `Device`
    - `Country`
    - `IP Address`
    - `Sign-In Status`

* * *

## Known Issues and Limitations

1. The script relies on accurate location and device data from Microsoft Graph API.
2. Conflicting flags (e.g., `-s` and `-f` together) are not allowed.
3. Internet connectivity is required for API interactions.

* * *

## Troubleshooting

- **Error**: `Could not export results to <path>`  
**Solution**: Verify the output directory exists and has write permissions.
- **Error**: `Microsoft.Graph module not found`  
**Solution**: Install the required module with:

        powershellCopy codeInstall-Module Microsoft.Graph

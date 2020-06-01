function Update-ThumbnailPhotoFromExo {
    <#
    .SYNOPSIS
        This CMDLET Updates thumbnailPhoto property on AD from EXO
    .DESCRIPTION
        This CMDLET is used to perform a Pull Request From EXO (Exchange Online) and update thumbnailPhoto property of the users on Active Directory using the pictures of users in exchange online
    .EXAMPLE
        --------------------------------------------------------------------------------------
        Update-ThumbnailPhotoFromExo 
        Update-ThumbnailPhotoFromExo -First 0 -Last 20
        Update-ThumbnailPhotoFromExo -FN 0 -LN 20
        Update-ThumbnailPhotoFromExo -First 0
        Update-ThumbnailPhotoFromExo -Last 20
        --------------------------------------------------------------------------------------
    .INPUTS
        None
    .OUTPUTS
        Logs are created on Desktop file location of server where the script was ran
    .NOTES
        FUTURE MODS LISTED BELOW
        1. Error handling for ranges entered if First number is greater than Last number 
    #>

    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $false,
            HelpMessage = "Please Enter the first number where upload will start from !")]
        [Alias("FN")]
        [int32]
        $First,

        [Parameter(Mandatory = $false,
            HelpMessage = "Please Enter the last number where upload will stop at !")]
        [Alias("LN")]
        [int32]
        $Last
    )
    
    #log path
    $LogPath = $Home + "\Desktop\Update-ThumbnailPhotoFromExo"

    #start log
    Start-Transcript -OutputDirectory $LogPath

    #Get all users mailboxes
    $Mailboxes = Get-Mailbox -ResultSize Unlimited 

    #Set Variable for Total Mailbox in Organisation
    $TotalNumber = $Mailboxes.Count

    $i = 0

    if (-Not $First) {
        $FirstValue = 0
    }
    else {
        $FirstValue = $First
    }

    if (-Not $Last) {
        $LastValue = $TotalNumber
    }
    else {
        $LastValue = $Last
    }

    #echo number of mailboxes in the organisation 
    Write-Host "The Total Number of Mailboxes in the Organisation is " $TotalNumber -ForegroundColor yellow

    #echo values of the range of mailboxes that upload is been done for
    Write-Host "Starting Upload for Mailboxes From the ranges of " $FirstValue "to " $LastValue -ForegroundColor white

    #Region WorkingLoop
    Foreach ($Mailbox in $Mailboxes) {
        $i++
        if (($i -ge $FirstValue) -and ($i -le $LastValue)) {
            
            #echo number count of mailbox
            Write-Host "starting for " $i  

            #Set Variable for PrimarySmtpAddress
            $PrimaryAddress = $Mailbox.UserPrincipalName

            #Get picture data from EXO
            $Thumbnail = Get-UserPhoto -Identity $PrimaryAddress -ErrorAction SilentlyContinue | Select-Object PictureData -ExpandProperty PictureData

            #start sleep cmdlet
            Start-Sleep -m 0.5;

            #check block thumbnail 1
            if (-Not $Thumbnail) {

                #echo info 1 for picture data 
                Write-Host "No picture data found for " $PrimaryAddress -ForegroundColor Red

                #check block thumbnail 2
            }
            elseif ($Thumbnail) {

                #echo info 1 for picture data
                Write-Host "Picture data found for " $PrimaryAddress

                #set byte format for picture data
                $FinalThumbnail = [byte[]]($Thumbnail)

                #Get Aduser for check
                $Aduser = Get-ADUser -Filter { UserPrincipalName -like $PrimaryAddress } -ErrorAction SilentlyContinue

                #check block Adusers 1
                if (-Not $Aduser) {

                    #echo info 1 for Aduser
                    Write-Host $PrimaryAddress " Not found on AD" -ForegroundColor Red

                    #check block Adusers 2
                }
                elseif ($Aduser) {
                
                    #echo info for Upload
                    Write-Host "Uploading ThumbnailPhoto for " $PrimaryAddress -ForegroundColor yellow

                    #Set thumbnailPhoto for found User
                    Get-ADUser -Filter { UserPrincipalName -like $PrimaryAddress } | Set-ADUser -Replace @{thumbnailPhoto = $FinalThumbnail }

                    #echo info of success
                    Write-Host "Upload Successful" -ForegroundColor Green
                }
            }
        }
    }
    #EndRegion WorkingLoop

    #stop log
    Stop-Transcript
}
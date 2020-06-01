function Update-ThumbnailPhotoFromExo () {
    #log path
    $LogPath = $Home + "\Desktop\Update-ThumbnailPhotoFromExo.txt"

    #start log
    Start-Transcript -Path $LogPath

    #Get all users mailboxes
    $Mailboxes = Get-Mailbox -ResultSize Unlimited 

    Foreach ($Mailbox in $Mailboxes) {

        #Set Variable for PrimarySmtpAddress
        $PrimaryAddress = $Mailbox.UserPrincipalName

        #Get picture data from EXO
        $Thumbnail = Get-UserPhoto -Identity $PrimaryAddress -ErrorAction SilentlyContinue | Select-Object PictureData -ExpandProperty PictureData

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
    Stop-Transcript
}
#﻿ Connect to Exchange Online
Connect-ExchangeOnline

# Get all user mailboxes
$Users = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox
# Get all shared mailboxes
$Shares = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails SharedMailbox
# Get all room mailboxes
$Rooms = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails RoomMailbox
# Get all equipment mailboxes
$Equipments = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails EquipmentMailbox


# Permissions
$Permission = "Reviewer"

# Calendar name languages
$FolderCalendars = @("Calendar", "Kalender")

# Loop through each UserMailbox
foreach ($User in $Users) {

    # Get calendar in every user mailbox
    $CalendarsUsers = (Get-MailboxFolderStatistics $User.Identity -FolderScope Calendar)

        # Loop through each user calendar
        foreach ($CalendarUser in $CalendarsUsers) {
            $CalendarNameUser = $CalendarUser.Name

            # Check if calendar exist
            if ($FolderCalendars -Contains $CalendarNameUser) {
                $CalUser = $User.Identity.ToString() + ":\$CalendarNameUsers"
                $CurrentMailFolderPermissionUser = Get-MailboxFolderPermission -Identity $CalUser -User Default
                
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $CalUser -User Default -AccessRights $Permission -WarningAction:SilentlyContinue ##-WhatIf##
                
                # Write output
                if ($CurrentMailFolderPermissionUser.AccessRights -eq "$Permission") {
                    Write-Host $User.Identity already has the permission $CurrentMailFolderPermissionUser.AccessRights -ForegroundColor Yellow
                }
                else {
                    Write-Host $User.Identity added permissions $Permission -ForegroundColor Green
            }
        }
    }
}

# Loop through each SharedMailbox
foreach ($Share in $Shares) {

    # Get calendar in every SharedMailbox
    $CalendarsShares = (Get-MailboxFolderStatistics $Share.Identity -FolderScope Calendar)

        # Loop through each user calendar
        foreach ($CalendarShare in $CalendarsShares) {
            $CalendarNameShare = $CalendarShare.Name

            # Check if calendar exist
            if ($FolderCalendars -Contains $CalendarNameShare) {
                $CalShare = $Share.Identity.ToString() + ":\$CalendarNameShare"
                $CurrentMailFolderPermissionShare = Get-MailboxFolderPermission -Identity $CalShare -User Default
                
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $CalShare -User Default -AccessRights $Permission -WarningAction:SilentlyContinue ##-WhatIf ##
                
                # Write output
                if ($CurrentMailFolderPermissionShare.AccessRights -eq "$Permission") {
                    Write-Host $Share.Identity already has the permission $CurrentMailFolderPermissionShare.AccessRights -ForegroundColor Yellow
                }
                else {
                    Write-Host $Share.Identity added permissions $Permission -ForegroundColor Green
            }
        }
    }
}

# Loop through each RoomMailbox
foreach ($Room in $Rooms) {

    # Get calendar in every RoomMailbox
    $CalendarsRooms = (Get-MailboxFolderStatistics $Room.Identity -FolderScope Calendar)

        # Loop through each user calendar
        foreach ($CalendarRoom in $CalendarsRooms) {
            $CalendarNameRoom = $CalendarRoom.Name

            # Check if calendar exist
            if ($FolderCalendars -Contains $CalendarNameRoom) {
                $CalRoom = $Room.Identity.ToString() + ":\$CalendarNameRoom"
                $CurrentMailFolderPermissionRoom = Get-MailboxFolderPermission -Identity $CalRoom -User Default
                
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $CalRoom -User Default -AccessRights $Permission -WarningAction:SilentlyContinue ##-WhatIf ##
                
                # Write output
                if ($CurrentMailFolderPermissionRoom.AccessRights -eq "$Permission") {
                    Write-Host $Room.Identity already has the permission $CurrentMailFolderPermissionRoom.AccessRights -ForegroundColor Yellow
                }
                else {
                    Write-Host $Room.Identity added permissions $Permission -ForegroundColor Green
            }
        }
    }
}

# Loop through each EquipmentMailbox
foreach ($Equipment in $Equipments) {

    # Get calendar in every EquipmentMailbox
    $CalendarsEqs = (Get-MailboxFolderStatistics $Equipment.Identity -FolderScope Calendar)

        # Loop through each user calendar
        foreach ($CalendarEq in $CalendarsEqs) {
            $CalendarNameEq = $CalendarEq.Name

            # Check if calendar exist
            if ($FolderCalendars -Contains $CalendarNameEq) {
                $CalEq = $Equipment.Identity.ToString() + ":\$CalendarNameEq"
                $CurrentMailFolderPermissionEq = Get-MailboxFolderPermission -Identity $CalEq -User Default
                
                # Set calendar permission / Remove -WhatIf parameter after testing
                Set-MailboxFolderPermission -Identity $CalEq -User Default -AccessRights $Permission -WarningAction:SilentlyContinue ##-WhatIf ##
                
                # Write output
                if ($CurrentMailFolderPermissionEq.AccessRights -eq "$Permission") {
                    Write-Host $Equipment.Identity already has the permission $CurrentMailFolderPermissionEq.AccessRights -ForegroundColor Yellow
                }
                else {
                    Write-Host $Equipment.Identity added permissions $Permission -ForegroundColor Green
            }
        }
    }
}
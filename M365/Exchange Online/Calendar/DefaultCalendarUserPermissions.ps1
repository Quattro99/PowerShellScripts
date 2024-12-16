<#
.SYNOPSIS
   This script sets default calendar permissions for all user, shared, room, and equipment mailboxes in an Exchange Online environment. The permissions are applied to specific calendar folders.

.DESCRIPTION
   The script connects to Exchange Online, retrieves all user, shared, room, and equipment mailboxes, and iterates through their calendar folders. It checks if the calendar folder named "Calendar" (or "Kalender" in other languages) exists in each mailbox. 
   If it exists, it updates the calendar permissions for the "Default" user to a specified permission level (default is set to "Reviewer"). 
   The script provides outputs indicating whether the permissions were already set or newly applied.

.INPUTS
   - None directly from the user. All mailbox information is fetched from Exchange Online.
   - Ensure the user running the script has the necessary permissions in Exchange Online.

.OUTPUTS
   - Outputs the status of calendar permission changes for each mailbox processed, indicating if permissions were updated or already set.

.NOTES
   ===========================================================================
   Created on:    16.12.2024
   Created by:    Michele Blum
   Filename:      DefaultCalendarUserPermissions.ps1
   ===========================================================================
.COMPONENT
   Exchange Online Management

.ROLE
   Exchange Administrator

.FUNCTIONALITY
   This script automates the management of calendar permissions across multiple types of mailboxes in Exchange Online, ensuring that default calendar access rights are uniformly applied.
#>

# Connect to Exchange Online
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
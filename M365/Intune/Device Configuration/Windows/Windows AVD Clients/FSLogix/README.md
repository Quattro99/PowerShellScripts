# FSLogix Configuration Profile and Redirection Exclusions for AVD

This README provides a comprehensive description of the FSLogix Configuration Profile and the corresponding `Redirections.xml` file, designed to optimize profile management in a Windows AVD environment. The configuration aims to enhance the performance and efficiency of user profiles by excluding specific folders and setting various parameters.

## FSLogix Configuration Profile

### Profile Details

-   **Name**: CONF-PRD-WIN-M-SC-AVD-FSLogix
-   **Version**: 1.0.0
-   **Description**: Configuration for FSLogix profiles on AVD hosts ensuring optimal profile performance and folder redirection.
-   **Created By**: Michele Blum
-   **Creation Date**: 27.03.2025
-   **Platform**: Windows 11
-   **Technologies Used**: Microsoft MDM (Mobile Device Management aka. Intune)

### Settings Overview

The configuration contains 14 settings that control various aspects of FSLogix profile management. Below is a brief description of each setting:

1. **Device Guard LSA CFG Flags**: Configuration setting for LSA flags.
2. **Profiles Access Network as Computer**: Controls how profiles access the network.
3. **Profiles Container and Directory Naming**: Manages directory naming for profiles.
4. **Profiles Volume Type**: Configures the type of volume used by profiles (VHD/VHDX).
5. **Delete Local Profile When VHD Applies**: Deletes the local profile if the virtual hard drive (VHD) is applied.
6. **Profiles Enabled**: Enables or disables profile management.
7. **Profiles Locked Retry Count**: Sets the number of retry attempts when the profile is locked.
8. **Profiles Locked Retry Interval**: Defines the interval in seconds between retries when the profile is locked.
9. **Profiles Profile Type**: Specifies the type of profiles.
10. **Profiles Reattach Count**: Number of times a profile can reattach.
11. **Profiles Reattach Interval**: The time interval for reattachments.
12. **Profiles Redirection XML Source Folder**: Specifies the source folder for redirection XML configuration.
13. **Profiles Size in MBs**: Sets the maximum allowed size for profiles.
14. **Profiles VHD Locations**: Configures the location of the virtual hard disks for profiles.


## Redirections.xml for AVD hosts

### Overview

This XML file specifies the folders that should be excluded from profile folder redirection. Proper exclusions help to manage space better and enhance application performance by preventing unnecessary data from being redirected.

### Key Features

-   **Exclusions**: The XML lists specific folders that should not be included in the profile redirection, especially for common applications such as:

    -   **Microsoft Teams**: Excludes data related to Teams applications to prevent bloat.
    -   **Web Browsers**: Excludes cache and other data from Google Chrome, Microsoft Edge, and Brave Browser to optimize space.
    -   **System/Other Folders**: Excludes various system and temporary folders that do not need to be redirected.

-   **Includes**: The XML also allows for specific directories to be included in the profile management process, ensuring that certain important data, like Java security settings, is retained.

### Example Exclusions

Here are some example exclusions specified in the XML:

-   Microsoft Teams cache and logs to enhance performance.
-   Browser cache for Google Chrome and Microsoft Edge, which reduces unnecessary data storage.
-   Various temporary and system folders that do not require backup.

### Example Includes

-   Security settings for Java, ensuring that necessary configurations are retained for application functionality.

### References

For more details on folder redirection and best practices, refer to:

-   [Microsoft Documentation on FSLogix Redirections XML](https://learn.microsoft.com/fslogix/tutorial-redirections-xml)
-   [FSLogix GitHub Redirections Example](https://github.com/JamesKindon/Citrix/blob/master/FSLogix/redirections.xml)
-   [Optimizing FSLogix Profile Containers](https://blog.andreas-schreiner.de/2023/02/14/fslogix-profile-container-content-optimierung/)
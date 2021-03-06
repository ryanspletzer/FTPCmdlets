@{
    RootModule = 'FTPCmdlets.psm1'
    ModuleVersion = '0.1.0'
    GUID = '5730d124-f136-44b8-902b-a533cac43880'
    Author = 'Ryan Spletzer'
    Copyright = '(c) 2016 Ryan Spletzer.'
    Description = 'A PowerShell Module for FTP Cmdlets'
    PowerShellVersion = '5.0'
    FormatsToProcess = @('FTPCmdlets.Format.ps1xml')
    FunctionsToExport = @(
        'Copy-FTPItem'
    )
    CmdletsToExport = @()
    PrivateData = @{
        PSData = @{  # Private data to pass to the module specified in RootModule/ModuleToProcess
            Tags = @('FTP','PowerShell','Cmdlets','File Transfer Protocol')
            LicenseUri = 'https://github.com/ryanspletzer/FTPCmdlets/blob/dev/LICENSE'
            ProjectUri = 'https://github.com/ryanspletzer/FTPCmdlets'
        } # End of PSData hashtable
    } # End of PrivateData hashtable
}

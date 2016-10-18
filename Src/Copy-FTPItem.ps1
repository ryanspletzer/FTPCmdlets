function Copy-FTPItem {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.Net.Security.AuthenticationLevel]
        $AuthenticationLevel = [System.Net.Security.AuthenticationLevel]::None,

        [Parameter()]
        [PSCredential]
        [Alias("Credentials")]
        $Credential,

        [Parameter()]
        [System.Net.Cache.RequestCacheLevel]
        [Alias("DefaultCachePolicy")]
        $RequestCacheLevel = [System.Net.Cache.RequestCacheLevel]::Default,

        [Parameter()]
        [Bool]
        $EnableSsl = $true,

        #[Parameter()]
        #[Bool]
        #$KeepAlive = $true,

        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ($_ -notlike "ftp://*") {
                Test-Path -Path $_
            } else {
                Test-Path -Path ($_.TrimStart("ftp://")) -IsValid
            }
        })]
        [String[]]
        $Path,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if ($_ -notlike "ftp://*") {
                Test-Path -Path $_ -IsValid
            } else {
                Test-Path -Path ($_.TrimStart("ftp://")) -IsValid
            }
        })]
        [String]
        $Destination,

        [Parameter(Position=2)]
        [Switch]
        $Recurse,

        [Parameter()]
        [Int32]
        $Timeout = -1,

        [Parameter()]
        [Bool]
        $UseBinary = $true,

        [Parameter()]
        [Bool]
        $UsePassive = $true,

        #[Parameter()]
        #[Int]
        #$BufferSize = 20KB,

        [Parameter(Position=3)]
        [Switch]
        $Force
    )

    begin {
        [System.Net.FtpWebRequest]$ftpWebRequest = $null
        if ((Test-Path -Path $Path -PathType Leaf) -and
            ($Destination -like "ftp://*")) {
            $ftpWebRequest = [System.Net.FtpWebRequest]::Create($Destination)
            $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        }
        if ((Test-Path -Path $Path -PathType Container) -and
            ($Destination -like "ftp://*")) {
            $ftpWebRequest = [System.Net.FtpWebRequest]::Create($Destination)
            $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory  # Might be recursive
        }
        if (($Path -like "ftp://*") -and
            (Test-Path -Path $Destination -IsValid)) {
            $ftpWebRequest = [System.Net.FtpWebRequest]::Create($Path)
            $ftpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile  # Might be recursive
        }
        $ftpWebRequest.AuthenticationLevel = $AuthenticationLevel
        $ftpWebRequest.CachePolicy = New-Object -TypeName System.Net.Cache.RequestCachePolicy -ArgumentList $RequestCacheLevel
        $ftpWebRequest.Credentials = New-Object -TypeName System.Net.NetworkCredential -ArgumentList @($Credential.UserName, $Credential.Password)
        $ftpWebRequest.EnableSsl = $EnableSsl
        $ftpWebRequest.Timeout = $Timeout
    }

    process {
        switch ($ftpWebRequest.Method) {
            ([System.Net.WebRequestMethods+Ftp]::UploadFile) {
                try {
                    $file = [IO.File]::ReadAllBytes((Convert-Path -Path $Path))
                    $ftpWebRequest.ContentLength = $file.Length
                    $requestStream = $ftpWebRequest.GetRequestStream()
                    $requestStream.Write($file, 0, $file.Length)
                    $requestStream.Close()
                    $requestStream.Dispose()

                } catch {
                    Write-Error -Exception $_.Exception -Message $_.Exception.Message
                }
            }
            ([System.Net.WebRequestMethods+Ftp]::MakeDirectory) {
                throw [System.NotImplementedException] "Make Directory not yet implemented for Copy-Item"
            }
            ([System.Net.WebRequestMethods+Ftp]::DownloadFile) {
                throw [System.NotImplementedException] "Downloading files not yet implemented for Copy-Item"
            }
        }
    }
}

Function New-FunctionFromType {
    [cmdletbinding(DefaultParameterSetName='TypeName')]
    param (
        [Parameter(Mandatory)]
        [Alias('FunctionName')]
        [string]$Name,

        [Parameter()]
        [string]$Path,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='TypeName')]
        [String]$TypeName,

        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName='Object')]
        [Object]$InputObject
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'TypeName') {
            $Properties = ($TypeName -as [Type]).GetMembers() | Where-Object { $_.MemberType -in 'Property', 'Field' -and $_.CanWrite }
        }
        else {
            $Properties = $InputObject.GetMembers() | Where-Object { $_.MemberType -in 'Property', 'Field' -and $_.CanWrite }
        }

        $FunctionDefinition = @"
Function $Name {
    [CmdletBinding()]
    param (`n
"@

        foreach ($Property in $Properties) {
            if ($Property.PropertyType.Name -as [Type]) {
                $type = $Property.PropertyType.Name
            }
            else {
                $type = $Property.PropertyType.FullName
            }
            $FunctionDefinition += "        [{0}]`${1},`n`n" -f $type, $Property.Name

        }
        $FunctionDefinition += @"
    )
}
"@

        if ($Path) {
            $FunctionDefinition | Set-Content -Path $Path
        }
        else {
            $FunctionDefinition
        }
    }
}


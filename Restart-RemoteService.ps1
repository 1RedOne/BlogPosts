
Function Restart-RemoteService{
[CmdletBinding()]
Param($ComputerName=$env:COMPUTERNAME)
    DynamicParam {
    
            # Set the dynamic parameters' name
            $ParameterName = 'Service'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Mandatory = $true
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Get-WmiObject Win32_Service -ComputerName $computername | select -ExpandProperty Name
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    begin {
        # Bind the parameter to a friendly variable
        $Service = $PsBoundParameters[$ParameterName]
    }

    process {
      Write-Debug 'ham' 
  ForEach($machine in $computername){
    write-host "Stopping service $service on host $machine..." -NoNewline 
    Get-WmiObject -ClassName Win32_Service -ComputerName $machine | Where Name -eq $service | % StopService | Out-Null
    write-host "[OK]" -ForegroundColor Cyan

    Write-Host "Starting Service $service on host $machine..." -NoNewline
    Get-WmiObject -ClassName Win32_Service -ComputerName $machine | Where Name -eq $service | % StartService | Out-Null
    write-host "[OK]" -ForegroundColor Cyan
    }
    }

}

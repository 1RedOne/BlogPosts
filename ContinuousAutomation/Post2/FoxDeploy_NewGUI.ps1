[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$xamlPath = "$($PSScriptRoot)\$((split-path $PSCommandPath -Leaf ).Split(".")[0]).xaml"
if (-not(Test-Path $xamlPath)){
    throw "Ensure that $xamlPath is present within $PSScriptRoot"
}
$inputXML = Get-Content $xamlPath
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[xml]$XAML = $inputXML
  
$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
    }
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
}
  
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
  
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
  
Get-FormVariables

function loadListView(){
    $global:deviceList = new-object -TypeName System.Collections.ArrayList    
    $devices = import-csv "$PSScriptRoot\devices.csv" | Sort-Object Processed
    ForEach($device in $devices){        
        $global:deviceList.Add($device)
    }
    $WPFdevice_listView.ItemsSource = $global:deviceList
}

function cancelButton(){
    $WPFok.IsEnabled = $false
    $wpfdeviceTextbox.Text = $null 
    $wpflabelCounter.Text="Reset"
    }

$wpfdeviceTextbox.Add_TextChanged({
    if ($wpfdeviceTextbox.Text.Length -le 5){
        return 
    }
    $WPFok.IsEnabled = $true 
    $deviceTextbox = $wpfdeviceTextbox.Text.Split(',').Split([System.Environment]::NewLine).Where({$_.Length -ge 3})
    $count = $deviceTextbox.Count
    $wpflabelCounter.Text=$count
})

$WPFCancel.Add_Click({
    cancelButton    
})


$WPFok.Add_Click({
    $deviceTextbox = $wpfdeviceTextbox.Text.Split(',').Split([System.Environment]::NewLine).Where({$_.Length -ge 3})    
    ForEach($item in $deviceTextbox){
        $global:deviceList.Add([pscustomObject]@{HostName=$item})
    }    
    set-content "$PSScriptRoot\devices.csv" -Value $($deviceList | ConvertTo-csv -NoTypeInformation)
    cancelButton
    loadListView
})

loadListView
$Form.ShowDialog() | out-null
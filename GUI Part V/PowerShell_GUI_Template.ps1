$Global:syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)

# Load WPF assembly if necessary
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')

$psCmd = [PowerShell]::Create().AddScript({
    [xml]$xaml = @"
   <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="MainWindow" Height="350" Width="525">
    <Grid Background="#FF3A3A3A">
        <TextBlock x:Name="textBlock" HorizontalAlignment="Left" Height="62" Margin="10,23,0,0" TextWrapping="Wrap" Text="Use this template to easily drop a working progress bar into your UI" UseLayoutRounding="True" VerticalAlignment="Top" Width="337" Foreground="White" FontSize="18.667"/>
        <Button x:Name="button" Content="Start" HorizontalAlignment="Left" Height="62" Margin="322,23,0,0" VerticalAlignment="Top" Width="114"/>
        <GroupBox x:Name="Results" Header="Results" HorizontalAlignment="Left" Height="96" Margin="220,111,0,0" VerticalAlignment="Top" Width="216">
            <TextBox x:Name="textBox" TextWrapping="Wrap" Text="TextBox" FontFamily="Consolas" ScrollViewer.VerticalScrollBarVisibility="Auto" IsReadOnly="True"/>
        </GroupBox>
        <ProgressBar x:Name = "ProgressBar" Height = "20" Width = "300" HorizontalAlignment="Left" VerticalAlignment="Top" Margin = "36,244,0,0"/>
        <TextBlock x:Name="StarttextBlock" HorizontalAlignment="Left" Height="23" Margin="36,108,0,0" TextWrapping="Wrap" Text="Starting..." VerticalAlignment="Top" Width="111"/>
        <TextBlock x:Name="ProcesstextBlock" HorizontalAlignment="Left" Height="23" Margin="36,136,0,0" TextWrapping="Wrap" Text="Processing..." VerticalAlignment="Top" Width="111"/>
        <TextBlock x:Name="FiltertextBlock" HorizontalAlignment="Left" Height="23" Margin="36,164,0,0" TextWrapping="Wrap" Text="Filtering..." VerticalAlignment="Top" Width="111"/>
        <TextBlock x:Name="DonetextBlock" HorizontalAlignment="Left" Height="23" Margin="36,187,0,0" TextWrapping="Wrap" Text="Done..." VerticalAlignment="Top" Width="111"/>
        <Image x:Name="checkimage1" HorizontalAlignment="Left" Height="20" Margin="10,111,0,0" VerticalAlignment="Top" Width="21"/>
        <Image x:Name="checkimage2" HorizontalAlignment="Left" Height="20" Margin="10,136,0,0" VerticalAlignment="Top" Width="21"/>
        <Image x:Name="checkimage3" HorizontalAlignment="Left" Height="20" Margin="10,164,0,0" VerticalAlignment="Top" Width="21"/>
        <Image x:Name="checkimage4" HorizontalAlignment="Left" Height="20" Margin="10,187,0,0" VerticalAlignment="Top" Width="21"/>
       
    </Grid>
</Window>
"@


    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

    [xml]$XAML = $xaml
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
        #Find all of the form types and add them as members to the synchash
        $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name) )

    }

    $Script:JobCleanup = [hashtable]::Synchronized(@{})
    $Script:Jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))

    #region Background runspace to clean up jobs
    $jobCleanup.Flag = $True
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"          
    $newRunspace.Open()        
    $newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
    $newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
    $jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
        #Routine to handle completed runspaces
        Do {    
            Foreach($runspace in $jobs) {            
                If ($runspace.Runspace.isCompleted) {
                    [void]$runspace.powershell.EndInvoke($runspace.Runspace)
                    $runspace.powershell.dispose()
                    $runspace.Runspace = $null
                    $runspace.powershell = $null               
                } 
            }
            #Clean out unused runspace jobs
            $temphash = $jobs.clone()
            $temphash | Where {
                $_.runspace -eq $Null
            } | ForEach {
                $jobs.remove($_)
            }        
            Start-Sleep -Seconds 1     
        } while ($jobCleanup.Flag)
    })
    $jobCleanup.PowerShell.Runspace = $newRunspace
    $jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  
    #endregion Background runspace to clean up jobs

    $syncHash.button.Add_Click({
        #Start-Job -Name Sleeping -ScriptBlock {start-sleep 5}
        #while ((Get-Job Sleeping).State -eq 'Running'){
            $x+= "."
        #region Boe's Additions
        $newRunspace =[runspacefactory]::CreateRunspace()
        $newRunspace.ApartmentState = "STA"
        $newRunspace.ThreadOptions = "ReuseThread"          
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash) 
        $PowerShell = [PowerShell]::Create().AddScript({
Function Update-Window {
        Param (
            $Control,
            $Property,
            $Value,
            [switch]$AppendContent
        )

        # This is kind of a hack, there may be a better way to do this
        If ($Property -eq "Close") {
            $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal")
            Return
        }

        # This updates the control based on the parameters passed to the function
        $syncHash.$Control.Dispatcher.Invoke([action]{
            # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
            If ($PSBoundParameters['AppendContent']) {
                $syncHash.$Control.AppendText($Value)
            } Else {
                $syncHash.$Control.$Property = $Value
            }
        }, "Normal")
    }                        
Update-Window -Control StarttextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 850
$x += 1..15000000
update-window -Control ProgressBar -Property Value -Value 25

update-window -Control TextBox -property text -value $x -AppendContent
Update-Window -Control ProcesstextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 50

Update-Window -Control FiltertextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 500
update-window -Control ProgressBar -Property Value -Value 75

Update-Window -Control DonetextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 200
update-window -Control ProgressBar -Property Value -Value 100
        })
        $PowerShell.Runspace = $newRunspace
        [void]$Jobs.Add((
            [pscustomobject]@{
                PowerShell = $PowerShell
                Runspace = $PowerShell.BeginInvoke()
            }
        ))
    })

    #region Window Close 
    $syncHash.Window.Add_Closed({
        Write-Verbose 'Halt runspace cleanup job processing'
        $jobCleanup.Flag = $False

        #Stop all runspaces
        $jobCleanup.PowerShell.Dispose()      
    })
    #endregion Window Close 
    #endregion Boe's Additions

    #$x.Host.Runspace.Events.GenerateEvent( "TestClicked", $x.test, $null, "test event")

    #$syncHash.Window.Activate()
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()

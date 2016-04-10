$main = $Null 
$VMS = get-vm | sort State 
$head = ((gc .\head.html) -replace '%4',(get-date).DateTime) -replace '%t'.("VM Report")
$tail = gc .\tail.html
$i = 0 

ForEach ($VM in $VMS){
$i++
        $description= @"
        Currently $($VM.Status.ToLower()) with a <br>
        state of $($VM.State)<br>
        It was created on $($VM.CreationTime)<br>

        Its files are found in $($VM.Path)


"@

if ($vm.State -eq 'Off'){
    $image = "images/pic01.jpg";$style = 'style1'
    $Name=$vm.Name
    }else{
    "VM isnt off"
    $image = "images/pic03.jpg";$style = "style3"
    $Name="$($VM.Name)<br>
    RAM: $($VM.MemoryAssigned /1mb)<br>
    CPU: $($VM.CPUUsage)
    "
    }

    $image = "images/pic0$i.jpg"


        $style = "<article class=`"$($style)`">"
        "setting style as : $style"

        $tile = @"
                                
                                $style
									<span class="image">
										<img src="$image" alt="" />
									</span>
									<a href="generic.html">
										<h2>$Name</h2>
										<div class="content">
											<p>$($description)</p>
										</div>
									</a>
								</article>
"@
$tile

$main += $tile
}

$html = $head + $main + $tail

$html > .\VMReport.html
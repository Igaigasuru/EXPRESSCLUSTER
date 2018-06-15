#Set parameters from parameters
$uri = $Args[0]

#Send request to the target Web Server
$result = Invoke-WebRequest -Uri $uri -UseBasicParsing
$flag = $?

if($flag -eq $true){
    #If Invoke-WebRequest command secceeded ($flag==true), check the Web Server Status.
    $status = $result.StatusCode

	if($result.StatusCode -lt 300){
       	#If Web Server Status is abnormal (HTTP StatusCode is bigger than 300), return 1.
		Write-Output "Succeeded to connect to the Web Server."
        clplogcmd -m "Succeed to connect to the Web Server."

        exit 0
	}else{
       	#If Web Server Status is normal, return 0.
		Write-Output "Received Error from the Web Server. (StatusCode: $status)"
        clplogcmd -m "Received Error from the Web Server."
        clplogcmd -m $status -l ERR

		exit 1
	}
}else{
    #if Invoke-WebRequest command failed, return 1.
	Write-Output "Failed to connect to the Web Server."
    clplogcmd -m "Failed to connect to the Web Server." -l ERR

	exit 1
}

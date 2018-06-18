#Requires -Modules dbatools

$dbs = (Get-DbaDatabaseFile -SqlInstance localhost).where({$_.PhysicalName -like "H:\Data*"  -and $_.TypeDescription -eq "ROWS" -and $_.PhysicalName -notlike "*temp*" -and $_.PhysicalName -notlike "*.ldf" -and $_.PhysicalName -notlike "*-evil.mdf*"})

foreach($db in $dbs){

    $ACL = Get-ACL -Path $db.PhysicalName
    
    Set-DbaDatabaseState -SqlInstance localhost -SingleUser -Database $db.Database -Confirm -Force
    Dismount-DbaDatabase -SqlInstance localhost -UpdateStatistics -Database $db.database -Confirm -Force

    $Group = New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
    $ACL.SetOwner($Group)
    Set-Acl $db.PhysicalName -AclObject $ACL -Confirm
    
    Copy-Item -Path $db.PhysicalName -Destination "e:\Data" -Force -Confirm
    $fileStructure = New-Object System.Collections.Specialized.StringCollection
    $fileStructure.Add(“e:\data\$($db.LogicalName).mdf”)

    Mount-DbaDatabase -SqlInstance localhost -Database $db.database -FileStructure $fileStructure -Confirm
    Set-DbaDatabaseState -ReadWrite -SqlInstance localhost -Database $db.database -MultiUser -Confirm 
    Rename-Item -Path $db.PhysicalName -NewName "$($db.LogicalName)-evil.mdf" -Confirm
}

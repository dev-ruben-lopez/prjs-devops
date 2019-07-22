#Powershell for AzureRmKeyVault
#Create a key vault for a resource group, activate DIskEncryption
#An aleternative to this method, is to use a template from github URL : https://github.com/Azure/azure-quickstart-templates/tree/master/201-encrypt-running-windows-vm-without-aad

New-AzureRmKeyVault -Location "eastus" `
    -ResourceGroupName "AdelaideRlopezResGroup01" `
    -VaultName "adelVaultKey" `
    -EnabledForDiskEncryption
	

#Change the access policy to use it on VMs	
Set-AzureRmKeyVaultAccessPolicy -VaultName "adelVaultKey" -ResourceGroupName "AdelaideRlopezResGroup01" -EnabledForDiskEncryption


#Create a snapshot of the VM before run the encrytpion

$resourceGroupName = "AdelaideRlopezResGroup01"
$vmName="DemoRlopezWin01"
$Location = "eastus"
$snapshotName = "DemoRlopezWin01_snap_001"

$vm = get-azureRmVm -ResourceGroupName $resourceGroupName -Name $vmName

$vmOSDisk=(Get-AzureRmVM -ResourceGroupName $resourceGroupName -Name $vmName).StorageProfile.OsDisk.Name
$Disk = Get-AzureRmDisk -ResourceGroupName $resourceGroupName -DiskName $vmOSDisk
$SnapshotConfig = New-AzureRmSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location

$Snapshot=New-AzureRmSnapshot -Snapshot $snapshotConfig -SnapshotName `
      $snapshotName -ResourceGroupName $resourceGroupName
 
#verify the snapshot
Get-AzureRmSnapshot -ResourceGroupName $resourceGroupName

#NOw, apply the encryption to the disk
Set-AzureRmVmDiskEncryptionExtension `
	-ResourceGroupName $resourceGroupName `
    -VMName $vmName `
    -VolumeType [All | OS | Data]
	-DiskEncryptionKeyVaultId <keyVault.ResourceId> `
	-DiskEncryptionKeyVaultUrl <keyVault.VaultUri> `
     -SkipVmBackup
	 
	 
Get-AzureRmVmDiskEncryptionStatus  -ResourceGroupName "AdelaideRlopezResGroup01" -VMName "DemoRlopezWin01"

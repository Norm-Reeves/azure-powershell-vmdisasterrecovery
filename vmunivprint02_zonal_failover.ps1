param (
	[string]$Zone = $( Read-Host "Input West US 2 zone to deploy to (1-3)" )
)

$ResourceGroupName = "rg-vmunivprint02-prod-001"
$VMName = "vmunivprint02"
$OSDiskName = "dsk-vmunivprint02-os-pssd-westus2-zrs"
$NICName = "nic-vmunivprint02-prod-001"

$LocationName = "westus2"
$VMSize_Zone1 = "Standard_D4as_v5"

#Step 1: Delete only VM.
Remove-AzVM -ResourceGroupName $ResourceGroupName -Name $VMName -Force

#Step 2: Create VM and attach existing disk and NIC.
$OSDisk =  Get-AzDisk -DiskName $OSDiskName -ResourceGroupName $ResourceGroupName
$NIC = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICName

$VirtualMachineConfig = New-AzVMConfig -VMName $VMName -VMSize $VMSize_Zone1 -EncryptionAtHost -Zone @($Zone)# #Zone input is an array.
$VirtualMachineConfig = Add-AzVMNetworkInterface -VM $VirtualMachineConfig -Id $NIC.Id -DeleteOption "Detach"
$VirtualMachineConfig = Set-AzVMOSDisk -VM $VirtualMachineConfig -ManagedDiskId $OSDisk.Id -DiskSizeInGB 128 -CreateOption Attach -Windows -DeleteOption Detach -StorageAccountType $OSDisk.Sku.Name -Name $OSDisk.Name
$VirtualMachineConfig = Set-AzVMBootDiagnostic -VM $VirtualMachineConfig -Enable -ResourceGroupName $ResourceGroupName -StorageAccountName "stvmunivprint02bootdiags" 

New-AzVM -ResourceGroupName $ResourceGroupName -VM $VirtualMachineConfig -Location $LocationName

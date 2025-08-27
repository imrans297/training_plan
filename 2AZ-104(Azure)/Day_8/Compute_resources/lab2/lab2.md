created windows Vm with name as appvm
publicip: 20.85.126.79

![alt text](image.png)

connected through RDP with remmina
![alt text](image-1.png)

right now i was having disk size as Standard B1s (1 vcpu, 1 GiB memory) increased to Standard_B2ms

Before
![alt text](image-2.png)

# Log in to Azure
az login

# Stop VM before resize (safer option)
az vm deallocate --resource-group app-grp --name appvm

# Resize VM
az vm resize --resource-group app-grp --name appvm --size Standard_B2ms

# Start VM again
az vm start --resource-group app-grp --name appvm

After changes applied
![alt text](image-3.png)

Azure windows Virtual Machine Disk capacity
![alt text](image-4.png)

Types of Different Disks
![alt text](image-5.png)

created Additional datadisk with name as "datadisk01"
![alt text](image-6.png)

Mount volume on windows Virtual Machine
![alt text](image-7.png)
After Mounting
![alt text](image-8.png)

What happen when we stop the machine??
before that created an two file 
one in D drive which is temprorary storage with a name as data.txt
![alt text](image-9.png)
another in e drive "data" with a name as testfile
![alt text](image-10.png)
once we stop the VM and restarted it the file which is stored in D drive which is temprorary strogae the file is been deleted
![alt text](image-11.png)

Data Disk Snapshot
Creating a new disk from the snapshot (Point in time copy of you data)
1st we will create a snapshot of "datadisk01" with named as "disk01-snapshot"
![alt text](image-12.png)
![alt text](image-13.png)

and then from the snapshot we created an Disk and attached it to the new VM
![alt text](image-14.png)
![alt text](image-15.png)

Attaching An existing Disk from virtual machine "appvm" to virtual machine "appvm-02"

Yes we can attach the existing disk to another VM



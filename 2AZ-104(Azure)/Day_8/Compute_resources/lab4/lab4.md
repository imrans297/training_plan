creating an Availability Sets
Created linuxvm-01 and linuxvm-02 on the same appset availability set
![alt text](image.png)
Created

![alt text](image-1.png)

Availibility Zones
what is meant by AZ ?
This features help provides better availability for your application by protecting them from datacenter failures.

Each Availability zone is a unique physical location in an Azure region.

Each zone comprises of one or more data centers that has independent power, cooling, and networking

Hence the physical separation of the Availability Zones helps protect applications against data center failures

Using Availability Zones, you can be guaranteed an availability of 99.99% for your virtual machines. You need to ensure that you have 2 or more virtual machines running across multiple availability zones.


Azure Virtual Machine Scale sets

Creted Scale Set with name as "appset01"
![alt text](image-2.png)

under the Scale set 
![alt text](image-3.png)

Setting Scalling COnditions

two Types:
1st: Mannual Scale
![alt text](image-4.png)
2nd: Custome AutoScale based on Metrics and Threshold
![alt text](image-5.png)
We can also add an Scale rule
![alt text](image-6.png)


Install stress to give stress to the VM into the terminal
sudo stress --cpu 1000
Increasing by one
![alt text](image-7.png)
![alt text](image-8.png)


Creating Virtual Machine Scale Sets - Custom Script
uploaded Cutom Script to Storage account
IIIS.ps1
![alt text](image-9.png)
![alt text](image-10.png)

Created through windows

Virtual Scale Set
![alt text](image-13.png)

VM: appset_0
![alt text](image-14.png)
Vm: appset-1
![alt text](image-15.png)

Extension+Applications
![alt text](image-16.png)

Result server
![alt text](image-12.png)
![alt text](image-11.png)

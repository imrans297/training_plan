# Network Security Group

* This is used to filter Network Traffic between Azure Resources in and Azure Virtual Network
* Filter Inbound (Incoming) and Outbound (outgoing) traffic to Allow or Deny

#### Default Security Group Rules

![alt text](image.png)

#### Added Custom as well as http service in the inbound rule and tested

![alt text](image-1.png)

* After Adding Service as HTTP it was able to reache

![alt text](image-2.png)

* After Adding the custom rule it was not able to reached due to high priority which was set at 200

![alt text](image-3.png)

#### Addind My Ip address and Private Ip to test the SG rule

![alt text](image-4.png)

### Network Sg - Access to other Machines
* Deploying new Subnet - appsubnet01
* Deploying new VM(appvm-linux-01) -on the new Subnet

![alt text](image-5.png)

* webvm-linux-01 Sg
  ![alt text](image-7.png)
* appvm-linux-01 sg 
 ![alt text](image-6.png)

* Made changes to Webvm-linux-01 Sg and tested the connections.
* Below is the terminal of appvn-linux-01
    ![alt text](image-8.png)

### To Allow ping request ICMP

* Tested Before applying changes to N/W rule
![alt text](image-9.png)

* After applying changes to the rule.
![alt text](image-11.png)
![alt text](image-12.png)

#### Also we can add one NSG to mutiple VM's
 * we can associate this to Network Interface or either Subnet 

Here we will first add Key Vault to our RG and then we will add secrets into the KeyVault and then we will run DataDactory Access to the key Vault
create an Key Vault in azure
![alt text](image-1.png)

linked to Azure Key Vault
![alt text](image.png)
its pintung to the storage account

Go to the storage account under security+networking - Access Key
![alt text](image-3.png)
copy the key to the clipboard and import an key in Key Vault create Secret generate/import
![alt text](image-4.png)
![alt text](image-5.png)
Grant Access to the Access Key Vault
![alt text](image-6.png)
![alt text](image-7.png)

Create Key vault service Linked
we need to create an Linked service 
in ADF left side pannel Manage search for Azure key Vault services
![alt text](image-8.png)
Test Connection and create
![alt text](image-9.png)

![alt text](image-10.png)
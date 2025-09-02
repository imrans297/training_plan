Create a new Pipeline and renamed it

Go to the newly created pipeline and got to General > get Metadata drag and drop
![alt text](image.png)

Rename it and under dataset select Azure Data Lake Storage Gend2 and click on continue select JSon rename it
![alt text](image-1.png)


Assured that linked the Azure Key Vault (Test Connection)
![alt text](image-2.png)

![alt text](image-3.png)

![alt text](image-4.png)

Click on Add Activities and Add COPY DATA1

![alt text](image-5.png)

Under source create new and choose Data Lake Storage Gen2 and select JSON
![alt text](image-6.png)
![alt text](image-7.png)

![alt text](image-8.png)

SINK Parameter 
@concat(substring(item().name, 0, sub(length(item().name),5)), '-csv')
![alt text](image-13.png)

![alt text](image-9.png)

![alt text](image-10.png)



Pipeline got executed
![alt text](image-11.png)

![alt text](image-12.png)
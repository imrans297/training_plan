
Upload Sample data into the storage account "adlsvinoworld"
create 2 separate container with named as "landing" and "raw"
upload the sampledata.zip into the container landing
![alt text](image-1.png)
![alt text](image.png)

In ADF choose Built in copy task select Run once now
![alt text](image-2.png)

![alt text](image-3.png)
Test connection and then create
under files and folder choose storage account and container
![alt text](image-4.png)

![alt text](image-5.png)

![alt text](image-6.png)

![alt text](image-7.png)

Monitor the Pipeline and see activiy and details of the pipeline
![alt text](image-8.png)
![alt text](image-9.png)

under the storage account "" under the container "raw"
we can see the zip files are been unzip we have folders along with the source file
![alt text](image-10.png)

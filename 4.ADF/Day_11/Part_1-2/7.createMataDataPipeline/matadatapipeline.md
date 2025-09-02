![alt text](image-1.png)



![alt text](image-2.png)

select * from dbo.ADF_Metadata where FolderName in ('masterdata', 'productdata')
![alt text](image-3.png)

![alt text](image-4.png)

under setting untick the First row only box
![alt text](image-5.png)

@activity('GetMetadata').output.value
![alt text](image-6.png)

under "source" drop down and select "abs_csv_cleansed_stage_dynamic"
![alt text](image-7.png)

@item().FolderName
@item().FileName
@item().Delimiter

![alt text](image-8.png)

![alt text](image-9.png)

TRUNCATE TABLE stage.@{item().TableName}
![alt text](image-10.png)

As we can see out sql database server "stage.stor" and "stage.Territory" is Empty
![alt text](image-11.png)
![alt text](image-12.png)
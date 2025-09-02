Setup of Environment

Creating Storage account
![alt text](image-1.png)

Creating Azure Data Factory
![alt text](image-2.png)
Once created cleck on `Launch Studio`
![alt text](image-5.png)

Setup Azure sql DB Resources
![alt text](image-6.png)
select SQL databases

under that create an sql Database server here selected ((US) East US 2)
sql db server name: vinoworld-dev-sql29
server admin login: vinoworldadmin
![alt text](image-7.png) 
select: 
Backup storage redudancy as" locally- backup storage
compute+storage: configure
![alt text](image-8.png)
netwroking:
![alt text](image-9.png)

keep other setting as Default and create
![alt text](image-10.png)

Setup Azure Data Studio
installed packages and 
tar -xvf "...."
cd ~/Downloads/azuredatastudio-linux-x64
./azuredatastudio 
![alt text](image-11.png)

now connect our database server to Azure Data Studio
under Azure Data Studio
server name: vinoworld-dev-sql29.database.windows.net

![alt text](image-13.png)
we are now connected to azure sql dv
![alt text](image-14.png)
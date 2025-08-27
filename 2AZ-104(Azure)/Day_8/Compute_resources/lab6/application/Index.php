<html lang="en">
  <head>
    <meta charset="utf-8">    
    <meta name="description" content="Displaying Courses">    
    <link href="./lib/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet">
    <title>Courses</title>
</head>
<body>

    <div class="container-sm">

      <h1><?php echo "List of Courses" ?></h1>
      <p class="lead">This is a list of Courses</p>
    

    <table class="table table-striped table-bordered">
        <thead class="table-dark">
          <tr>
            <th class="th-sm" scope="col">Course ID</th>
            <th class="th-sm" scope="col">Course Name</th>
            <th class="th-sm" scope="col">Rating</th>            
          </tr>
        </thead>
        <tbody>
          <tr>
            <th scope="row">1</th>
            <td>Docker and Kubernetes</td>
            <td>4.5</td>            
          </tr>
          <tr>
            <th scope="row">2</th>
            <td>AWS Solutions Architect Associate</td>
            <td>4.6</td>            
          </tr>
          <tr>
            <th scope="row">3</th>
            <td>AZ-104 Azure Administrator</td>
            <td>4.7</td>            
          </tr>          
        </tbody>        
      </table>
    </div>
</body>
</html>


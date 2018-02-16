<?php header("X-XSS-Protection: 0");?>

<!doctype html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>PostgreSQL DB demo</title>
  </head>
  <body>
      <div style="color: #FFFFFF; background-color: #000000; font-family: 'Arial'">
      <br>
      <form id="connectdb" name="connectdb" action="#" method="POST">
          <label for="fip">FIP</label>
          <input type="text" id="fip" name="fip" value="" />
          <input type="submit" id="connect" name="connect" value="Start" />
          <input type="submit" id="disconnect" name="disconnect" value="Stop" />
      </form>
      <br>
      <b><div id = "dbstatus" style="font-size: 20px"></div></b>
      <br>
      </div>
      <br>
      <font face='Arial'><div id = "dbtransaction" font-family:'Arial'></div></font>
      <br>

<?php

// ---------- Set PostgreSQL Parameters ----------
//  $dbname: PostgreSQL Database Name
//  $dbtable: PostgreSQL Database Table Name
//  $dbuser: PostgreSQL Database Logon User Name
//  $dbpass: PostgreSQL Database Logon User Password
//  $dbport: PostgreSQL Database Access Port (default: 5432)
// -----------------------------------------------
  $dbname = "test-db";
  $dbtable = "testtable";
  $dbuser = "postgres";
  $dbpass = "postgres";
  $dbport = "5432";


  $logged_in = false;
  $trn_repeat = true;

  // Omajinai for flash string
  echo str_pad("", 4096)."<br/>\n";
  ob_end_flush();
  ob_start('mb_output_handler');


  // Coonect button is clicked
  if (isset($_POST["connect"])) {
    $fip = $_POST["fip"];
    $constr = "host=".$fip." port=".$dbport." dbname=".$dbname." user=".$dbuser." password=".$dbpass;

    //Connect to DB
    $conn = pg_connect($constr);
    if($conn != true){
      $str = "<b><font color=\\\"#FF0000\\\">Error!</font></b> Cannot connect to DB.";
      $str = "<script type =\"text/javascript\">document.getElementById(\"dbstatus\").innerHTML=\"".$str."\";</script>";
      print ($str);
      ob_flush();
      flush();
      exit;
    }

//    $str = "Connected to DB.";
//    $str = "<script type =\"text/javascript\">document.getElementById(\"dbstatus\").innerHTML=\"".$str."\";</script>";
//    print ($str);
//    ob_flush();
//    flush();

$trn_repeat = false;

while (true){
  $trn_result = true;

  if($trn_repeat != true){
    //Get DB table data
    $result = pg_query($conn, "SELECT number FROM testtable WHERE name='US-dollar'");
    $doll = pg_fetch_result($result, 0, 0);

    //Show DB table data
    $str = "<script type =\"text/javascript\">document.getElementById(\"dbstatus\").innerHTML=\"US Dollar: ".$doll."$\";</script>";
    print ($str);
    ob_flush();
    flush();
    sleep(3);
  }
  else{
    sleep(3);
  }

  $doll_tmp=$doll;

  //Start Transaction
  $result = pg_query($conn, "BEGIN");
  if($result != true){
    $trn_result = false;
  }

  if($trn_repeat != true){
    $str_tmp = "<b>Transaction Start</b><br><br>";
    $str = "<script type =\"text/javascript\">document.getElementById(\"dbtransaction\").innerHTML=\"".$str_tmp."\";</script>";
  }
  else{
    $str_tmp = "<b><font color=\\\"#FF367F\\\">Retry from ".$doll."$</font></b><br><br>";
    $str = "<script type =\"text/javascript\">document.getElementById(\"dbtransaction\").innerHTML=\"".$str_tmp."\";</script>";
  }
  print ($str);
  ob_flush();
  flush();

  for($count = 0; $count < 5; $count++) {
    $result = pg_query($conn, "UPDATE ".$dbtable." set number=number+10 where name='US-dollar'");

    if($result != true){
      $trn_result = false;
      $str_tmp = $str_tmp."Add 10$: <b><font color=\\\"#FF0000\\\">Error!</font></b> Transaction failed.<br>";
      $str = "<script type =\"text/javascript\">document.getElementById(\"dbtransaction\").innerHTML=\"".$str_tmp."\";</script>";
      print ($str);
      ob_flush();
      flush();
      sleep(1);
      break;
    }

    $doll_tmp+=10;
    $str_tmp = $str_tmp."  Add 10$ -> ".$doll_tmp."$<br>";
    $str = "<script type =\"text/javascript\">document.getElementById(\"dbtransaction\").innerHTML=\"".$str_tmp."\";</script>";
    print ($str);
    ob_flush();
    flush();
    sleep(1);
  }

  if($trn_result == true){
    $result = pg_query($conn, "COMMIT");
    $trn_repeat = false;
    if($result != true){
      $trn_result = false;
    }
  }

  if($trn_result != true){
    $result = pg_query($conn, "ROLLBACK");
    $str_tmp = $str_tmp."<br><b><font color=\\\"#FF367F\\\">Error! Rollback: ".$doll."$</font></b>";
    $trn_repeat = true;
    pg_close($conn);
    $conn = pg_connect($constr);

  }
  else{
    $str_tmp = $str_tmp."<br><b><font color=\\\"#136FFF\\\">Commit: ".$doll_tmp."$</font?</b>";
  }

  $str = "<script type =\"text/javascript\">document.getElementById(\"dbtransaction\").innerHTML=\"".$str_tmp."\";</script>";
  print ($str);
  ob_flush();
  flush();

}

  //End of "Start"
  }

  if (isset($_POST["disconnect"])) {
    //Disconnect DB
    $result = pg_query($conn, "ROLLBACK");
    $result = pg_close($conn);

    $str = "Disconnected DB.";
    $str = "<script type =\"text/javascript\">document.getElementById(\"dbstatus\").innerHTML=\"".$str."\";</script>";
    print ($str);
    ob_flush();
    flush();

  }
?>

  </body>
</html>


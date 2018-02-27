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
          <input type="submit" id="start" name="start" value="Start" />
          <input type="submit" id="stop" name="stop" value="Stop" />
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
//  $itemname: Countup target name which should be the same as a name in db table (e.g. "US-dollar")
//  $displayname: Display name of the countup target (e.g. "$")
// -----------------------------------------------
  $dbname = "test-db";
  $dbtable = "testtable";
  $dbuser = "postgres";
  $dbpass = "postgres";
  $dbport = "5432";
  $itemname = "US-dollar";
  $displayname = "$";

// ---------- Please don't change the following parameters ----------
  $logged_in = false;
  $conn = null;
  $trn_repeat = false;
// -----------------------------------------------


  // Omajinai for flash string
  echo str_pad("", 4096)."<br/>\n";
  ob_end_flush();
  ob_start('mb_output_handler');


// [Start] button is clicked
  if (isset($_POST["start"])) {
    $fip = $_POST["fip"];
    $constr = "host=".$fip." port=".$dbport." dbname=".$dbname." user=".$dbuser." password=".$dbpass;

    //Connect to DB
    $conn = pg_connect($constr);
    if($conn != true){
      $str = "<b><font color=\\\"#FF0000\\\">Error!</font></b> Cannot connect to DB: ".$dbname;
      display_data($str, "dbstatus", 0);
      exit;
    }

    $trn_repeat = true;
    $trn_result = true;

    while ($trn_repeat){
      if($trn_result){
        //Get DB table data and store it to $num
        $result = pg_query($conn, "SELECT number FROM testtable WHERE name='".$itemname."'");
        $num = pg_fetch_result($result, 0, 0);
        $str = $itemname.": ".$num.$displayname;
        display_data($str, "dbstatus", 1);
      }
      $num_tmp=$num;

      //Start Transaction
      if($trn_result){
        $str_tmp = "<b>Transaction Start</b><br><br>";
        display_data($str_tmp, "dbtransaction", 0);
      }
      else{
        $str_tmp = "<b><font color=\\\"#FF367F\\\">Retry from ".$num.$displayname."</font></b><br><br>";
        display_data($str_tmp, "dbtransaction", 0);
    
        while(true){
          $conn = pg_connect($constr);
          if($conn){
            break;
          }
          sleep(1);
        }
      }
      $result = pg_query($conn, "BEGIN");
      for($count = 0; $count < 5; $count++) {
        $result = pg_query($conn, "UPDATE ".$dbtable." set number=number+10 where name='".$itemname."'");
        $trn_result = $result;
        if($trn_result != true){
          $str_tmp = $str_tmp."Add 10".$displayname." -> <b><font color=\\\"#FF0000\\\">Error!</font></b> Transaction failed.<br>";
          display_data($str_tmp, "dbtransaction", 1);
          break;
        }
        $num_tmp+=10;
        $str_tmp = $str_tmp."  Add 10".$displayname." -> ".$num_tmp.$displayname."<br>";
        display_data($str_tmp, "dbtransaction", 1);
      }
      if($trn_result == true){
        $result = pg_query($conn, "COMMIT");
        $trn_result = $result;
      }
      if($trn_result != true){
        pg_query($conn, "ROLLBACK");
        $str_tmp = $str_tmp."<br><b><font color=\\\"#FF367F\\\">Error! Rollback: ".$num.$displayname."</font></b>";
        display_data($str_tmp, "dbtransaction", 1);
        pg_close($conn);
        $conn = pg_connect($constr);
      }
      else{
        $str_tmp = $str_tmp."<br><b><font color=\\\"#136FFF\\\">Commit: ".$num_tmp.$displayname."</font></b>";
        display_data($str_tmp, "dbtransaction", 1);
      }
    }
    
    // End of [Start] button
  }

// [Stop] button is clicked
  if (isset($_POST["stop"])) {
    //Disconnect DB
    $result = true;
    if ($conn != null)
      $result = pg_close($conn);
    if ($result == true){
      $str = "Disconnected DB: ".$dbname;
      display_data($str, "dbstatus", 1);

      $trn_repeat = false;
    }
    else{    
      $str = "Error! Cannot disconnect DB: ".$dbname;
      display_data($str, "dbstatus", 1);
    }

  // End of [Stop] button is clicked
  }

//function to displat data
function display_data($str, $tagid, $sleeptime)
{
    $str = "<script type =\"text/javascript\">document.getElementById(\"".$tagid."\").innerHTML=\"".$str."\";</script>";
    print ($str);
    ob_flush();
    flush();
    sleep($sleeptime);
}

?>
  </body>
</html>

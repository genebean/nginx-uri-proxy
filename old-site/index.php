<!DOCTYPE html>
<html>
<head>
  <title>Old Site in Apache</title>
  <style>
    body {
      background-color: #474c55;
      color: #edeff0;
    }
    a:link, a:visited {
      color: #edeff0;
    }
    table, th, td {
      border:  1px solid #edeff0;
    }
    th, td {
      padding-left:  20px;
      padding-right: 20px;
    }
  </style>
</head>
<body>
  <h1>Old Site in Apache</h1>
  <h2>
    <?php
    $url =  "{$_SERVER['REQUEST_URI']}";
    $escaped_url = htmlspecialchars( $url, ENT_QUOTES, 'UTF-8' );
    echo 'Current URI: ' . $escaped_url;
    ?>
    <br />
    <br />
    <table>
      <tr>
        <th>Page</th>
        <th>Status</th>
        <th>Notes</th>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/">/</a></td>
        <td>Migrated</td>
        <td>home page</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/index.php">/index.php</a></td>
        <td>Migrated</td>
        <td>Be sure to migrate your actual home page :)</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part1">/part1</a></td>
        <td>Migrated</td>
        <td></td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part1/random/sub/section">/part1/random/sub/section</a></td>
        <td></td>
        <td>Inherits migrated status</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part2">/part2</a></td>
        <td>Old Site</td>
        <td>Inherits default location block</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part2/special/page.php">/part2/special/page.php</a></td>
        <td>Migrated</td>
        <td>Single page explicitly migrated</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part2/special/hello.php">/part2/special/hello.php</a></td>
        <td></td>
        <td>Same directory but not migrated yet</td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/part3">/part3</a></td>
        <td>Migrated</td>
        <td></td>
      </tr>
      <tr>
        <td><a href="http://<?php echo $_SERVER['SERVER_NAME'] ?>/not/migrated/yet">/not/migrated/yet</a></td>
        <td>Old Site</td>
        <td>Also inherits default location block</td>
      </tr>
    </table>
  </h2>
  <h3>
    When migrating content, don't forget about your CSS, JavaScript, and other paths that are included in your pages.
    I recommend making sure your new site and old site <u>do not</u> use the same path for includes... otherwise
    you will have problems here.
  <h3>
</body>
</html>

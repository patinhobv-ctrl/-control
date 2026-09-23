<?php
$c = require "test_providers2.php";
foreach($c["providers"] as $i=>$p){
    if(!is_string($p)){
        echo "$i: ";
        var_dump($p);
    }
}
echo "OK\n";
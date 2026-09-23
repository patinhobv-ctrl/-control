<?php

$config = require "config/app.php";
foreach ($config["providers"] as $i => $p) {
    if (!is_string($p)) {
        echo "Provider $i is not a string: ";
        var_dump($p);
    }
}
echo "All providers are strings\n";
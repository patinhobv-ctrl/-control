<?php
require __DIR__.'/vendor/autoload.php';
$app = require __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Auth;

$user = User::where('email','admin@empresa.com')->first();
Auth::login($user);
echo "User: ".$user->name." sucursal:".$user->sucursal_id.PHP_EOL;
echo "Can crear sucursales: ".($user->can('crear sucursales')?'si':'no').PHP_EOL;

$req = Illuminate\Http\Request::create('/api/sucursales','POST',[
    'codigo' => 'SUC016',
    'nombre' => 'Sucursal Test',
    'ciudad' => 'Asunción',
    'direccion' => 'Test 123',
    'responsable' => 'Test'
]);
$req->setUserResolver(fn()=> $user);
$req->headers->set('Accept','application/json');

$controller = app(App\Http\Controllers\Api\SucursalController::class);
try{
    $resp = $controller->store($req);
    echo "Status: ".$resp->getStatusCode().PHP_EOL;
    echo "Content: ".$resp->getContent().PHP_EOL;
}catch(Throwable $e){
    echo "Error: ".$e->getMessage().PHP_EOL;
    echo $e->getTraceAsString().PHP_EOL;
}

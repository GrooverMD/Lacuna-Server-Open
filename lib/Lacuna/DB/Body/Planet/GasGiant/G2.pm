package Lacuna::DB::Body::Planet::GasGiant::G2;

use Moose;
extends 'Lacuna::DB::Body::Planet::GasGiant';

use constant image => 'pg2';



use constant galena => 14000;

use constant bauxite => 4000;

use constant goethite => 2000;


no Moose;
__PACKAGE__->meta->make_immutable;


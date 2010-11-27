package Lacuna::RPC::Building::HallsOfVrbansk;

use Moose;
use utf8;
no warnings qw(uninitialized);
extends 'Lacuna::RPC::Building';

sub app_url {
    return '/hallsofvrbansk';
}

sub model_class {
    return 'Lacuna::DB::Result::Building::Permanent::HallsOfVrbansk';
}

sub get_upgradable_buildings {
    my ($self, $session_id, $building_id) = @_;
    my $empire = $self->get_empire_by_session($session_id);
    my $building = $self->get_building($empire, $building_id);
    my @buildings;
    my $upgradable = $building->get_upgradable_buildings;
    while (my $building = $upgradable->next) {
        push @buildings, {
            id      => $building->id,
            name    => $building->name,
            x       => $building->x,
            y       => $building->y,
            level   => $building->level,
            image   => $building->image_level,
        };
    }
    return {
        buildings   => \@buildings,
        status      => $self->format_status($empire, $building->body),
    };
}

sub sacrifice_to_upgrade {
    my ($self, $session_id, $building_id, $upgrade_id) = @_;
    my $empire = $self->get_empire_by_session($session_id);
    my $building = $self->get_building($empire, $building_id);
    my $upgrade = $self->get_building($empire, $upgrade_id);
    my @upgradable = $building->get_upgradable_buildings->get_column('id')->all;
    unless ($upgrade->id ~~ \@upgradable) {
        confess [1009, 'The Halls of Vrbansk do not have the knowledge necessary to upgrade the '.$upgrade->name];
    }
    $upgrade->start_upgrade;
    my $halls = $building->get_halls;
    foreach (1..$upgrade->level + 1) {
        $halls->next->delete;
    }
    my $body = $building->body;
    $body->needs_surface_refresh(1);
    $body->update;
    return { status => $self->format_status($empire, $body) };
}

__PACKAGE__->register_rpc_method_names(qw(get_upgradable_buildings sacrifice_to_upgrade));

no Moose;
__PACKAGE__->meta->make_immutable;

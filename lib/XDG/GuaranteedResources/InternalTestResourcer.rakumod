# THIS WON'T WORK OUTSIDE OF THIS PACKAGE
# MAKE YOUR OWN CLASS JUST LIKE THIS ONE
# You can just copy-paste this one and change
# the class name.
#
# Sorry. It's to do with how %?RESOURCES
# is scoped.
use XDG::GuaranteedResources::AbstractResourcer;

unit class XDG::GuaranteedResources::InternalTestResourcer does XDG::GuaranteedResources::AbstractResourcer;

method fetch-resource(::?CLASS:U: ) {
    %?RESOURCES;
}

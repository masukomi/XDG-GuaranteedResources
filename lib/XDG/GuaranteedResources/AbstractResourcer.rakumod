unit module XDG::GuaranteedResources::AbstractResourcer;

role XDG::GuaranteedResources::AbstractResourcer {
	# your implementatino of fetch-resource should be
	# method fetch-resource(::?CLASS:U:){%?RESOURCES}
	method fetch-resource(::?CLASS:U:){...}

}

unit module XDG::GuaranteedResources::AbstractResourcer;
use XDG::BaseDirectory :terms;

role XDG::GuaranteedResources::AbstractResourcer {
	# Note I've provided your implementation of
	# these methods commented out at the bottom.
	# Just copy, paste into your Resourcer, and uncomment.
	# Also change the string returned by app-name

	# app name should return a single string that is the name of the application
	# and can be used as a directory name in the XDG directories
	method app-name(::?CLASS:U:){...}
	# your fetch-resource should be the following
	# method fetch-resource(::?CLASS:U:){%?RESOURCES;}
	method fetch-resource(::?CLASS:U:){...}


	method data-resource(Str $path){::?CLASS.fetch-resource{"data/$path"};}
	method config-resource(Str $path){::?CLASS.fetch-resource{"config/$path"};}
	method cache-resource(Str $path){::?CLASS.fetch-resource{"data/$path"};}
	method runtime-resource(Str $path){::?CLASS.fetch-resource{"runtime/$path"};}
	method state-resource(Str $path){::?CLASS.fetch-resource{"state/$path"};}



}

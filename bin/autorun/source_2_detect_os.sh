#!env bash

export cygwin=false;
export darwin=false;
export linux=false;
export msys=false

case  $(uname | cut -c1-6) in
	Linux)
		export linux=true;
		;;
	Darwin) 
		export darwin=true;
		;;
	MINGW*) 
		export msys=true;
		;;
	CYGWIN)	
		export cygwin=true;
		;;
esac

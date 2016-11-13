module find;

import std.file;
import std.path;
import std.range;
import std.regex;
import std.stdio;
import std.algorithm;

import core.exception;

import commando;

void main( string[] args )
{
	// Declare the variables for the arguments
	bool recurse;
	bool isRegex;
	string directory;
	string pattern;

	try
	{
		// the `parse` method takes a string array and a delegate.
		// The delegate will be used for building the parser
		ArgumentParser.parse( args, ( ArgumentSyntax syntax )
		{
			// we use `commando.CaseSensitive.yes` here because CaseSensitive conflicts with the std lib
			syntax.config.caseSensitive = commando.CaseSensitive.yes;

			// Define our options with the `option` method.
			// The `option` method has the following signature: `void option( T )( char shortName, string longName, T* ptr, Required required, string helpText )`
			syntax.option( 'r', "recurse", &recurse, Required.no, "Search directory recursively" );
			syntax.option( 'R', "regex", &isRegex, Required.no, "Specify that the pattern is a regular expression (defult is glob)" );
			syntax.option( 'p', "pattern", &pattern, Required.yes, "The file name search pattern" );
			syntax.option( 'd', "directory", &directory, Required.yes, "The directory to search" );
		} );
	}
	catch( ArgumentParserException ex )
	{
		// Catch any exceptions while building the parser or actually parsing and display it nicely.
		stderr.writefln( ex.msg );
		return;
	}

	bool filterFiles( string name )
	{
		if( !name.exists )
			return false;

		if( name.isDir )
			return false;

		try
		{
			return isRegex ? !!name.matchFirst( pattern ) : name.globMatch( pattern );
		}
		catch( RegexException ex )
		{
			stderr.writefln( "Error in regular expression: %s", ex.msg );
			assert( false );
		}
	}

	string normalize( string path )
	{
		return path.asNormalizedPath
	               .array
				   .asAbsolutePath
				   .array
				   .idup;
	}

	if( !directory.isValidPath )
	{
		stderr.writefln( "'%s' is not a valid path" );
		return;
	}

	try
	{
		directory = normalize( directory );
		auto entries = directory.dirEntries( SpanMode.breadth )
								.filter!( filterFiles )
								.map!( normalize );

		foreach( entry; entries )
			writeln( entry );
	}
	catch( AssertError ) { }
	catch( Throwable th )
	{
		stderr.writefln( "Error while searching for files: %s", th.msg );
	}
}
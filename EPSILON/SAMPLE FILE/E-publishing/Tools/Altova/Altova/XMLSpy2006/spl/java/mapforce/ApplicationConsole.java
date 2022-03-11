/**
 * [=$application.Name]Console.java
 *
 * This file was generated by [=$Host].
 *
 * YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
 * OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
 *
 * Refer to the [=$HostShort] Documentation for further details.
 * [=$HostURL]
 */


package [=$JavaPackageName];

import com.altova.types.*;


public class [=$application.Name]Console {

	public static void main(String\[\] args) {
		System.out.println("[=$application.OriginalName] Application");

[if $InputParameterCount > 0
]		java.util.Hashtable	mapArguments = new java.util.Hashtable();
		if( args.length <= 1 )	{
			System.out.println();
			System.out.println( \"WARNING: No parameters given!\");
			System.out.println( \"SYNTAX: [=$application.Name] [
	foreach $Mapping in $application.Mappings
		foreach $AlgorithmGroup in $Mapping.AlgorithmGroups
			foreach $SourceLibrary in $AlgorithmGroup.SourceLibraryList
				if $SourceLibrary.Kind = 4	' Parameter Library
					if $SourceLibrary.IsOptional ]\[[endif
					]/[=$SourceLibrary.Name] ...[
					if $SourceLibrary.IsOptional ]\][endif
					] [
				endif
			next
		next
	next
		]\");
			System.out.println( \"Note: If you want to use spaces as values write them inbetween double quotes.\" );
			System.out.println();
		}
		else
		{
			for( int i = 0; i < args.length; i++ )
			{
				String sName = args\[ i \];
				if( sName.substring( 0, 1 ).equals( \"/\" )  &&  ( i + 1 ) < args.length )
					mapArguments.put( sName.substring( 1, sName.length() ), args\[ ++i \] );
			}
		}
[endif
foreach $Mapping2 in $application.Mappings]
		try { // [=$Mapping2.OriginalName]
			TraceTargetConsole ttc = new TraceTargetConsole();

[			$AlgorithmGroups = $Mapping2.AlgorithmGroups
			include "java/mapforce/ApplicationMain.java"]
			System.out.println("Finished");
		} 
		catch (com.altova.UserException ue) {
			System.out.print("USER EXCEPTION:");
			System.out.println( ue.getMessage() );
			System.exit(1);
		}
		catch (Exception e) {
			System.out.print("ERROR:");
			System.out.println( e.getMessage() );
			e.printStackTrace();
			System.exit(1);
		}
[next]
	}
}


class TraceTargetConsole implements com.altova.TraceTarget {
	public void writeTrace(String info) {
		System.out.println(info);
	}
}
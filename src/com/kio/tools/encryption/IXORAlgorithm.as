package com.kio.tools.encryption
{
	import flash.utils.ByteArray;

	public interface IXORAlgorithm
	{		
		function codeByteArray(s:ByteArray):ByteArray;		
		function code(s:String):String;		
		function randomString():String;		
	}
}
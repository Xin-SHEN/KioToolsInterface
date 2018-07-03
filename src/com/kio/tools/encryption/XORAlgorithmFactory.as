package com.kio.tools.encryption
{
	import com.hurlant.crypto.Crypto;
	import com.hurlant.crypto.symmetric.ICipher;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.core.ByteArrayAsset;
	
	public class XORAlgorithmFactory extends EventDispatcher 
	{
		//this is the CircleCalculator library.swf file (encrypted with LibraryEncrypter of course)
		[Embed (source="library.swf", mimeType="application/octet-stream")]
		private var encryptedSwf:Class;
		
		private var _XORAlgorithm:IXORAlgorithm=null;
		
		public function XORAlgorithmFactory(completeHandler:Function)
		{
			super();
			
			this.addEventListener(Event.COMPLETE, completeHandler);
			
			//load up the swf file that contains the CircleCalculator class
			var fileData:ByteArrayAsset = ByteArrayAsset(new encryptedSwf());
			
			var key:ByteArray = new ByteArray();
			fileData.readBytes(key, 0, 8);
			var encryptedBytes:ByteArray = new ByteArray();
			fileData.readBytes(encryptedBytes);
			
			//decrypt library.swf
			var aes:ICipher = Crypto.getCipher("blowfish-ecb", key, Crypto.getPad("pkcs5"));
			aes.decrypt(encryptedBytes);
			
			//load the swf bytes into the current application domain
			var ldr:Loader = new Loader();
			var ldrContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			
			//do this for AIR support
			if(ldrContext.hasOwnProperty("allowLoadBytesCodeExecution"))
				ldrContext.allowLoadBytesCodeExecution = true;
			
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadSwfComplete);
			ldr.loadBytes(encryptedBytes, ldrContext);
		}
		
		private function loadSwfComplete(event:Event):void
		{
			var cc:Class = ApplicationDomain.currentDomain.getDefinition("com.kio.tools.encryption.XORAlgorithm") as Class;
			_XORAlgorithm = new cc();
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * @return an object implementing the ICircleCalculator interface
		 */
		public function getInstance():IXORAlgorithm
		{
			return _XORAlgorithm;
		}
	}
}


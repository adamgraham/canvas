package com.zigurous 
{
	final public class Random 
	{
		//////////////////////
		// DIRECTION (-1,1) //
		//////////////////////
		
		static public function directionInteger():int 
		{
			return (Math.random() < 0.5) ? 1 : -1;
		}
		
		static public function directionFloat():Number 
		{
			return (Math.random() < 0.5) ? 1.0 : -1.0;
		}
		
		//////////////////
		// BINARY (0,1) //
		//////////////////
		
		// BOOLEAN //
		
		static public function boolean():Boolean 
		{
			return Math.random() < 0.5;
		}
		
		// INTEGER //
		
		static public function binary():int 
		{
			return integerInclusive( 0, 1 );
		}
		
		// STRING //
		
		static public function binaryString( bits:uint = 32 ):String 
		{
			var binaryCode:String = "";
			while ( bits-- ) binaryCode += String(binary);
			return binaryCode;
		}
		
		///////////////////////
		// INTEGER (min,max) //
		///////////////////////
		
		// INCLUSIVE //
		
		static public function integerInclusive( min:int, max:int ):int 
		{
			return Math.random() * Math.abs( (max - min + 1) ) + min;
		}
		
		// INCLUSIVE-EXCLUSIVE //
		
		static public function integerInclusiveExclusive( min:int, max:int ):int 
		{
			return Math.random() * Math.abs( (max - min) ) + min;
		}
		
		// EXCLUSIVE //
		
		static public function integerExclusive( min:int, max:int ):int 
		{
			return Math.random() * Math.abs( (max - min - 1) ) + min + 1;
		}
		
		// EXCLUSIVE-INCLUSIVE //
		
		static public function integerExclusiveInclusive( min:int, max:int ):int 
		{
			return Math.random() * Math.abs( (max - min) ) + min + 1;
		}
		
		/////////////////////
		// FLOAT (min,max) //
		/////////////////////
		
		static public function float( min:Number, max:Number ):Number 
		{
			return Math.random() * Math.abs( max - min ) + min;
		}
		
		/////////////////////
		// PERCENT (0,100) //
		/////////////////////
		
		static public function percentInteger():int 
		{
			return integerInclusive( 0, 100 );
		}
		
		static public function percentFloat():Number 
		{
			return float( 0.0, 100.0 );
		}
		
		static public function percentFloatWhole():Number 
		{
			return float( 0.0, 1.0 );
		}
		
		/////////
		// HEX //
		/////////
		
		static public function hex():String 
		{
			var hex:String = "";
			var digit:int = integerInclusiveExclusive( 0, 16 );
			
			if ( digit < 10 ) 
			{
				hex += String(digit);
			} 
			else 
			{
				var char:String;
				
				switch ( digit )
				{
					case 10:
						char = 'A';
						break;
					case 11:
						char = 'B';
						break;
					case 12:
						char = 'C';
						break;
					case 13:
						char = 'D';
						break;
					case 14:
						char = 'E';
						break;
					case 15:
						char = 'F';
						break;
				}
				
				hex += char;
			}
			
			return hex;
		}
		
		static public function hexString():String 
		{
			return "0x" + hex8Bit() + hex8Bit() + hex8Bit();
		}
		
		static public function hexStringNBits( bits:uint = 32 ):String 
		{
			bits /= 4;
			var hexString:String = "0x";
			while ( bits-- ) hexString += hex();
			return hexString;
		}
		
		static public function hex8Bit():String 
		{
			return hex() + hex();
		}
		
		///////////
		// COLOR //
		///////////
		
		static public function color():uint 
		{
			return uint(Math.random() * 0xFFFFFF);
		}
		
		static public function colorInRange( red:String = null, green:String = null, blue:String = null ):uint 
		{
			if ( red == null ) red = hex8Bit();
			if ( green == null ) green = hex8Bit();
			if ( blue == null ) blue = hex8Bit();
			
			return uint("0x" + red + green + blue);
		}
		
		static public function colorRGB():Object 
		{
			var rgb:Object = {};
			
			rgb.r = colorRGBValue();
			rgb.g = colorRGBValue();
			rgb.b = colorRGBValue();
			
			return rgb;
		}
		
		static public function colorRGBValue():uint 
		{
			return integerInclusive( 0, 255 );
		}
		
		///////////
		// ARRAY //
		///////////
		
		static public function arrayIndex( array:Array, fromIndex:int = 0 ):int 
		{
			return integerInclusiveExclusive( fromIndex, array.length );
		}
		
		static public function arrayElement( array:Array, fromIndex:int = 0 ):* 
		{
			return array[integerInclusiveExclusive( fromIndex, array.length )];
		}
		
		static public function arrayElementInRange( array:Array, min:int, max:int ):* 
		{
			return array[integerInclusiveExclusive( min, max )];
		}
		
	}
	
}
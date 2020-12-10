package com.zigurous 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	final public class Main extends MovieClip 
	{
		private var _stage:Stage;
		
		private var _game:Sprite;
		private var _background:MovieClip;
		private var _instructions:Sprite;
		
		private var _canvasBounds:Vector.<Rectangle>;
		private var _canvasBitmapData:BitmapData;
		private var _canvasBitmap:Bitmap;
		
		private var _canvasRed:CanvasBoard;
		private var _canvasBlue:CanvasBoard;
		private var _canvasGreen:CanvasBoard;
		private var _canvasYellow:CanvasBoard;
		
		private var _canvasTimer:Timer;
		
		private var _mBackdropRed:Sprite;
		private var _mBackdropBlue:Sprite;
		private var _mBackdropGreen:Sprite;
		private var _mBackdropYellow:Sprite;
		
		private var _mColorSetRed:Sprite;
		private var _mColorSetBlue:Sprite;
		private var _mColorSetGreen:Sprite;
		private var _mColorSetYellow:Sprite;
		
		private var _music:Sound;
		
		static public const DEBUG:Boolean = false;
		
		static private const DEG_TO_RAD = Math.PI / 180.0;
		static private const RAD_TO_DEG = 180.0 / Math.PI;
		
		public function Main() 
		{
			stop();
			
			if ( stage != null ) init( null );
			else addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init( event:Event ):void 
		{
			removeEventListener( Event.ADDED_TO_STAGE, init );
			gotoAndStop( 2 );
			
			loaderInfo.addEventListener( Event.COMPLETE, onLoaded );
		}
		
		private function onLoaded( event:Event ):void 
		{
			loaderInfo.removeEventListener( Event.COMPLETE, onLoaded );
			
			_stage = stage;
			_stage.scaleMode = StageScaleMode.NO_SCALE;
			//_stage.scaleMode = StageScaleMode.NO_BORDER;
			
			_game = new Game as Sprite;
			
			_background = _game["mBackground"];
			_instructions = _game["mInstructions"];
			
			_mBackdropRed = _game["mBackdropRed"];
			_mBackdropBlue = _game["mBackdropBlue"];
			_mBackdropGreen = _game["mBackdropGreen"];
			_mBackdropYellow = _game["mBackdropYellow"];
			
			_mColorSetRed = _game["mColorSetRed"];
			_mColorSetBlue = _game["mColorSetBlue"];
			_mColorSetGreen = _game["mColorSetGreen"];
			_mColorSetYellow = _game["mColorSetYellow"];
			
			_canvasRed = new CanvasBoard();
			_canvasBlue = new CanvasBoard();
			_canvasGreen = new CanvasBoard();
			_canvasYellow = new CanvasBoard();
			
			_canvasRed.init( ColorSet.RED, BrushShape.CIRCLE, 46.0, Math.random() * 360.0, new <CanvasBoard>[_canvasBlue, _canvasGreen, _canvasYellow] );
			_canvasBlue.init( ColorSet.BLUE, BrushShape.CIRCLE, 46.0, Math.random() * 360.0, new <CanvasBoard>[_canvasRed, _canvasGreen, _canvasYellow] );
			_canvasGreen.init( ColorSet.GREEN, BrushShape.CIRCLE, 46.0, Math.random() * 360.0, new <CanvasBoard>[_canvasRed, _canvasBlue, _canvasYellow] );
			_canvasYellow.init( ColorSet.YELLOW, BrushShape.CIRCLE, 46.0, Math.random() * 360.0, new <CanvasBoard>[_canvasRed, _canvasBlue, _canvasGreen] );
			
			//_music = new MusicLoop01() as Sound;
			//if ( _music != null ) _music.play( 0.0, int.MAX_VALUE, new SoundTransform( 0.05, 0.0 ) );
			
			addChild( _game );
			
			if ( !DEBUG ) _stage.addEventListener( MouseEvent.CLICK, startGame );
			else startGame( null );
		}
		
		private function startGame( event:MouseEvent ):void 
		{
			_stage.removeEventListener( MouseEvent.CLICK, startGame );
			
			_background.gotoAndStop( 2 );
			
			_instructions.visible = false;
			
			_mColorSetRed.visible = false;
			_mColorSetBlue.visible = false;
			_mColorSetGreen.visible = false;
			_mColorSetYellow.visible = false;
			
			_mBackdropRed.visible = false;
			_mBackdropBlue.visible = false;
			_mBackdropGreen.visible = false;
			_mBackdropYellow.visible = false;
			
			_canvasBounds = new <Rectangle>[];
			_canvasBounds.push( new Rectangle( _mBackdropRed.x, _mBackdropRed.y, _mBackdropRed.width, _mBackdropRed.height ) );
			_canvasBounds.push( new Rectangle( _mBackdropGreen.x, _mBackdropGreen.y, _mBackdropGreen.width, _mBackdropGreen.height ) );
			_canvasBounds.push( new Rectangle( _mBackdropBlue.x, _mBackdropBlue.y, _mBackdropBlue.width, _mBackdropBlue.height ) );
			_canvasBounds.push( new Rectangle( _mBackdropYellow.x, _mBackdropYellow.y, _mBackdropYellow.width, _mBackdropYellow.height ) );
			
			_canvasRed.activate( _canvasBounds[0] );
			_canvasGreen.activate( _canvasBounds[1] );
			_canvasBlue.activate( _canvasBounds[2] );
			_canvasYellow.activate( _canvasBounds[3] );
			
			_canvasTimer = new Timer( 25000.0, 1 );
			_canvasTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onCanvasTimerComplete );
			
			_stage.addEventListener( Event.ENTER_FRAME, update );
			_stage.addEventListener( MouseEvent.MOUSE_MOVE, onFreeMouseMovement );
			//_stage.addEventListener( KeyboardEvent.KEY_DOWN, onInputDown );
			//_stage.addEventListener( KeyboardEvent.KEY_UP, onInputUp );
			
			onCanvasTimerComplete( null );
		}
		
		private function update( event:Event ):void 
		{
			_canvasRed.update();
			_canvasGreen.update();
			_canvasBlue.update();
			_canvasYellow.update();
		}
		
		private function onCanvasTimerComplete( event:TimerEvent ):void 
		{
			clearCanvas();
			
			var bounds:Vector.<Rectangle> = new <Rectangle>[];
			var amountOfBounds:int = Math.min( Random.integerInclusive( 1, 6 ), 4 );
			
			for ( var i:int = 0; i < amountOfBounds; i++ ) 
			{
				var leftIndex:int = Random.integerInclusiveExclusive( 0, 4 );
				var rightIndex:int = Random.integerInclusiveExclusive( 0, 4 );
				
				if ( leftIndex > rightIndex ) 
				{
					var temp:int = leftIndex;
					leftIndex = rightIndex;
					rightIndex = temp;
				}
				
				var aBounds:Rectangle = _canvasBounds[leftIndex];
				var bBounds:Rectangle = _canvasBounds[rightIndex];
				
				var boundMinTop:Number = bBounds.top;
				var boundMaxBottom:Number = bBounds.bottom;
				
				while ( leftIndex != rightIndex ) 
				{
					boundMinTop = Math.min( _canvasBounds[leftIndex].top, boundMinTop );
					boundMaxBottom = Math.max( _canvasBounds[leftIndex].bottom, boundMaxBottom );
					leftIndex++;
				}
				
				bounds.push( new Rectangle( aBounds.x, boundMinTop, bBounds.right - aBounds.left, boundMaxBottom - boundMinTop ) );
			}
			
			_canvasRed.setBounds( bounds[Random.integerInclusiveExclusive( 0, amountOfBounds )] );
			_canvasGreen.setBounds( bounds[Random.integerInclusiveExclusive( 0, amountOfBounds )] );
			_canvasBlue.setBounds( bounds[Random.integerInclusiveExclusive( 0, amountOfBounds )] );
			_canvasYellow.setBounds( bounds[Random.integerInclusiveExclusive( 0, amountOfBounds )] );
			
			var brushShape:int = Random.integerInclusive( 0, 2 );
			_canvasRed._brushShape = brushShape;
			_canvasGreen._brushShape = brushShape;
			_canvasBlue._brushShape = brushShape;
			_canvasYellow._brushShape = brushShape;
			
			_canvasRed._brushSize = Random.float( 16.0, 54.0 );
			_canvasGreen._brushSize = Random.float( 16.0, 54.0 );
			_canvasBlue._brushSize = Random.float( 16.0, 54.0 );
			_canvasYellow._brushSize = Random.float( 16.0, 54.0 );
			
			_canvasRed._speedMultiplier = Random.float( 0.35, 2.0 );
			_canvasGreen._speedMultiplier = Random.float( 0.35, 2.0 );
			_canvasBlue._speedMultiplier = Random.float( 0.35, 2.0 );
			_canvasYellow._speedMultiplier = Random.float( 0.35, 2.0 );
			
			_canvasRed._rotation = Math.random() * 360.0;
			_canvasGreen._rotation = Math.random() * 360.0;
			_canvasBlue._rotation = Math.random() * 360.0;
			_canvasYellow._rotation = Math.random() * 360.0;
			
			recalculateAngles();
			redrawBrushes();
			resetTimer();
		}
		
		private function clearCanvas():void 
		{
			if ( _canvasBitmapData != null ) 
			{
				_canvasBitmapData.fillRect( _canvasBitmapData.rect, 0xffffff );
				_canvasBitmapData.dispose();
			}
			
			if ( _canvasBitmap != null ) 
			{
				_stage.removeChild( _canvasBitmap );
					
				_canvasBitmap.bitmapData = null;
				_canvasBitmap = null;
			}
			
			_canvasBitmapData = new BitmapData( Number(_stage.stageWidth), Number(_stage.stageHeight), false, 0xffffffff );
			_canvasBitmap = new Bitmap( _canvasBitmapData );
			
			_canvasRed._canvas = _canvasBitmapData;
			_canvasGreen._canvas = _canvasBitmapData;
			_canvasBlue._canvas = _canvasBitmapData;
			_canvasYellow._canvas = _canvasBitmapData;
			
			_stage.addChildAt( _canvasBitmap, 0 );
		}
		
		private function onFreeMouseMovement( event:MouseEvent ):void 
		{
			var dx:Number = (_stage.stageWidth  * 0.5) - _stage.mouseX;
			var dy:Number = (_stage.stageHeight * 0.5) - _stage.mouseY;
			var radians:Number = Math.atan2( dy, dx );
			var degrees:Number = radians * RAD_TO_DEG;
			
			_canvasRed.recalculateWithAngle( degrees );
			_canvasGreen.recalculateWithAngle( degrees + 90.0 );
			_canvasBlue.recalculateWithAngle( degrees + 180.0 );
			_canvasYellow.recalculateWithAngle( degrees + 270.0 );
		}
		
		private function onInputDown( event:KeyboardEvent ):void 
		{
			if ( event.keyCode == Keyboard.W || event.keyCode == Keyboard.UP ) CanvasBoard._up = true;
			else if ( event.keyCode == Keyboard.A || event.keyCode == Keyboard.LEFT ) CanvasBoard._left = true;
			else if ( event.keyCode == Keyboard.S || event.keyCode == Keyboard.DOWN ) CanvasBoard._down = true;
			else if ( event.keyCode == Keyboard.D || event.keyCode == Keyboard.RIGHT ) CanvasBoard._right = true;
			
			recalculateAngles();
		}
		
		private function onInputUp( event:KeyboardEvent ):void 
		{
			if ( event.keyCode == Keyboard.W || event.keyCode == Keyboard.UP ) CanvasBoard._up = false;
			else if ( event.keyCode == Keyboard.A || event.keyCode == Keyboard.LEFT ) CanvasBoard._left = false;
			else if ( event.keyCode == Keyboard.S || event.keyCode == Keyboard.DOWN ) CanvasBoard._down = false;
			else if ( event.keyCode == Keyboard.D || event.keyCode == Keyboard.RIGHT ) CanvasBoard._right = false;
			
			recalculateAngles();
		}
		
		private function recalculateAngles():void 
		{
			_canvasRed.recalculateAngle();
			_canvasGreen.recalculateAngle();
			_canvasBlue.recalculateAngle();
			_canvasYellow.recalculateAngle();
		}
		
		private function redrawBrushes():void 
		{
			_canvasRed.redrawBrush();
			_canvasGreen.redrawBrush();
			_canvasBlue.redrawBrush();
			_canvasYellow.redrawBrush();
		}
		
		private function resetTimer():void 
		{
			_canvasTimer.stop();
			_canvasTimer.reset();
			_canvasTimer.start();
		}
		
	}
	
}
package com.zigurous 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import fl.motion.AdjustColor;
	
	final public class CanvasBoard 
	{
		private var _brush:Shape;
		private var _brushContainer:Sprite;
		private var _brushColor:ColorTransform;
		
		private var _colorSet:Vector.<uint>;
		private var _otherCanvases:Vector.<CanvasBoard>;
		
		private var _collisionTimer:Timer;
		private var _colliding:Boolean;
		
		private var _centerX:Number;
		private var _centerY:Number;
		
		private var _vx:Number;
		private var _vy:Number;
		
		private var _activated:Boolean;
		
		internal var _canvas:BitmapData;
		internal var _canvasBounds:Rectangle;
		
		internal var _brushSize:Number;
		internal var _brushShape:int;
		
		internal var _hue:Number;
		internal var _hueDelta:Number;
		
		internal var _rotation:Number;
		internal var _angle:Number;
		
		internal var _speedMultiplier:Number;
		
		static internal var _up:Boolean;
		static internal var _left:Boolean;
		static internal var _down:Boolean;
		static internal var _right:Boolean;
		
		static private const BASE_SPEED:Number = 10.0;
		
		static private const DEG_TO_RAD = Math.PI / 180.0;
		static private const RAD_TO_DEG = 180.0 / Math.PI;
		
		public function init( colorSet:Vector.<uint>, brushShape:int, brushSize:Number, rotationOffset:Number = 0.0, otherCanvases:Vector.<CanvasBoard> = null ):void 
		{
			_colorSet = colorSet;
			_brushShape = brushShape;
			_brushSize = brushSize;
			_rotation = rotationOffset;
			_otherCanvases = (otherCanvases != null) ? otherCanvases : new <CanvasBoard>[];
			
			_hue = 0.0;
			_hueDelta = 10.0 * Random.directionFloat();
			
			_brush = new Shape();
			_brushContainer = new Sprite();
			_brushContainer.addChild( _brush );
			_brushColor = new ColorTransform();
			
			_collisionTimer = new Timer( 1000.0, 1 );
			_collisionTimer.addEventListener( TimerEvent.TIMER_COMPLETE, onCollisionComplete );
			
			redrawBrush();
		}
		
		public function activate( startingBounds:Rectangle ):void 
		{
			if ( !_activated ) 
			{
				_activated = true;
				_colliding = false;
				
				_vx = 0.0;
				_vy = 0.0;
				_speedMultiplier = 1.0;
				_angle = 0.0;
				
				recalculateAngle();
				setBounds( startingBounds );
				
				_centerX = _canvasBounds.x + (_canvasBounds.width  * 0.5);
				_centerY = _canvasBounds.y + (_canvasBounds.height * 0.5);
				
				_brush.x = _centerX;
				_brush.y = _centerY;
			}
		}
		
		public function setBounds( bounds:Rectangle ):void 
		{
			if ( bounds != null ) _canvasBounds = bounds;
			else _canvasBounds = new Rectangle();
		}
		
		internal function update():void 
		{
			_centerX += _vx * _speedMultiplier;
			_centerY += _vy * _speedMultiplier;
			
			checkForWalls();
			checkForCollision();
			
			_brush.x = _centerX;
			_brush.y = _centerY;
			
			draw();
		}
		
		internal function draw():void 
		{
			_brush.rotation = Random.float( 0.0, 360.0 );
			
			var sizeHalf:Number = _brushSize * 0.5;
			_brush.x += Random.float( -sizeHalf, sizeHalf );
			_brush.y += Random.float( -sizeHalf, sizeHalf );
			
			_brushColor.color = _colorSet[Random.integerInclusiveExclusive( 0, _colorSet.length )];
			_brush.transform.colorTransform = _brushColor;
			_canvas.draw( _brushContainer );
		}
		
		internal function redrawBrush():void 
		{
			var sizeHalf:Number = _brushSize * 0.5;
			var offset:Number = -sizeHalf;
			
			_brush.graphics.clear();
			_brush.graphics.beginFill( _brushColor.color );
			
			if ( _brushShape == BrushShape.SQUARE ) 
			{
				_brush.graphics.drawRect( offset, offset, _brushSize, _brushSize );
			}
			else if ( _brushShape == BrushShape.CIRCLE ) 
			{
				_brush.graphics.drawCircle( 0.0, 0.0, sizeHalf );
			}
			else if ( _brushShape == BrushShape.DIAMOND ) 
			{
				_brush.graphics.drawRect( offset, offset, _brushSize, _brushSize );
				_brush.rotation = 45.0;
			}
			else if ( _brushShape == BrushShape.TRIANGLE ) 
			{
				_brush.graphics.moveTo( offset, offset );
				_brush.graphics.lineTo( +sizeHalf, 0.0 );
				_brush.graphics.lineTo( -sizeHalf, sizeHalf );
				_brush.graphics.lineTo( offset, offset );
				_brush.rotation -= 90.0;
			}
			
			_brush.graphics.endFill();
		}
		
		internal function recalculateAngle():void 
		{
			var angle:Number = _angle;
			
			if ( _right ) 
			{
				angle = 0.0;
				
				if ( _up ) angle -= 45.0;
				else if ( _down ) angle += 45.0;
			} 
			else if  ( _left ) 
			{
				angle = 180.0;
				
				if ( _up ) angle += 45.0;
				else if ( _down ) angle -= 45.0;
			} 
			else if ( _down ) 
			{
				angle = 90.0;
			} 
			else if ( _up ) 
			{
				angle = 270.0;
			}
			
			recalculateWithAngle( angle );
		}
		
		internal function recalculateWithAngle( angle:Number ):void 
		{
			_angle = angle;
			
			var radians:Number = (_angle + _rotation) * DEG_TO_RAD;
			
			_vx = Math.cos( radians ) * BASE_SPEED;
			_vy = Math.sin( radians ) * BASE_SPEED;
		}
		
		private function checkForWalls():void 
		{
			var left:Number = _canvasBounds.left;
			var right:Number = _canvasBounds.right;
			var top:Number = _canvasBounds.top;
			var bottom:Number = _canvasBounds.bottom;
			
			if ( _centerX < left ) _centerX = right;
			else if ( _centerX > right ) _centerX = left;
			
			if ( _centerY < top) _centerY = bottom;
			else if ( _centerY > bottom ) _centerY = top;
		}
		
		private function checkForCollision():void 
		{
			if ( !_colliding ) 
			{
				var len:int = _otherCanvases.length;
				for ( var i:int = 0; i < len; i++ ) 
				{
					if ( isCollidingAABB( _brush, _otherCanvases[i]._brush ) ) 
					{
						_hue += _hueDelta;
						
						if ( _hue > 180.0 ) _hue = -180.0;
						else if ( _hue < -180.0 ) _hue = 180.0;
						
						var colorFilter:AdjustColor = new AdjustColor();
						
						colorFilter.brightness = 0.0;
						colorFilter.contrast = 0.0;
						colorFilter.saturation = 0.0;
						colorFilter.hue = _hue;
						
						var matrix:Array = colorFilter.CalculateFinalFlatArray();
						var colorMatrix:ColorMatrixFilter = new ColorMatrixFilter( matrix );
						
						_brushContainer.filters = [colorMatrix];
						
						_colliding = true;
						_collisionTimer.reset();
						_collisionTimer.start();
						
						break;
					}
				}
			}
		}
		
		private function isCollidingAABB( a:Shape, b:Shape ):Boolean 
		{
			var dx:Number = a.x - b.x;
			var dy:Number = a.y - b.y;
			
			dx = (dx < 0) ? -dx : dx;
			dy = (dy < 0) ? -dy : dy;
			
			return (dx < _brushSize) ? ((dy < _brushSize) ? true : false) : false;
		}
		
		private function onCollisionComplete( event:TimerEvent ):void 
		{
			_colliding = false;
		}
		
	}
	
}
package ru.b0ber.arkanoid.loader {
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.net.URLRequest;
/**
 * @author Andrey Bobkov
 */
public class Resource extends Object {
private var loader:Loader;
private var _alias:String;
private var _url:String;
private var _onComplete:Function;
private var _bytesLoaded:uint = 0;
private var loaded:Boolean = false;

public function Resource(url:String, alias:String, onComplete:Function = null) {
  loader = new Loader();
  loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeListener);
  loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressListener);
  loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
  _url = url;
  _alias = alias;
  _onComplete = onComplete;
}

private function errorListener(event:IOErrorEvent):void {
  loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeListener);
  loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressListener);
  loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
  
}

public function get complete():Boolean {
  return loaded;
}

public function start():void {
  loader.load(new URLRequest(_url));
}

public function get alias():String {
  return _alias;
}

public function get url():String {
  return _url;
}

public function get loaderInfo():LoaderInfo {
  return loader.contentLoaderInfo;
}

public function get bytesLoaded():uint {
  return _bytesLoaded;
}

public function get content():DisplayObject {
  if (!loaded) {
    throw new Error("Load not complete yet");
  }
  return loader.content;
}

public function destroy():void {
  loader.unload();
  loader = null;
}

private function completeListener(event:Event):void {
  loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeListener);
  loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressListener);
  loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
  loaded = true;
  if (_onComplete != null) {
    _onComplete();
  }
}

private function progressListener(event:ProgressEvent):void {
  _bytesLoaded = event.bytesLoaded;
}

}
}

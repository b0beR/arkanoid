package ru.b0ber.arkanoid.loader {
import flash.events.IOErrorEvent;
import flash.display.LoaderInfo;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.utils.Dictionary;

/**
 * @author Andrey Bobkov
 */
public class BatchLoader extends EventDispatcher {
private var resources:Dictionary = new Dictionary();
private var pendingLoad:Vector.<Resource> = new Vector.<Resource>();
private var count:uint = 0;
private var loadedCount:uint = 0;
private var errorCount:uint = 0;
public function BatchLoader() {
  super();
}

/*
 * Добавление ресурса в список загрузки. 
 * onComplete - колбэк на окончание загрузки данного ресурса
 */
public function add(resourceUrl:String, resourceAlias:String, onComplete:Function = null):void {
  if (resourceAlias in resources) {
    throw new Error("Can't add 2 resources with same alias");
  }
  const resource:Resource = new Resource(resourceUrl, resourceAlias, onComplete);
  resource.loaderInfo.addEventListener(ProgressEvent.PROGRESS, progressListener);
  resource.loaderInfo.addEventListener(Event.COMPLETE, resourceCompleteListener);
  resource.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorListener);
  resources[resourceAlias] = resource;
  pendingLoad.push(resource);
  count++;
}

/*
 * Запуск загрузки добавленных ресурсов. 
 * maxActiveConnections - максимальное количество открытых соединений
 */
public function start(maxActiveConnections:uint = 0):void {
  if (maxActiveConnections == 0) {
    maxActiveConnections = count;
  }
  for (var i:uint = 0; i < maxActiveConnections; i++) {
    (pendingLoad.shift() as Resource).start();
  }
}

/*
 * Получить содержимое загруженного ресурса по алиасу
 */
public function getContents(alias:String):DisplayObject {
  if (!(alias in resources)) {
    throw new Error("No such resource!");
  }
  const resource:Resource = resources[alias] as Resource;
  if (!resource.complete) {
    throw new Error("Not loaded");
  }
  return resource.content;
}

/*
 * Очистка памяти от загруженных объектов и обнуление всего загрузчика
 */
public function dispose():void {
  for each (var resource:Resource in resources) {
    resource.destroy();
  }
  resources = new Dictionary();
  pendingLoad.length = 0;
  count = 0;
  loadedCount = 0;
}

/*
 * Листенер окончания загрузки одного ресурса
 */
private function resourceCompleteListener(event:Event):void {
  const loaderInfo:LoaderInfo = event.target as LoaderInfo;
  loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressListener);
  loaderInfo.removeEventListener(Event.COMPLETE, resourceCompleteListener);
  loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
  loadedCount++;
  if (pendingLoad.length > 0) {
    (pendingLoad.shift() as Resource).start();
  }
  if ((loadedCount + errorCount) == count) {
    dispatchEvent(new LoaderEvent(LoaderEvent.BATCH_COMPLETE));
  }
}

/*
 * Транслятор событий прогресса
 */
private function progressListener(event:ProgressEvent):void {
  var bytesLoaded:uint = 0;
  for each (var resource:Resource in resources) {
    bytesLoaded += resource.bytesLoaded;
  }
  dispatchEvent(new LoaderEvent(LoaderEvent.BATCH_PROGRESS, bytesLoaded, loadedCount));
}


/*
 * Листенер ошибки загрузки
 */
private function errorListener(event:IOErrorEvent):void {
  const loaderInfo:LoaderInfo = event.target as LoaderInfo;
  loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progressListener);
  loaderInfo.removeEventListener(Event.COMPLETE, resourceCompleteListener);
  loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorListener);
  errorCount ++;
  if (pendingLoad.length > 0) {
    (pendingLoad.shift() as Resource).start();
  }
  if ((loadedCount + errorCount) == count) {
    dispatchEvent(new LoaderEvent(LoaderEvent.BATCH_COMPLETE));
  }
}
}
}

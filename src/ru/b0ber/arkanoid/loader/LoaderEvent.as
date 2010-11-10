package ru.b0ber.arkanoid.loader {
	import flash.events.Event;

/**
 * @author Andrey Bobkov
 */
public class LoaderEvent extends Event {
public static const BATCH_PROGRESS:String = "batchLoaderProgress";
public static const BATCH_COMPLETE:String = "batchLoaderComplete";

private var _bytesLoaded:uint;
private var _resourcesLoaded:uint;

public function LoaderEvent(type:String, bytesLoaded:uint = 0, resourcesLoaded:uint = 0) {
  super(type, false, false);
  _bytesLoaded = bytesLoaded;
  _resourcesLoaded = resourcesLoaded;
}
}
}

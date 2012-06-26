package org.bigbluebutton.core.model
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.external.ExternalInterface;
    import flash.utils.Dictionary;
    
    import mx.collections.ArrayCollection;
    import mx.resources.IResourceManager;
    import mx.resources.ResourceManager;
    
    import org.bigbluebutton.core.controllers.events.LocaleEvent;
    import org.bigbluebutton.core.vo.LocaleCode;

    public class LocaleModel
    {
        public var dispatcher:IEventDispatcher;
        private static var MASTER_LOCALE:String = "en_US";
        private var _preferredLocale: String = MASTER_LOCALE;
        private static var BBB_RESOURCE_BUNDLE:String = 'bbbResources';        
        private var _resourceManager:IResourceManager = ResourceManager.getInstance();
        private var _locales:Dictionary = new Dictionary();
        
        public function LocaleModel(dispatcher:IEventDispatcher)
        {
            this.dispatcher = dispatcher;
        }
        
        public function get locals():ArrayCollection {
            var lc:ArrayCollection = new ArrayCollection();
            
            for (var key:Object in _locales) {				
                var l:Locale = _locales[key] as Locale;
                var k:LocaleCode = new LocaleCode(l.code, l.name);
                lc.addItem(k);
            }
            return lc;
        }
        
        public function addLocale(code:String, name:String):void {
            var locale:Locale = new Locale(code, name, dispatcher);
            _locales[locale.code] = locale;
        }
        
        public function get masterLocale():String {
            return MASTER_LOCALE;
        }
        
        public function get preferredLocale():String {
            return _preferredLocale;
        }
        
        public function get resourceManager():IResourceManager {
            return _resourceManager;
        }
        
        public function get defaultLocale():String {
            return ExternalInterface.call("getLanguage");
        }
        
        public function loadMasterLocale():void {
            var locale:Locale = _locales[MASTER_LOCALE];
            locale.load();
        }
        
        public function loadPreferredLocale():void {
            if (defaultLocale == MASTER_LOCALE) {
                masterIsPreferredLocale(defaultLocale);
            } else {
                var locale:Locale = _locales[defaultLocale];
                locale.load();                
            }
        }
        
        public function localeLoaded(code:String):void {
            var e: LocaleEvent;
            
            if (code == MASTER_LOCALE) {
                resourceManager.localeChain = [MASTER_LOCALE];
                e = new LocaleEvent(LocaleEvent.LOAD_MASTER_LOCALE_SUCCEEDED_EVENT);
                e.loadedLocale = code;
                dispatcher.dispatchEvent(e);
            } else {
                resourceManager.localeChain = [code, MASTER_LOCALE];
                e = new LocaleEvent(LocaleEvent.LOAD_PREFERRED_LOCALE_SUCCEEDED_EVENT);
                e.loadedLocale = code;
                dispatcher.dispatchEvent(e);
            }     
            
            update();
        }
        
        public function localeLoadingFailed(code:String):void {
            masterIsPreferredLocale(code);
        }
        
        private function masterIsPreferredLocale(code:String):void {
            resourceManager.localeChain = [MASTER_LOCALE];
            var e: LocaleEvent;
            e = new LocaleEvent(LocaleEvent.LOAD_PREFERRED_LOCALE_SUCCEEDED_EVENT);
            e.loadedLocale = code;
            dispatcher.dispatchEvent(e);
            update();            
        }
        
        public function update():void {
            dispatcher.dispatchEvent(new Event(Event.CHANGE));
        }
    }
}
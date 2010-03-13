package org.coderepos.webservices.google.translate
{
    import flash.events.EventDispatcher;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.net.URLVariables;

    import com.adobe.serialization.json.JSON;

    import org.coderepos.webservices.google.translate.events.GoogleTranslateEvent;
    import org.coderepos.webservices.google.translate.events.GoogleTranslateErrorEvent;

    public class GoogleTranslator extends EventDispatcher
    {
        private var _loader:URLLoader;
        private var _isFetching:Boolean;

        public function GoogleTranslator()
        {
            _isFetching = false;
        }

        public function get isFetching():Boolean
        {
            return _isFetching;
        }

        public function translate(q:String, from:String, to:String):void
        {
            if (_isFetching)
                throw new Error("Already fetching.");

            _isFetching = true;
            var req:URLRequest = new URLRequest(GoogleTranslateEndpoint.TRANSLATE);
            var params:URLVariables = new URLVariables();
            params.v = '1.0';
            params.q = q;
            params.langpair = from + "|" + to;
            req.data = params;
            _loader = new URLLoader();
            _loader.addEventListener(Event.COMPLETE, completeHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _loader.load(req);
        }

        private function completeHandler(e:Event):void
        {
            _isFetching = false;
            var response:String = String(e.target.data);
            trace(response);
            var result:Object;
            try {
                result = JSON.decode(response);
                if ("responseStatus" in result && result["responseStatus"] == '200') {
                    if ("responseData" in result && "translatedText" in result["responseData"]) {
                        dispatchEvent(new GoogleTranslateEvent(
                            GoogleTranslateEvent.COMPLETE, result["responseData"]["translatedText"]));
                    } else {
                        dispatchEvent(new GoogleTranslateErrorEvent(
                            GoogleTranslateErrorEvent.ERROR, "Couldn't find translatedText: " + response));
                    }
                } else {
                    // erroor
                    var errorMessage:String = ("responseDetails" in result)
                        ? result["responseDetails"] : "Couldn't get proper result: " + response;
                    dispatchEvent(new GoogleTranslateErrorEvent(
                        GoogleTranslateErrorEvent.ERROR, errorMessage));
                }
            } catch (e:*) {
                // JSONParseError
                dispatchEvent(new GoogleTranslateErrorEvent(
                    GoogleTranslateErrorEvent.ERROR, "failed to parse response."));
            }
        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e);
        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {
            _isFetching = false;
            dispatchEvent(e);
        }
    }
}


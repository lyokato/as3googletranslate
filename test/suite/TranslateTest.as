package suite
{
    import flexunit.framework.TestCase;
    import flexunit.framework.TestSuite;

    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;

    import org.coderepos.webservices.google.translate.GoogleTranslator;
    import org.coderepos.webservices.google.translate.GoogleDetector;
    import org.coderepos.webservices.google.translate.LanguageType;
    import org.coderepos.webservices.google.translate.events.GoogleTranslateEvent;
    import org.coderepos.webservices.google.translate.events.GoogleTranslateErrorEvent;
    import org.coderepos.webservices.google.translate.events.GoogleDetectEvent;

    public class TranslateTest extends TestCase 
    {
        public function TranslateTest(meth:String) 
        {
            super(meth);
        }

        public static function suite():TestSuite
        {
            var ts:TestSuite = new TestSuite();
            ts.addTest(new TranslateTest("testTranslate"));
            ts.addTest(new TranslateTest("testDetect"));
            return ts;
        }

        public function testTranslate():void
        {
            var translator:GoogleTranslator = new GoogleTranslator();
            translator.addEventListener(GoogleTranslateEvent.COMPLETE, addAsync(translateCompleteHandler, 3600));
            translator.addEventListener(GoogleTranslateErrorEvent.ERROR, translateErrorHandler);
            translator.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            translator.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            translator.translate("こんにちは", LanguageType.JA, LanguageType.EN);
        }

        public function testDetect():void
        {
            var detector:GoogleDetector = new GoogleDetector();
            detector.addEventListener(GoogleDetectEvent.COMPLETE, addAsync(detectCompleteHandler, 3600));
            detector.addEventListener(GoogleTranslateErrorEvent.ERROR, detectErrorHandler);
            detector.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            detector.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            detector.detect("こんにちは");
        }

        private function translateCompleteHandler(e:GoogleTranslateEvent):void
        {
            assertEquals('translated message', e.message, 'Hello');
        }

        private function translateErrorHandler(e:GoogleTranslateErrorEvent):void
        {

        }

        private function detectCompleteHandler(e:GoogleDetectEvent):void
        {
            assertEquals('proper language found', e.language, LanguageType.JA);
        }

        private function detectErrorHandler(e:GoogleTranslateErrorEvent):void
        {

        }

        private function ioErrorHandler(e:IOErrorEvent):void
        {

        }

        private function securityErrorHandler(e:SecurityErrorEvent):void
        {

        }
    }
}

public class EinsteinLanguage_StringTooLongException extends Exception {

    public EinsteinLanguage_StringTooLongException(String field, Integer maxValue, Integer currentValue) {
        setMessage('The maximum allowed length for "' + field + '" is ' + maxValue + ' (current: ' + currentValue + ').');
    }

}
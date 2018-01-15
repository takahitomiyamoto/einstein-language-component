public class EinsteinLanguage_NumberTooSmallException extends Exception {

    public EinsteinLanguage_NumberTooSmallException (String field, Decimal minValue, Decimal currentValue) {
        setMessage('The minimum allowed size for "' + field + '" is ' + minValue + ' (current: ' + currentValue + ').');
    }

}
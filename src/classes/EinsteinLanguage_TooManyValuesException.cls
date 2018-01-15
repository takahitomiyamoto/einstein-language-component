public class EinsteinLanguage_TooManyValuesException extends Exception {

    public EinsteinLanguage_TooManyValuesException(String field, Integer maxValue, Integer currentValue) {
        setMessage('The maximum allowed number of entries for "' + field + '" is ' + maxValue + ' (current: ' + currentValue + ').');
    }

}
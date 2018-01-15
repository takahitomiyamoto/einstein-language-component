public class EinsteinLanguage_NoValuesException extends Exception {

    public EinsteinLanguage_NoValuesException(String field, String check) {
        setMessage('You have not provided any values for "' + field + '".');
    }

}
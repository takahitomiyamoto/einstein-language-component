public class EinsteinLanguage_StringIsEmptyException extends Exception {

    public EinsteinLanguage_StringIsEmptyException(String field, String check) {
        setMessage('The field "' + field + '" cannot be empty.');
    }

}
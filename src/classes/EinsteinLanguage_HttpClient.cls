public class EinsteinLanguage_HttpClient {

    private String url;
    private Boolean isDelete = false;
    private Boolean isPost = false;
    private Boolean isPut = false;
    private EinsteinLanguage_PredictionService predictionService;
    private JSONParser parser;
    private Blob body;

    // Values for HTTP response
    private String errorMessage;
    private Integer statusCode;
    private String statusMessage;


    public EinsteinLanguage_HttpClient(EinsteinLanguage_PredictionService predictionService, String url) {
        System.debug(LoggingLevel.FINE, 'START EinsteinLanguage_HttpClient');

        this.predictionService = predictionService;
        this.url = url;

        System.debug(LoggingLevel.FINE, 'END EinsteinLanguage_HttpClient');
    }

    public EinsteinLanguage_HttpClient(EinsteinLanguage_PredictionService predictionService, String url, Blob body) {
        this.predictionService = predictionService;
        this.url = url;
        this.body = body;
        isPost(true);
    }

    public String getUrl() {
        System.debug(LoggingLevel.FINE, 'START getUrl');

        return url;
    }

    public void execute() {
        System.debug(LoggingLevel.FINE, 'START execute');

        if (url == null) {
            return;
        }

        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setHeader('Authorization', 'Bearer ' + predictionService.getBearerToken());
        request.setHeader('Cache-Control', 'no-cache');
        request.setMethod('GET');
        if (isDelete()) {
            request.setMethod('DELETE');
        } else if (isPost() || isPut()) {
            request.setHeader('Content-Type', EinsteinVision_HttpBodyPart.GetContentType());
            request.setBodyAsblob(body);
            if (isPut()) {
                request.setMethod('PUT');
            } else {
                request.setMethod('POST');
            }
        }
        Http http = new Http();
        HTTPResponse response = http.send(request);
        predictionService.isExecuting(true);
        updateResponseValues(response);

        System.debug(LoggingLevel.FINE, 'END execute');
    }

    private void updateResponseValues(HTTPResponse response) {
        System.debug(LoggingLevel.FINE, 'START updateResponseValues');

        statusCode = response.getStatusCode();
        statusMessage = response.getStatus();
        if (getStatusCode() == 400 || getStatusCode() == 200) {
            try {
                parser = JSON.createParser(response.getBody());
            } catch (Exception e) {
                errorMessage = 'Could not read JSON data';
                return;
            }
            if (getStatusCode() == 200) {
                Boolean hasDataToken = false;
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String currentProperty = parser.getText();
                        if (currentProperty == 'data' || currentProperty == 'metricsData') {
                            parser.nextToken();
                            hasDataToken = true;
                            break;
                        }
                    }
                }
                if (!hasDataToken) {
                    parser = JSON.createParser(response.getBody());
                }
            } else {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        String currentProperty = parser.getText();
                        if (currentProperty == 'message') {
                            parser.nextToken();
                            errorMessage = parser.getText();
                            break;
                        }
                    }
                }
            }
        }
        predictionService.isExecuting(false);

        System.debug(LoggingLevel.FINE, 'END updateResponseValues');
    }

    public boolean isDelete() {
        return isDelete;
    }

    public void isDelete(boolean isDelete) {
        this.isDelete = isDelete;
    }

    public boolean isPost() {
        return isPost;
    }

    public void isPost(boolean isPost) {
        this.isPost = isPost;
    }

    public boolean isPut() {
        return isPut;
    }

    public void isPut(boolean isPut) {
        this.isPut = isPut;
    }

    public Boolean isError() {
        return (getStatusCode()!=200 && getStatusCode()!=204);
    }

    public Integer getStatusCode() {
        return statusCode;
    }

    public String getStatusMessage() {
        return statusMessage;
    }

    public String getResponseError() {
        return errorMessage;
    }

    public JSONParser getParser() {
        return parser;
    }

}